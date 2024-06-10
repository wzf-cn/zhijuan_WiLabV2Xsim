% read packet status data

% get database path
dbFilePath = fullfile(fileparts(fileparts(mfilename('fullpath'))), "Output", "ITS", "rho100_v_km", "resuts_1.db");
tableName = 'PacketStatusDetail';
TxID = 10;
TxInterval = 0.1;
logTimeStep = 1;
timePeriod = [3, 4];
disResolution = 10;
maxDis = 1000;

% get "real" PRP of tagged vehicle
[onRoadAvgPRP] = prp_onRoad(dbFilePath, tableName, TxID, TxInterval, timePeriod,...
    disResolution, maxDis);

% get evaluation PRP of tagged vehicle
[estimateAvgPRP, numVCount, numVReal] = prp_density_Estimation(dbFilePath, tableName, TxID, TxInterval, timePeriod,...
    disResolution, maxDis);


% plot density on road and sensed density
myColors = [228,26,28
55,126,184]./255;

fig = figure();
hold on;

plot(numVCount(:,1), numVCount(:,2), '-', 'Color', myColors(2,:), DisplayName="Sensed num of V", LineWidth=1.5);

plot(numVReal(:,1), numVReal(:,2), '--', 'Color', myColors(1,:), DisplayName="Num of V on Road", LineWidth=1.5);
xlabel("Distance [m]");
ylabel("Number of vehicles");
legend(Location="southwest");

fig = figure();
hold on;
plot(onRoadAvgPRP(:,1), onRoadAvgPRP(:,2), '--', Color=myColors(1,:), DisplayName="PRP on road", LineWidth=1.5);
plot(estimateAvgPRP(:,1), estimateAvgPRP(:,2), '-', Color=myColors(2,:), DisplayName="PRP estimated", LineWidth=1.5);
xlabel("Distance [m]");
ylabel("PRP");
legend(Location="southwest");

