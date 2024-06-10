function [estimateAvgPRP, numVCount, numVReal] = prp_density_Estimation(dbPath, tableName, taggedID, TxInterval, obTimePeriod, disResolution, maxDis)
%PRPEVALUATION Evaluate the PRR of Tx by counting the successively received
%packets generated from its neighbour
%   Detailed explanation goes here

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

distances = disResolution:disResolution:maxDis;

% load data from database
sqlquery = sprintf("select * from %s where time >= %f and time < %f and RxID = %f", tableName, startTime, endTime, taggedID);
data = fetch(conn,sqlquery);
numPktAssuming = floor((endTime - startTime) / TxInterval);  % number of packets each vehicle would generate during the observation time

%% Get PRP and density based on BSM
% Step1: get the sensed vehicles of tagged ID
indexSensed = data.packet_status > 0;
sensedIDs = data.TxID(indexSensed);
sensedIDs = unique(sensedIDs);


% init output
avgPRP = zeros(length(distances), length(sensedIDs));
numVCount = avgPRP;


for iSID = 1:length(sensedIDs)
    % Step2: find out how many packets that the vehicle i has been generated
    % within the given distance of tagged ID
    indexSensedID = data.TxID == sensedIDs(iSID);
    tempData = data(indexSensedID,:);
    
    % Step3: find out how many packets have been received successfully by tagged ID
    % among the Step2
    for iDis = 1:length(distances)
        indexDis = tempData.distance >= distances(iDis) - disResolution & tempData.distance < distances(iDis);
        numTot = sum(indexDis);
        if numTot == 0
            continue;
        end
        numRxOK = sum(tempData.packet_status(indexDis) == 1);
        avgPRP(iDis, iSID) = numRxOK/numTot;
        numVCount(iDis, iSID) = numTot / numPktAssuming;  % if the vehicle move from on distance section to the other, count a fraction not just 1
    end
end

% Step4: get average PRP
estimateAvgPRP = sum(avgPRP,2) ./ sum(avgPRP~=0, 2);
estimateAvgPRP(isnan(estimateAvgPRP)) = 0;
numVCount = sum(numVCount, 2);

estimateAvgPRP = [distances', estimateAvgPRP];
numVCount = [distances', numVCount];

%% get real number of vehicles
realIDs = unique(data.TxID);
numVReal = zeros(length(distances), 2);
numVReal(:,1) = distances;

for iRealID = 1:length(realIDs)
    indexRealID = data.TxID == realIDs(iRealID);
    tempData = data(indexRealID,:);

    for iDis = 1:length(distances)
        indexDis = tempData.distance >= distances(iDis) - disResolution & tempData.distance < distances(iDis);
        numTot = sum(indexDis);
        if numTot == 0
            continue;
        end
        numVReal(iDis, 2) = numVReal(iDis, 2) + numTot / numPktAssuming;  % if the vehicle move from on distance section to the other, count a fraction not just 1
    end
end


close(conn);

end

