function [SpkVoltage, SpkTime, VelocityatSpk] = rastersToVoltage(analogin, spikes)
%% spike rasters over voltage wheel
tic
pos = analogin.pos;
ts = analogin.ts; % in sec
vel = diff([nan pos]);
%

for iUnit = 1:length(spikes.UID)
    allSpkIdx = [];
    selSpikesTimes = spikes.times{iUnit};
    allSpkIdx = find(ismember(ts,spikes.times{iUnit}));
%     Out-of-memory-errors % see about batches, now slower option:
%     for iSpk = 1:length(selSpikesTimes)
%         spkIdx = find(ts==selSpikesTimes(iSpk));
%         allSpkIdx = [allSpkIdx spkIdx];
%     end
    
SpkVoltage{iUnit} = pos(allSpkIdx);
SpkTime{iUnit} = ts(allSpkIdx);
VelocityatSpk{iUnit} = vel(allSpkIdx);
end



end