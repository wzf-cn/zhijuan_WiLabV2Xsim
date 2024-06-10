function [onRoadPRP] = prp_onRoad(dbPath, tableName, TxID, TxInterval, obTimePeriod, disResolution, maxDis)
%GETPRPFROMID given a log file, get the distance-PRP data of the specific
%vehicle.
% filePath: The full path of the database
% tableName: the table name, "PacketStatusDetail" for now
% TxID: The ID of the vehicle that it's PRP will be output
% TxInterval: the transmission times interval, normally 0.1 seconds
% logTimeStep: the time step for calculate the average prp
% timePeriod: the time span for calculate the average PRP
% disResolution and maxDis: deciding the distance interval of the dis-PRP
% data
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

times = startTime:1:endTime;
distances = disResolution:disResolution:maxDis;


% load data from database
sqlquery = sprintf("select * from %s where time >= %f and time < %f and TxID = %f", tableName, startTime, endTime, TxID);
data = fetch(conn,sqlquery);
numPktAssuming = floor((endTime - startTime) / TxInterval);  % number of packets each vehicle would generate during the observation time

% init output matrix
onRoadPRP = zeros(length(distances), 1+length(times));
onRoadPRP(:,1) = distances;

for iDis = 1:length(distances)
    % get all data within distance when logged
    tempIndex = data.distance>=distances(iDis)-disResolution & data.distance<distances(iDis);
    totRx = sum(tempIndex);
    RxCorrect = sum(data.packet_status(tempIndex) == 1);
    onRoadPRP(iDis, 2) = RxCorrect / totRx;
end


close(conn);