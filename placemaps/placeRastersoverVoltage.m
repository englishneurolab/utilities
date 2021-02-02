function [SpkVoltage, SpkTime] = placeRastersoverVoltage(analogin, spikes)
%% spike rasters over voltage wheel

pos = analogin.pos;
ts = analogin.ts; % in sec
%

for iUnit = 1:length(spikes.UID)
    allSpkIdx = [];
    %slow, but out-of-memory-errors % see about batches
    for iSpk = 1:length(spikes.times{iUnit})
        spkIdx = find(ts==spikes.times{iUnit}(iSpk));
        allSpkIdx{iUnit} = [allSpkIdx spkIdx];
    end
    
SpkVoltage{iUnit} = pos(allSpkIdx{iUnit});
SpkTime{iUnit} = ts(allSpkIdx{iUnit});

end



iUnit = 1;
figure,plot(SpkVoltage,SpkTime,'.')
xlabel('voltage wheel')
ylabel('time')
title(['Unit ' num2str{iUnit}])
ax = gca;
ax.YDir = 'reverse';