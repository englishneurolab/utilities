function [spikes_realigned] = realignSpikesLong(spikes, trl)
% Pulls spikes for each event individually, double counting spikes that 
% occur in multiple events
%
% inputs:
% spikes struct from buzcode
% trl = [Nx2] start stop of trials
% example: [spike_toPulse] = realignSpikes(spikes, trlCenteredEpoch);
spikes_realigned = cell(1,length(spikes.times));
a = mat2cell(trl,ones(size(trl,1),1),2);
for iUnit  = 1:length(spikes.times)
    [m] = cellfun(@(z) InIntervals(spikes.times{iUnit},z),a,'UniformOutput',false);
    spikes_realigned{iUnit} =  cellfun(@(z) spikes.times{iUnit}(z),m,'UniformOutput',false);
end

