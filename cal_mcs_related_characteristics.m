%% Calculate Coding Rate, Data Rate, and SINR of NR-V2X
% with given MCS, packet size, and other parameters

% init
clear;clc;

fullPath = fileparts(mfilename('fullpath'));
addpath(genpath(fullPath));

% parameters of NR-V2X
phyParams.fc = 5.9;                 % [GHz]
phyParams.BwMHz = 10;               % [MHz]
phyParams.sizeSubchannel = 12;      % number of RBs in each subchannel
phyParams.SCS_NR = 15;              % Sets the SCS for 5G (kHz)
phyParams.nDMRS_NR = 18;            % Sets the number of DMRS resource element used in each slot
phyParams.SCIsymbols = 3;           % Sets the number of symbols dedicated to the SCI-1 between 2 and 3
phyParams.nRB_SCI = 12;             % Sets the number of RBs dedicated to the SCI-1

% Call function to find the total number of RBs in the frequency domain per Tslot in 5G
phyParams.RBsFrequency = RBtable_5G(phyParams.BwMHz,phyParams.SCS_NR);

phyParams.Tslot_NR = 1e-3/(phyParams.SCS_NR/15);            % 5G Tslot [s]
phyParams.RBbandwidth = 180e3*phyParams.SCS_NR/15;          % 5G Resource Block Bandwidth [Hz]

n0_dBm = -174; %dBm/Hz
noiseFigure_dB = 9;  % dB
phyParams.noisefloor_dBm = n0_dBm + noiseFigure_dB + 10*log10(phyParams.BwMHz*10^6); %
phyParams.noisefloor =  db2pow(phyParams.noisefloor_dBm-30);


phyParams.Ptx_dBm = 46;  % dBm
phyParams.Ptx = db2pow(phyParams.Ptx_dBm-30);

for packetSize = [200, 1600]        % packet size [bytes]
    packetSizeBits = packetSize * 8;    % packet size [bits]
    % print column name
    fprintf("===========================================\n");
    fprintf("%d bytes\n", packetSize);
    fprintf("===========================================\n");
    fprintf("iMCS\tCR\t\tDR [Mbps]\tnRB_b\tSINR_th[dB]\t Transmission Range\n");
    % print
    for MCS_NR = 0:29
        phyParams.MCS_NR = MCS_NR;
        try
            % calculate
            % NbitsHz [bits/s/Hz]
            [nSubchannelperChannel,subchannelperPacket,nRB_b,gammaMin_dB,NbitsHz,CR,Qm] = findRBsBeaconSINRmin_5G(phyParams,packetSizeBits);
            
            % calculate data rate: 
            % eq 4 in V. Todisco et al.: Performance Analysis of Sidelink 5G-V2X Mode 2 Through Open-Source Simulator
            n_symslot = 12;         % the 1st and the last symbols are not used
            n_scpPRB = 12;          % the number of subcarriers in the frequency domain per PRB
            b_symbol_m = Qm;        % number of bits per symbol
            DR = NbitsHz * phyParams.BwMHz;  % [Mbps]

            % calculate transmission range by winner+ model
            
            prh = gammaMin_dB * phyParams.noisefloor;
            hBS= 1.5 ;
            hMS = 1.5;

            TR4 = 10*phyParams.Ptx*(hBS*hMS)^(16.2/10)*(1/(5.9*10^9))^(3.8/10)/(9*prh);
            TR = TR4^(1/4);

            
            fprintf("%d\t\t%.3f\t%.2f\t\t%d\t\t%.2f\t\t\t%.2f\n", MCS_NR, CR, DR, nRB_b, gammaMin_dB,TR);
        catch exception
            
        end
    end
end
