function [spikes] = shanksForSpikesKS2(basepath,spikes)

% Update Shank information for Spikes
% Buzcode currently assumes 1 shank when there is no shanks.npy (this is an
% file that is omitted between KS1 and KS2. 

% This code allows you to update the shank information in your spikes
% struct, based on the information in your XML (sessionInfo)

cd(basepath)

sessionInfo = bz_getSessionInfo;

chans = zeros(length(sessionInfo.AnatGrps(1).Channels),size(sessionInfo.AnatGrps,2));
for iShank = 1:size(sessionInfo.AnatGrps,2)
chans(:,iShank) = sessionInfo.AnatGrps(iShank).Channels;
end


for iUnit = 1: length(spikes.maxWaveformCh)  % double
    selSpkChan = spikes.maxWaveformCh(iUnit);
    
[~, newShankID] = find(selSpkChan == chans);
spikes.shankID(iUnit) = newShankID;
end
