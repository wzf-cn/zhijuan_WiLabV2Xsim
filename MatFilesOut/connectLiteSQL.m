function outParams = connectLiteSQL(outParams)
%CONNECTLITESQL connect to LiteSQL for logging results

%% Setup dbfile
dbfile = fullfile(outParams.outputFolder, sprintf("resuts_%d.db", outParams.simID));
if isfile(dbfile)
    % delete if the old database exist
    delete(dbfile);
end
outParams.conn = sqlite(dbfile,"create");


%% Create tables

% Table ParamsInSim
sqlquery = strcat("CREATE TABLE ParamsInSim(RawMax11p numeric, " + ...
    "RawMaxCV2X numeric)");
execute(outParams.conn, sqlquery);

% Table PacketStatusDetail
% [time, TxID, RxID, BRID, distance, packet_status(1:correct, 0:error)]
sqlquery = strcat("CREATE TABLE PacketStatusDetail(time numeric, ", ...
    "TxID INT, RxID INT, BRID INT, distance numeric, velocity numeric, direction INT, packet_status INT)");
execute(outParams.conn, sqlquery);

end

