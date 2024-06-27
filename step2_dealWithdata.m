close all; clear; clc;
% read packet status data
fullPath = fileparts(mfilename('fullpath'));
addpath(genpath(fullPath));

%% calculate, saving data 
% settings
% for tech = ["CV2X", "11p"]
%     for rho_km = 100:50:350
%         TxID = 10;  % -1 means calculate the average PRP on the road
%         TxInterval = 0.1;
%         logTimeStep = 1;
%         timePeriod = 1;  % [3,4]
%         disResolution = 10;
%         calAvg = true;
% 
% 
%         % get database path
%         dbFilePath = fullfile(fullPath, "Output", "simulation_1", tech, sprintf("rho%d_v_km", round(rho_km)), "resuts_1.db");
%         tableName = 'PacketStatusDetail';
% 
%         % get "real" PRP of tagged vehicle
%         [onRoadAvgPRP] = prp_onRoad(tech, dbFilePath, tableName, -1, timePeriod,...
%             disResolution);
% 
%         %% plot estimated PRP by all vehicles 1 s earlier
%         % estimate PRP (estimateAvgPRP) by all vehicles, numVCount and numVReal is
%         % for tagged vehicle
%         [estimateAvgPRP, numVCount, numVReal] = prp_density_Estimation(tech, dbFilePath, tableName, TxID, calAvg, TxInterval, timePeriod,...
%             disResolution);
% 
%         % estimate PRP by tagged vehicle
%         calAvg = false;
%         [estimatePRPTgV, ~, ~] = prp_density_Estimation(tech, dbFilePath, tableName, TxID, calAvg, TxInterval, timePeriod,...
%             disResolution);
%         % deal with 0 values
%         estimatePRPTgV = estimatePRPTgV(estimatePRPTgV(:,2) ~= 0, :);
% 
%         % Estimate awareness probability
%         PRP = estimateAvgPRP(:,2);
%         RxTimes = 1;
%         duration = 1;
%         TxInterval = 0.1;
%         Pa = cal_awarenessProbability(PRP, RxTimes, duration, TxInterval);
%         dataFolder = fullfile(fullPath, "Output", "data");
%         if ~exist(dataFolder, 'dir')
%            mkdir(dataFolder)
%         end
%         save(fullfile(dataFolder, sprintf("tech_%s_rhokm_%d", tech, round(rho_km))));
%     end
% end


%% load data and plot
for tech = ["CV2X", "11p"]
    for rho_km = 100:50:350
        load(fullfile(fullPath, "Output", "data", sprintf("tech_%s_rhokm_%d", tech, round(rho_km))));
        %% figure setting
        myColors = [228,26,28
                    55,126,184
                    77,175,74
                    152,78,163
                    255,127,0]./255;
        
        %% figure 1: Number of vehicles
        fig = figure();
        hold on;
        
        % plot number of vehicles derived from BSM
        plot(numVCount(:,1), numVCount(:,2), '-', 'Color', myColors(2,:), DisplayName="Sensed num of V", LineWidth=1.5);
        % plot number of vehicles on road
        plot(numVReal(:,1), numVReal(:,2), '--', 'Color', myColors(1,:), DisplayName="Num of V on Road", LineWidth=1.5);
        % plot re-estimated number
        plot(numVCount(:,1), numVCount(:,2)./Pa, '-', 'Color', myColors(4,:), DisplayName="Re-estimated number", LineWidth=1.5);
        xlabel("Distance [m]");
        ylabel("Number of vehicles");
        legend(Location="northeast");
        title(sprintf("PRP, tech: %s, rho: %d v/km", tech, round(rho_km)));
        figFolder = fullfile(fullPath, "Output", "figs");
        if ~exist(figFolder, 'dir')
           mkdir(figFolder)
        end
        saveas(fig, fullfile(figFolder, sprintf("PRP_tech_%s_rhokm_%d.png", tech, round(rho_km))));
        
        
        %% figure 2: PRP
        fig = figure();
        hold on;
        
        % PRP on road
        plot(onRoadAvgPRP(:,1), onRoadAvgPRP(:,2), '--', Color=myColors(1,:), DisplayName="PRP on road", LineWidth=1.5);
        
        % PRP estimated by tagged vehicle
        scatter(estimatePRPTgV(:,1), estimatePRPTgV(:,2), 20, myColors(2,:), "filled", "DisplayName", "PRP estimated by tagged V");
        
        % PRP estimated by all vehicles
        plot(estimateAvgPRP(:,1), estimateAvgPRP(:,2), '-', Color=myColors(3,:), DisplayName="PRP estimated by all Vs", LineWidth=1.5);
        
        xlabel("Distance [m]");
        ylabel("PRP");
        legend(Location="southwest");
        title(sprintf("Vehicle number, tech: %s, rho: %d v/km", tech, round(rho_km)));
        saveas(fig, fullfile(figFolder, sprintf("vehicleNum_tech_%s_rhokm_%d.png", tech, round(rho_km))));
    end
end


