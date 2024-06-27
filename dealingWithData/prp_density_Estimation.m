function [estimatePRP, numVCountByTgV, numVReal] = prp_density_Estimation(tech, dbPath, tableName, taggedID, calAvg, TxInterval, obTimePeriod, disResolution)
%PRPEVALUATION Evaluate the PRR of Tx by counting the successively received
%packets generated from its neighbour
%   input:
%       tech: technology (11p or CV2X)
%       dbPath: the full path of the database
%       tableName: the table name in the database
%       taggedID: the ID of the tagged vehicle
%       calAvg: Bool. if true, "estimateAvgPRP" will retrun the average
%               estimated PRP
%       TxInterval: [s], the transmission interval, used to estimate the
%                   number of packets generated
%       obTimePeriod: The observation time period.
%                     a. 0 ~ obTimePeriod, if scalar, or
%                     b. obTimePeriod(1) ~ obTimePeriod(2), if two-elements
%                        array
%       disResolution: distance resolution
%
%   output:
%       estimatePRP: estimated PRP by the tagged vehicle (taggedID) when
%                    calAvg is false, or estimated average PRP by all 
%                    vehicles (maybe based on transmit everyone's 
%                    "estimated PRP" 
%       numVCount: the number of vehicles counted by the tagged vehicle
%       numVReal:  the real number of vehicles on road around the tagged
%                  vehicle

% Step0: connect database
% link to the database
conn = sqlite(dbPath, "readonly");

% check timePeriod
tPnum = length(obTimePeriod(:));
switch tPnum
    case 1
        startTime = 0;
        endTime = obTimePeriod;
    case 2
        startTime = obTimePeriod(1);
        endTime = obTimePeriod(2);
    otherwise
        error("timePeriod should be one or two numbers of the simulation time.");
end

% get maximum distance from database
switch tech
    case "11p"
        sqlquery = "select RawMax11p from ParamsInSim";
    case "CV2X"
        sqlquery = "select RawMaxCV2X from ParamsInSim";
    otherwise
        error("tech should be 11p or CV2X");
end
paramsdb = fetch(conn, sqlquery);
maxDis = paramsdb{1,1};
distances = disResolution:disResolution:maxDis;
numPktAssuming = floor((endTime - startTime) / TxInterval);  % number of packets each vehicle would generate during the observation time

% load data from database
if calAvg  % for all vehicle
    sqlquery = sprintf("select * from %s where time >= %f and time < %f", tableName, startTime, endTime);
else  % for spesific vehicle
    sqlquery = sprintf("select * from %s where time >= %f and time < %f and RxID = %f", tableName, startTime, endTime, taggedID);
end
data = fetch(conn,sqlquery);

% get tagged IDs from received IDs
taggedIDs = unique(data.RxID);

% init 
estimateRx = zeros(length(distances), 2);

% For each vehicle, get its estimated PRP by estimate the packets received 
% from it's neighbor
for iTgID = 1:length(taggedIDs)
    data_Tg = data(data.RxID == taggedIDs(iTgID), :);

    %% Get PRP and density based on BSM
    % Get the sensed vehicles of tagged ID
    neighborsSensedByTgV = unique(data_Tg.TxID(data_Tg.packet_status > 0));        

    if taggedIDs(iTgID) == taggedID
        numVCountByTgV = zeros(length(distances), 1);
    end

    for iSID = 1:length(neighborsSensedByTgV)
        % Packets transmitted by one of the tagged V's neighbors
        tempData = data_Tg(data_Tg.TxID == neighborsSensedByTgV(iSID), :);
        
        % Dealing with each distance section
        for iDis = 1:length(distances)
            indexDis = tempData.distance >= distances(iDis) - disResolution & tempData.distance < distances(iDis);
            numPktTot = sum(indexDis);
            if numPktTot == 0
                continue;
            end

            % log the PRP by each neighbor and each distance section
            numRxOK = sum(tempData.packet_status(indexDis) == 1);
            estimateRx(iDis, :) = estimateRx(iDis, :) + [numRxOK, numPktTot];

            if taggedIDs(iTgID) == taggedID
                % if the vehicle move from one road section to the other, count
                % a fraction not just 1
                numVCountByTgV(iDis) = numVCountByTgV(iDis) + numPktTot/numPktAssuming;  
            end
        end
    end
end

estimatePRP = estimateRx(:,1) ./ estimateRx(:,2);
estimatePRP(isnan(estimatePRP)) = 0;
estimatePRP = [distances', estimatePRP];
numVCountByTgV = [distances', numVCountByTgV];


%% get real number of vehicles
data_TgRx = data(data.RxID == taggedID, :);  % all packets tagged V try to receive
neighborIDs = unique(data_TgRx.TxID);  % the neighbor's ID of tagged vehicle

numVReal = zeros(length(distances), 2);
numVReal(:,1) = distances;

for iNID = 1:length(neighborIDs)
    indexNID = data_TgRx.TxID == neighborIDs(iNID);
    tempData = data_TgRx(indexNID,:);

    for iDis = 1:length(distances)
        indexDis = tempData.distance >= distances(iDis) - disResolution & tempData.distance < distances(iDis);
        numPktTot = sum(indexDis);
        if numPktTot == 0
            continue;
        end
        numVReal(iDis, 2) = numVReal(iDis, 2) + numPktTot / numPktAssuming;  % if the vehicle move from on distance section to the other, count a fraction not just 1
    end
end


close(conn);

end

