dirN ={
    'D:\Data\Axoaxonic_Data_Lianne\u19_200310_135409';...%3
    'D:\Data\Axoaxonic_Data_Lianne\u19_200313_120452';...%2
    'D:\Data\Axoaxonic_Data_Lianne\u19_200313_155505';...%3
};

sessionInfo = bz_getSessionInfo(cd);

params.nChans       = sessionInfo.nChannels;
params.sampFreq     = sessionInfo.rates.wideband;
params.Probe0idx    = sessionInfo.channels;
% ccg
opts.ccgBinSize  = 0.001;
opts.ccgDur      = 0.2;


for iSess = 1:length(dirN)
    cd(dirN{iSess})
    
    basename = bz_BasenameFromBasepath(cd);
    load('pulseEpochs.mat')
    load([basename '.spikes.cellinfo.mat'])
    
    % function [ccgIN, ccgOUT,t] = calcCCGinoutpulseWithShuffle(spikes, pulseEpochs, params, opts)
    [status_pulse ,~ , ~ ] = cellfun(@(a) InIntervals(a,pulseEpochs), spikes.times,'UniformOutput', false);
    [status_outpulse] = cellfun(@(a) ~a, status_pulse,'uni',false);
    for iUnit = 1:length(spikes.times)
        spikeTimesinPulse{iUnit}   = spikes.times{iUnit}(status_pulse{iUnit});
        spikeTimesoutPulse{iUnit}   = spikes.times{iUnit}(status_outpulse{iUnit});
    end
    
    [ccgIN,t]=CCG(spikeTimesinPulse,[],'Fs',params.sampFreq, 'binSize',opts.ccgBinSize,'duration', opts.ccgDur, 'norm', 'rate');
    [ccgOUT,t]=CCG(spikeTimesoutPulse,[],'Fs',params.sampFreq, 'binSize',opts.ccgBinSize,'duration', opts.ccgDur, 'norm', 'rate');
    
    for iShuff = 1:1000
        % deze shuffle klopt nu niet.%
        selSpikeTimes = spikes.times{iUnit};
        
        status_shuffIN{iUnit} = status_pulse{iUnit}(randperm(length(status_pulse{iUnit})));
        spikeTimesNullIN{iUnit} = sort(selSpikeTimes(status_shuffIN{iUnit}));
        
        
        status_shuffOUT{iUnit} = status_outpulse{iUnit}(randperm(length(status_outpulse{iUnit})));
        spikeTimesNullOUT{iUnit} = sort(selSpikeTimes(status_shuffOUT{iUnit}));
        
        [ccgNullIN{iShuff},t] = CCG(spikeTimesNullIN,[],'Fs',params.sampFreq, 'binSize',opts.ccgBinSize,'duration', opts.ccgDur, 'norm', 'rate');
        [ccgNullOUT{iShuff},t] = CCG(spikeTimesNullOUT,[],'Fs',params.sampFreq, 'binSize',opts.ccgBinSize,'duration', opts.ccgDur, 'norm', 'rate');
        
        save([basename '.ccginout.events.mat'], 'ccgIN' ,'ccgOUT','ccgNullIN','ccgNullOUT','status_pulse','status_outpulse','pulseEpochs')
    end
    
end


%%ccgStats
%%plotting:
%statsbetweenCCG
