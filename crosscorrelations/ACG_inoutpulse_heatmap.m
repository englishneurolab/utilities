
%%
load('ccgINandOUT.mat')

%%
cumulacgIN = [];
cumulacgOUT = [];

% for iSess = 1:length(sessions)
% load('pulseEpochs.mat')
% load([basename '.spikes.cellinfo.mat']
% 
% [ccgIN, ccgOUT,t] = calcCCGinoutpulse(spikes, pulseEpochs, params, opts);
% spikes = bz_LoadPhy;



for iUnit = 1:length(spikes.times)
    % is unit included or excluded?
    % Which to include?
    % - Significant change during pulse?
    % - Min FR?
    % if included:
    for iPair = 1:length(spikes.times)
    if iUnit == iPair
        cumulacgIN = [cumulacgIN; squeeze(ccgIN(:,iUnit,iPair))'];
        cumulacgOUT = [cumulacgOUT; squeeze(ccgOUT(:,iUnit,iPair))'];
    end
    end
end
%end

%%

% How to sort?
% How to normalize?
midbin = median(1:size(cumulacgIN,2));

[~,iSortACG] =sortrows(mean(cumulacgIN(:,midbin-5:midbin+5),2),'descend');
%%
Cvals= [0 60];
% plot All
timSize = size(cumulacgIN,2);
xt      = [1:50:timSize];
xl      = t(xt);
strxl   = string(xl);

fig = figure;
set(gcf,'Position',[50 50 1200 800]);
set(gcf,'PaperOrientation','landscape');

subplot(1,3,1)
% h1 = imagesc(zscore(cumulacgIN(iSortACG,:),[],2));
h1 = imagesc((cumulacgIN(iSortACG,:)));
c1 = colorbar;
box off
title('IN pulse')
% caxis(Cvals)
set(gca,'XTick', xt,'XTickLabel',strxl)

subplot(1,3,2)
h2 = imagesc(cumulacgOUT(iSortACG,:));
c2 = colorbar;
box off
title('OUT pulse')
caxis(Cvals)
set(gca,'XTick', xt,'XTickLabel',strxl)


subplot(1,3,3)
h3 = imagesc(cumulacgOUT(iSortACG,:) - cumulacgIN(iSortACG,:));
c3 = colorbar;
box off
title('OUT - IN')
caxis([-30 30])
set(gca,'XTick', xt,'XTickLabel',strxl)

han = axes(fig,'visible','off');
han.Title.Visible = 'on';
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
ylabel(han,'cell pairs')
xlabel(han,'time (s)')

suptitle({['Rate for ACGs IN and OUT pulse']})

%     savefig(['CCG_INandOUT_heatmaps' num2str(iUnit)])

