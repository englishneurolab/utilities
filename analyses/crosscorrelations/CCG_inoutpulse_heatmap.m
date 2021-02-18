[ccgIN, ccgOUT,t] = calcCCGinoutpulse(spikes, pulseEpochs, params, opts);
spikes = bz_LoadPhy;
%%
load('ccgINandOUT.mat')

%%
cumulccgIN = [];
cumulccgOUT = [];

for iUnit = 1:length(spikes.times)
    cumulccgIN = [cumulccgIN; squeeze(ccgIN(:,iUnit,:))'];
    cumulccgOUT = [cumulccgOUT; squeeze(ccgOUT(:,iUnit,:))'];
    
end

%%
% How to sort?
% How to normalize?

% plot All
timSize = size(cumulccgIN,2);
xt      = [1:50:timSize];
xl      = t(xt);
strxl   = string(xl);

%%

%%
midbin = median(1:size(cumulccgIN,2));
[~,iSort] =sortrows(mean(cumulccgIN(:,midbin-2:midbin+2),2),'descend');

% sorted on IN pulse activity
Cvals = [-10 10];

fig = figure;
set(gcf,'Position',[50 50 1200 800]);
set(gcf,'PaperOrientation','landscape');

subplot(1,4,1)
h1 = imagesc(zscore(cumulccgIN(iSort,:),[],2));
c1 = colorbar;
box off
title('IN pulse')
caxis([Cvals])
set(gca,'XTick', xt,'XTickLabel',strxl)

subplot(1,4,2)
h2 = imagesc(zscore(cumulccgOUT(iSort,:),[],2));
c2 = colorbar;
box off
title('OUT pulse')
caxis([Cvals])
set(gca,'XTick', xt,'XTickLabel',strxl)


subplot(1,4,3)
h3 = imagesc(zscore(cumulccgOUT(iSort,:),[],2) - zscore(cumulccgIN(iSort,:),[],2));
c3 = colorbar;
box off
title('OUT - IN')
caxis([Cvals])
set(gca,'XTick', xt,'XTickLabel',strxl)

han = axes(fig,'visible','off');
han.Title.Visible = 'on';
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
ylabel(han,'cell pairs')
xlabel(han,'time (s)')

cumulOUTminIN = cumulccgOUT-cumulccgIN;
[~,iSort4] =sortrows(mean(cumulOUTminIN(:,midbin-2:midbin+2),2),'descend');


subplot(1,4,4)
h3 = imagesc(zscore(cumulccgOUT(iSort4,:),[],2) - zscore(cumulccgIN(iSort4),[],2));
c3 = colorbar;
box off
title('OUT - IN')
caxis([Cvals])
set(gca,'XTick', xt,'XTickLabel',strxl)

han = axes(fig,'visible','off');
han.Title.Visible = 'on';
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
ylabel(han,'cell pairs')
xlabel(han,'time (s)')
suptitle({['Rate for CCGs IN and OUT pulse']})

     savefig(['CCG_INandOUT_heatmaps_zscore_4panel'])
     print(['CCG_INandOUT_heatmaps_zscore_4panel'],'-dpdf','-bestfit')
%%
cumulALL = [cumulccgIN cumulccgOUT];
figure
imagesc(zscore(cumulALL(iSort,:),[],2))
hold on
limitsy=ylim;
plot([timSize+1 timSize+1], [0 limitsy(2)])
caxis([Cvals])
colorbar
set(gca,'XTick', [xt(1:end-1) xt+xt(end)],'XTickLabel',[strxl(1:end-1);strxl])
ylabel('cellpairs')
xlabel('time (s)')
title('IN and OUT CCG')

savefig(['CCG_INandOUT_heatmaps_perunit.fig'])
     print(['CCG_INandOUT_heatmaps_zscoreperunit.pdf'],'-dpdf','-bestfit')