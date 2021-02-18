function plotccg(ccgRip, ccgHIS, ccgLIS, t, INTIndx, spikes, opts)

figure,
for iUnit = find(INTIndx)
    fig = figure;

    set(gcf,'Position',[50 50 1200 800]);
    set(gcf,'PaperOrientation','landscape');
    plotCount = 0;
    
    for i=find(~INTIndx)
        plotCount = plotCount +1;
        subplot(ceil(sqrt(length(spikes.times))),ceil(sqrt(length(spikes.times))),plotCount),
        
        b3 = bar(t,ccgRip(:,iUnit,i));
        b3.FaceAlpha = 0.75;
        b3.EdgeColor = 'none';
        b3.BarWidth = 0.9;
        hold on
        
        b1= bar(t,ccgHIS(:,iUnit,i),'');
        b1.FaceAlpha = 0.75;
        b1.EdgeColor = 'none';
        b1.BarWidth =0.9;
        
        hold on,
        b2 = bar(t,ccgLIS(:,iUnit,i));
        b2.FaceAlpha = 0.75;
        b2.EdgeColor = 'none';
        b2.BarWidth = 0.9;
        
        box off

        
    end
    
    
    
    l1 = legend({'During Ripples','During High Synchrony','During Low Synchrony'});
    set(l1,'Position',[0.2241 0.1189 0.12501 0.0550])
    
    han = axes(fig,'visible','off');
    han.Title.Visible = 'on';
    han.XLabel.Visible = 'on';
    han.YLabel.Visible = 'on';
    ylabel(han,'Count')
    xlabel(han,'time (s)')
    title(han,[{['CCG INT to PYR of Unit ' num2str(iUnit) ' Binsize CCG = ' num2str(opts.ccgBinSize) ' minSyncI = ' num2str(opts.numsyncneurons)]}]')
    
    
    %
    %   savefig(gcf,['ccgI2P_unit' num2str(iUnit) '.fig'])
    %   print(gcf,['ccgI2P_unit' num2str(iUnit) '.pdf'],'-dpdf', '-fillpage')
    %  pause
    %  close
end