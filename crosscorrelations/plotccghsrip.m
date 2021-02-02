figure, 
for iUnit = find(INTIndx)
    figure
   set(gcf,'Position',[50 50 1200 800]);
set(gcf,'PaperOrientation','landscape');

% set(gcf,'Position',[1 41 1920 963])
    plotCount = 0;
    for i=find(~INTIndx)%length(spikes.times) 
        plotCount = plotCount +1;
        subplot(ceil(sqrt(length(spikes.times))),ceil(sqrt(length(spikes.times))),plotCount),
        
        
        b1= bar(t,ccgHSRip(:,iUnit,i),''); 
        b1.FaceAlpha = 0.75;

        hold on, 
        b2 = bar(t,ccgHSnoRip(:,iUnit,i));
        b2.FaceAlpha = 0.75;


        
%         end
    end
    l1 = legend({'HS During Ripples','HS Outside Ripples'});
        set(l1,'Position',[0.2241 0.1189 0.12501 0.0550])
%   savefig(gcf,['ccgI2P_ripnorip_unit' num2str(iUnit) '.fig'])
%   print(gcf,['ccgI2P_ripnorip_unit' num2str(iUnit) '.pdf'],'-dpdf', '-fillpage')
% %  pause
 close
end