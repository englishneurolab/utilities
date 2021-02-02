function [rate, count, time] = inh_rastersToPlace(spikes, trials,options)
% Rate for heatmap place

trialTimes = trials;

%%
binSize     = options.binSize; % in sec
timeEdges   = timwin(1):binSize:timwin(2);
secsTot     = timwin(2)-timwin(1);
%     secsPerBin = secsTot/numBins; % for when hist in stead of histcounts

%%
spike_toPulse = realignSpikes(spikes, trialTimes);

%%
for iUnit = 1:length(spikes.UID)
    plotSpkOffset = 0;
    
    for iPulse = 1:length(trials)
        spikeTrl_Pulse{iPulse} = spike_toPulse{iUnit}{iPulse} - trials(iPulse,1);
    end
    
    countHisto = histcounts(cell2mat(spikeTrl_Pulse'),timeEdges);
    rateHisto   = countHisto/length(trials)*1/binSize; %(countHisto*secsPerBin)
    timeHisto   = 1:length(rateHisto); % fix this still
    % maybe for time something like: linspace(timwin(1),timwin(2),length(rateHisto))
    
    rate(iUnit,:)   = rateHisto;
    count(iUnit,:)  = countHisto;
    time(iUnit,:)   = timeHisto;
    
    
    %%  plot 4 panel figure
    
    if options.doPlot        
        figure
        set(gcf,'PaperOrientation','Landscape')
        set(gcf,'Position',[354 634 965 704])
        
        subplot(2,2,1)
        histogram('BinEdges',timeEdges, 'BinCounts',rateHisto)
%         hb = bar(timeHisto,rateHisto,'BarWidth',1);
        hold on
        %     ylimits = get(gca,'YLim');
        %     line([pulseEpochs(1,1)-pulseEpochs(1,1) pulseEpochs(1,1)-pulseEpochs(1,1)],[0 ylimits(2)],'Color','red')
        %     line([pulseEpochs(1,2)-pulseEpochs(1,1)pulseEpochs(1,2)-pulseEpochs(1,1)],[0 ylimits(2)],'Color','blue')
        %     getXTick = get(gca,'XTick')
        %     newXLabel = linspace(timwin(1),timwin(2),length(getXTick))
        %     set(gca,'XLabel',mat2cell(newXLabel))
        box off
        set(gca,'TickDir','out')
        title(['Unit' num2str(iUnit)])
        xlabel('time(s)')
        ylabel('spikes/s')
        
        xlim(timwin)
        %     end
        %
        subplot(2,2,3)
        for iPulse = 1:length(trials)
            selPulseTr = spikeTrl_Pulse{iPulse};
            plot(selPulseTr',repmat(plotSpkOffset,1,length(selPulseTr)),'k.');
            hold on
            plotSpkOffset = plotSpkOffset+1;
        end
        
        box off
        set(gca,'ydir','reverse')
        ylimits = get(gca,'YLim');
%         line([pulseEpochs(1,1)-pulseEpochs(1,1) pulseEpochs(1,1)-pulseEpochs(1,1)],[plotSpkOffset ylimits(2)],'Color','red')
%         line([pulseEpochs(1,2)-pulseEpochs(1,1) pulseEpochs(1,2)-pulseEpochs(1,1)],[plotSpkOffset ylimits(2)],'Color','blue')
        xlabel('time (s)')
        ylabel('trials')
        set(gca,'TickDir','out')
        ylim([ylimits(1) plotSpkOffset])
        
        subplot(2,2,2)
        plot(spikes.rawWaveform{iUnit})
        axis off
        
        subplot(2,2,4)
        bar(t,ccg(:,iUnit,iUnit),'k')
        box off
        xlabel('time (s)')
        ylabel('rate')
        set(gca,'TickDir','out')
        
        if options.doSaveFig
            
            fileName = ['PETH_Unit_' num2str(iUnit) '.pdf'];
            print(gcf, fileName, '-dpdf')
            close gcf
        end
    end
end
end

