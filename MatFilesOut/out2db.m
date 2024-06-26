function out2db(simValues,outputValues,appParams,simParams,phyParams,sinrManagement,outParams,stationManagement)
%OUT2DB write params into database
%   Detailed explanation goes here

% copy params
if isfield(phyParams, "RawMax11p")
    params.RawMax11p = phyParams.RawMax11p;
end

if isfield(phyParams, "RawMaxCV2X")
    params.RawMaxCV2X = phyParams.RawMaxCV2X;
end

% invert into a table
paramsTable = struct2table(params);

tablename = "ParamsInSim";
sqlwrite(outParams.conn,tablename,paramsTable);
end

