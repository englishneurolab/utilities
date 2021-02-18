function [PowerPhaseRatemap,spikebinIDs] = bz_PowerPhaseRatemap_sam(spikes,filteredLFP,varargin)
%[PowerPhaseRatemap,spikebinIDs] = bz_PowerPhaseRatemap(spikes,filteredLFP,varargin)
%
% INPUTS
%   spikes          structure containing spikes.times from bz_getSpikes
%   filteredLFP     structure containing filteredLFP.timestamps, 
%                       filteredLFP.amp, filteredLFP.phase,
%                       filteredLFP.samplingRate. from bz_Filter(lfp).
% 
%  (options)
%   'ints'
%   'powernorm'     (default: 'modZ')
%   'ratenorm'      (default: 'none')
%   'numbins'        BINNING THE SPIKES , TO CALCULATE PER FREQUENCY (default: 20)
%   'metric'        if you would like to calculate average of some other
%                   metric (i.e. not rate) as function of power/phase
%                   should be cell array (similar to spikes) with value of
%                   other metric for each spike
%   'Nspikethresh'  number of spikes threshold to count mean metric
%                   (default: 10)
%
%OUTPUTS
%   PowerPhaseRatemap
%   spikebinIDs
%
% HISTORY
% DLevenstein 2018
% 2020/12/08 Lianne made this compatible with getPhaseMap
%% DEV
p = inputParser;
addParameter(p,'ints',[0 Inf],@isnumeric)
addParameter(p,'powernorm','Zlog')
addParameter(p,'metric',[])
addParameter(p,'Nspikethresh',10)
addParameter(p,'jittersig',false,@islogical)
addParameter(p,'cellsToJitter',spikes.UID,@isnumeric)
addParameter(p,'numbins',20,@isnumeric)

parse(p,varargin{:})
ints = p.Results.ints;
powernorm = p.Results.powernorm;
metric = p.Results.metric;
Nspikethresh = p.Results.Nspikethresh;
jittersig = p.Results.jittersig;
cellsToJitter = p.Results.cellsToJitter;
numbins = p.Results.numbins;

%% Find lfp and spikes in the intervals
instatespiketimes = cellfun(@(X) InIntervals(X,ints),...
    spikes.times,'UniformOutput',false);
instateLFPtimes = InIntervals(filteredLFP.timestamps,ints);

%%
numcells = length(spikes.times);
%%

%Normalize Power
switch powernorm
    case 'Zlog'
        filteredLFP.amp = NormToInt(log10(filteredLFP.amp),'Z',ints,filteredLFP.samplingRate);
end

%%

%Get Power/Phase at each spike
spikes.amp = cellfun(@(X) interp1(filteredLFP.timestamps,filteredLFP.amp,X,'nearest'),...
    spikes.times,'uniformoutput',false);
spikes.phase = cellfun(@(X) interp1(filteredLFP.timestamps,filteredLFP.phase,X,'nearest'),...
    spikes.times,'uniformoutput',false);

%%

%Power/Phase Bins
phaseedges = linspace(-pi,pi,numbins+1);
PowerPhaseRatemap.phasebins=phaseedges(1:end-1)+0.5.*diff(phaseedges(1:2));
poweredges = linspace(-1.8,1.8,numbins+1); % is this 1.8 hardcoded for old data?? LK
PowerPhaseRatemap.powerbins=poweredges(1:end-1)+0.5.*diff(poweredges(1:2));
poweredges(1) = -Inf; poweredges(end) = Inf;

%Calculate Power/Phase Spike Histogram
%phaseamphist = cellfun(@(X,Y) hist3([X,Y],{powerbins,phasebins}),spikeamp,spikephase,'UniformOutput',false);

[PowerPhaseRatemap.Nspikes,~,~,spikebinIDs.powerbin,spikebinIDs.phasebin] = ...
    cellfun(@(X,Y,Z) histcounts2(X(Z),Y(Z),poweredges,phaseedges),...
    spikes.amp,spikes.phase,instatespiketimes,...
    'UniformOutput',false);

%Calculate Power/Phase Time Histogram
%phaseamphist_t = hist3([t_amp,t_phase],{powerbins,phasebins});
%phaseamphist_t = phaseamphist_t./sf_LFP;

PowerPhaseRatemap.occupancy = ...
    histcounts2(filteredLFP.amp(instateLFPtimes),...
    filteredLFP.phase(instateLFPtimes),poweredges,phaseedges);
PowerPhaseRatemap.occupancy = ...
    PowerPhaseRatemap.occupancy./filteredLFP.sampleRate;
PowerPhaseRatemap.powerdist = sum(PowerPhaseRatemap.occupancy,2);

%Normalize Rate
%totaltime = sum(diff(ints,1,2));
%meanrate = cellfun(@(X) length(X)./totaltime,spiketimes,'UniformOutput',false);
PowerPhaseRatemap.ratemap = cellfun(@(X) X./PowerPhaseRatemap.occupancy,...
    PowerPhaseRatemap.Nspikes,'UniformOutput',false);
%phaseamprate = cellfun(@(X,Y) X./Y,phaseamprate,meanrate,'UniformOutput',false);

PowerPhaseRatemap.meanrate = nanmean(cat(3,PowerPhaseRatemap.ratemap{:}),3);

if ~isempty(metric)
    for po = 1:length(PowerPhaseRatemap.powerbins)
        for ph = 1:length(PowerPhaseRatemap.phasebins)

            %Find the spikes in the right bin
            inbinspikes = cellfun(@(X,Y,Z) X==po & Y==ph ,...
                spikebinIDs.powerbin,spikebinIDs.phasebin,...
                'UniformOutput',false);
            
            %Find the metric from spikes in the state
            instatmetric = cellfun(@(X,Y) X(Y),metric,instatespiketimes,...
                'UniformOutput',false);

            %Map for each cell
            for cc = 1:numcells
                PowerPhaseRatemap.metricmap{cc}(po,ph) = ...
                    nanmean(instatmetric{cc}(inbinspikes{cc}));
                
                 %Threshold.
                if sum(inbinspikes{cc}) < Nspikethresh
                    PowerPhaseRatemap.metricmap{cc}(po,ph) = nan;
                end
            end

        end
    end
    
	PowerPhaseRatemap.meanmetric = nanmean(cat(3,PowerPhaseRatemap.metricmap{:}),3);

end

% Compute power-dependent phase coupling for each unit
prefangle = zeros(numcells,numbins);
powerskew = zeros(numcells,numbins);
for ii = 1:numcells
    % Treat each amplitude bin separately
    for jj = 1:numbins
        rvect = nanmean(spikes.amp{ii}(spikebinIDs.powerbin{ii} == jj).*exp(1i .* spikes.phase{ii}(spikebinIDs.powerbin{ii} == jj)), 1);
        powerskew(ii, jj) = abs(rvect);
        prefangle(ii, jj) = angle(rvect);
    end
end
PowerPhaseRatemap.powerskew = powerskew;
PowerPhaseRatemap.prefangle = prefangle;

if jittersig
    numjitt = 100;
    % Jitter in window so that phases are randomized, but amplitudes preserved
    jitterwin = 2 ./ filteredLFP.filterparms.passband(1);
    jitterbuffer = zeros(length(cellsToJitter),numbins, numjitt);
    for jitnum = 1:numjitt
        jitterspikes = JitterSpiketimes(spikes.times(cellsToJitter),jitterwin);
        % Get Power/Phase at each spike
        amp = cellfun(@(X) interp1(filteredLFP.timestamps,filteredLFP.amp,X,'nearest'),jitterspikes,'uniformoutput',false);
        phase = cellfun(@(X) interp1(filteredLFP.timestamps,filteredLFP.phase,X,'nearest'),jitterspikes,'uniformoutput',false);
        % Bin jittered spikes according to phase and amplotude 
        [~,~,~,powerbin,~] = cellfun(@(X,Y,Z) histcounts2(X(Z),Y(Z),poweredges,phaseedges),...
                                    amp, phase, instatespiketimes(cellsToJitter), 'UniformOutput',false);
        powerskew = zeros(length(cellsToJitter), numbins);                        
        for ii = 1:length(cellsToJitter)
            % Treat each amplitude bin separately
            for jj = 1:numbins
                rvect = nanmean(amp{ii}(powerbin{ii} == jj).*exp(1i .* phase{ii}(powerbin{ii} == jj)), 1);
                powerskew(ii, jj) = abs(rvect);
            end
        end
        jitterbuffer(:,:,jitnum) = powerskew;
    end
    jittermean = mean(jitterbuffer,3);
    jitterstd = std(jitterbuffer,[],3); 
    PowerPhaseRatemap.spikephasesig = (PowerPhaseRatemap.powerskew(cellsToJitter,:)-jittermean)./jitterstd;
    
end

%%
% % excell = randsample(spikes.numcells,1);
% figure
% % subplot(2,2,1)
% %     imagesc(PowerPhaseRatemap.phasebins,PowerPhaseRatemap.powerbins,...
% %         PowerPhaseRatemap.ratemap{excell})
% %     hold on
% %     imagesc(PowerPhaseRatemap.phasebins+2*pi,PowerPhaseRatemap.powerbins,...
% %         PowerPhaseRatemap.ratemap{excell})
% %     xlim([-pi 3*pi])
% %     axis xy
% %     colorbar
%     
% subplot(2,2,1)
%     imagesc(PowerPhaseRatemap.phasebins,PowerPhaseRatemap.powerbins,...
%         PowerPhaseRatemap.meanrate)
%     hold on
%     imagesc(PowerPhaseRatemap.phasebins+2*pi,PowerPhaseRatemap.powerbins,...
%         PowerPhaseRatemap.meanrate)
%     plot(linspace(-pi,3*pi,100),cos(linspace(-pi,3*pi,100)),'k')
%     xlim([-pi 3*pi])
%     axis xy
%     colorbar  
%     xlabel('Phase');
%     ylabel('Power (Z(log))')
%     
% subplot(2,2,3)
%     bar(PowerPhaseRatemap.powerbins,PowerPhaseRatemap.powerdist)
%     xlabel('Power (Z(log))');ylabel('Time (s)')
%     box off
%     axis tight
%     
% if ~isempty(metric)
%     subplot(2,2,2)
%         h = imagesc(PowerPhaseRatemap.phasebins,PowerPhaseRatemap.powerbins,...
%             PowerPhaseRatemap.meanmetric);
%         hold on
%         h2 = imagesc(PowerPhaseRatemap.phasebins+2*pi,PowerPhaseRatemap.powerbins,...
%             PowerPhaseRatemap.meanmetric);
%         set(h,'AlphaData',~isnan(PowerPhaseRatemap.meanmetric));
%         set(h2,'AlphaData',~isnan(PowerPhaseRatemap.meanmetric));
%         plot(linspace(-pi,3*pi,100),cos(linspace(-pi,3*pi,100)),'k')
%         xlim([-pi 3*pi])
%         axis xy
%         colorbar  
%         xlabel('Phase');
%         ylabel('Power (Z(log))')
% end

end
