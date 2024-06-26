function Pa = cal_awarenessProbability(PRP, RxTimes, duration, TxInterval)
%CAL_AWARENESSPROBABILITY get awareness probability from PRP
%   PRP: packet receptioin ratio
%   RxTimes: the times of packets that the tagged vehicle received
%   successfully
%   duration: [s], the time duration within which the Pa would be calculated
%   TxInterval: [s], transmission time interval or packet generation time
%   interval
n = floor(duration/TxInterval);
Pa = zeros(length(PRP), 1);  % init

for k = RxTimes:1:n
    Pa = Pa + nchoosek(n, k) .* PRP.^k .* (1-PRP).^(n-k);
end
