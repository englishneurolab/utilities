% function 

% CCG on interneuron synchrony
% P-I ccg's plotted on I as trigger (ref)
% for each I spike count number of spikes of every other I within tim = 1,2,5,10 ms
% Reasoning is that maybe if the I synchrony is hihg, the P's will be more
% inhibited. 
% Seperate I to P CCGs on the high synchrony criteria

% Need to fix: double detected spikes when multiple I sync bins close
% together? 

% Written by Lianne Klaver 2020

params.sampFreq = 30000;
%synchrony
opts.timbinsync = 0.001; % or 0.002 , 0.005, 0.010;
opts.numsyncneurons = 3;

% ccg
opts.ccgBinSize  = 0.0001;
opts.ccgDur      = 0.03;

% get Spikes
basename = bz_BasenameFromBasepath(cd);
load([basename '.spikes.cellinfo.mat'])
load([basename '.ripples.events.mat'])

% determine interneurons 
getFSRS; % this can and should be done more elegantly than it's done now

% Determine bins with high interneuron synchrony bin entire recording in ms-bins:
alltimes = cellfun(@(a) max(a), spikes.times, 'uni', 0);
timeLastSpike = max(cell2mat(alltimes));
recordingBinEdges = 0:opts.timbinsync:timeLastSpike;

intcount = 0;

for iINT = find(INTIndx)
intcount = intcount+1;
    spkBinCount(intcount,:) = histcounts(spikes.times{iINT},recordingBinEdges);
end

sumIntSpks = sum(spkBinCount);
highSynchBins = sumIntSpks>=opts.numsyncneurons; %(arbitrary) %categorical input for CCGCond necessary)

highSynchTimes(:,1) = find(highSynchBins == 1) /1000 -0.1;
highSynchTimes(:,2) = find(highSynchBins == 1) /1000 +0.1;
% assign each spike for each unit in spike.times{iUnit} to a group (high
% synchrony bin or no high synchrony bin) %groups{#} same as spikes{#}

[spikesDuringHighSynch ,~ , ~ ] = cellfun(@(a) InIntervals(a,highSynchTimes), spikes.times,'UniformOutput', false);
[status_ripple ,~ , ~ ] = cellfun(@(a) InIntervals(a,ripples.timestamps), spikes.times,'UniformOutput', false);

Rip_spikes  = cell(1,length(spikes.times));
HS_spikes   = cell(1,length(spikes.times));
LS_spikes   = cell(1,length(spikes.times));

for iUnit = 1:length(spikes.times)
    Rip_spikes{iUnit}   = spikes.times{iUnit}(status_ripple{iUnit});
    HS_spikes{iUnit}    = spikes.times{iUnit}(spikesDuringHighSynch{iUnit});
    LS_spikes{iUnit}    = spikes.times{iUnit}(~spikesDuringHighSynch{iUnit});
end

[ccgHIS,t] = CCG(HS_spikes,[],'Fs',params.sampFreq, 'binSize',opts.ccgBinSize,...
     'duration', opts.ccgDur, 'norm', 'rate');
[ccgLIS,t] = CCG(LS_spikes,[],'Fs',params.sampFreq, 'binSize',opts.ccgBinSize,...
    'duration', opts.ccgDur, 'norm', 'rate');
[ccgRip,t] = CCG(Rip_spikes,[],'Fs',params.sampFreq, 'binSize',opts.ccgBinSize,...
    'duration', opts.ccgDur, 'norm', 'rate');

 HSRip_Spikes   = cell(1,length(spikes.times));
 HSnoRip_Spikes = cell(1,length(spikes.times));
 
[status_hsrip ,~ , ~ ] = cellfun(@(a) InIntervals(a,ripples.timestamps), HS_spikes,'UniformOutput', false);

for iUnit = 1:length(spikes.times)
    HSRip_Spikes{iUnit}     = HS_spikes{iUnit}(status_hsrip{iUnit});
    HSnoRip_Spikes{iUnit}   = HS_spikes{iUnit}(~status_hsrip{iUnit});
end

[ccgHSRip,t] = CCG(HSRip_Spikes,[],'Fs',params.sampFreq, 'binSize',opts.ccgBinSize,...
    'duration', opts.ccgDur, 'norm', 'rate');
[ccgHSnoRip,t] = CCG(HSnoRip_Spikes,[],'Fs',params.sampFreq, 'binSize',opts.ccgBinSize,...
    'duration', opts.ccgDur, 'norm', 'rate');

% plotccg(ccgRip, ccgHIS, ccgLIS, t, INTIndx, spikes)
