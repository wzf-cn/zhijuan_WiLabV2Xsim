%% 仿真结束后，运行: Step2_dealWithData

close all    % Close all open figures
clear        % Reset variables
clc          % Clear the command window

%% 部分设置
workingFolder = fileparts(mfilename("fullpath"));
outputMainFolder = fullfile(workingFolder, "Output", "simulation_1");
packetSize=200;                     % packet size [KB]
BandMHz = 10;                       % [MHz]
rho = 0.1;                          % density [vehs/m]
rho_km = rho * 1000;                % density [vehs/km]
speed=(38.177-102.89*rho) * 3.6;    % Average speed [km/h] rho<=0.371
speedStDev= speed/10;               % Standard deviation speed [km/h]
simTime = 5;                        % simulation time [s]

%% 其余设置见两个配置文件
% only_NR.cfg
% only_ITS.cfg

%% NR-V2X simulation
% Configuration file
configFile = 'only_NR.cfg';
outputFolder = fullfile(outputMainFolder, "CV2X", sprintf("rho%d_v_km",rho_km));

% Launches simulation
WiLabV2Xsim(configFile,'outputFolder',outputFolder,'beaconSizeBytes',packetSize, ...
    'simulationTime',simTime,'rho',rho_km,'vMean',speed,'vStDev',speedStDev, ...
    'printPacketReceptionStatusAll', true);

%% IEEE 802.11p simulations
% Configuration file
configFile = 'only_ITS.cfg';
outputFolder = fullfile(outputMainFolder, "11p", sprintf("rho%d_v_km",rho_km));

% Launches simulation
WiLabV2Xsim(configFile,'outputFolder',outputFolder,'beaconSizeBytes',packetSize, ...
    'simulationTime',simTime,'rho',rho_km,'vMean',speed,'vStDev',speedStDev, ...
    'printPacketReceptionStatusAll', true);

