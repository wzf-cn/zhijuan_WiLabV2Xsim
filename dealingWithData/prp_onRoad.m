function [onRoadPRP] = prp_onRoad(tech, dbPath, tableName, TxID, obTimePeriod, disResolution)
%GETPRPFROMID given a log file, get the distance-PRP data of the specific
%vehicle.
%   input:
%       tech: technology (11p or CV2X)
%       dbPath: The full path of the database
%       tableName: the table name, "PacketStatusDetail" for now
%       TxID: The ID of the vehicle that it's PRP will be output. If equals -1,
%             then calculate the average PRP on the road
%       obTimePeriod: the time span for calculate the average PRP
%       disResolution and maxDis: deciding the distance interval of the dis-PRP
%                                 data
%
% output: dis_prp  -> distanceSteps x logTimeSteps

% Felix

% connect sqlite
% fields of table "PacketStatusDetail"
% [time, TxID, RxID, BRID, distance, packet_status(1:correct, 0:error)]

% link to the database
conn = sqlite(dbPath, "readonly");

% check timePeriod
tPnum = length(obTimePeriod(:));
switch tPnum
    case 1
        startTime = 0;
        endTime = obTimePeriod;
    case 2
        if obTimePeriod(2) - obTimePeriod(1) ~= 1
            error("the time duration should be 1 second");
        end
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
times = startTime:1:endTime;
distances = disResolution:disResolution:maxDis;


% load data from database
if TxID > 0
    sqlquery = sprintf("select * from %s where time >= %f and time < %f and TxID = %f", tableName, startTime, endTime, TxID);
else
    sqlquery = sprintf("select * from %s where time >= %f and time < %f", tableName, startTime, endTime);
end

data = fetch(conn,sqlquery);

% init output matrix
onRoadPRP = zeros(length(distances), length(times));
onRoadPRP(:,1) = distances;

for iDis = 1:length(distances)
    % get all data within distance when logged
    tempIndex = data.distance>=distances(iDis)-disResolution & data.distance<distances(iDis);
    totRx = sum(tempIndex);
    RxCorrect = sum(data.packet_status(tempIndex) == 1);
    onRoadPRP(iDis, 2) = RxCorrect / totRx;
end


close(conn);