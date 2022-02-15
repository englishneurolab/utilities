%% Plot PETH FOR sin optostim

basename = bz_BasenameFromBasepath(cd);

Lsup = spikes.shankID == 1;
L5   = spikes.shankID == 2 | spikes.shankID == 3;

LsupC = spikes.UID(Lsup);
L5C   = spikes.UID(L5);

% figure
% for i = 1:length(pulseEpochs.timestamps)
%     [peth] = getPETH_epochs(cd, 'epochs', pulseEpochs.timestamps{i},'binSize',0.001,...
%         'timwin', [-.2 .2],'saveAs',['.SH' num2str(i) '.PETH.mat']);
%     
%     
% %     subplot(2,2,i) % hard coded for number of pulse channels
% %     imagesc(peth.rate)
% %     hold on
% %     ylabel('Cells')
% %     xlabel('Time (s)')
% %     set(gca,'XTick',[1:8:length(peth.timeEdges)])
% %     set(gca,'XTickLabel',peth.timeEdges([1:8:length(peth.timeEdges)]))
% %     plot([round(length(peth.timeEdges)/2) round(length(peth.timeEdges)/2)],[0 length(peth.trials)],'k')
% %     plot([find(min(abs(peth.timeEdges - pulseEpochs.stimDur)) == abs(peth.timeEdges - pulseEpochs.stimDur))  find(min(abs(peth.timeEdges - pulseEpochs.stimDur)) == abs(peth.timeEdges - pulseEpochs.stimDur))],...
% %         [0 length(peth.trials)],'k')
% end
PETHSpikesSupIN = bz_PETH_Spikes(HFOs.inPul.peaks,'cellnums', LsupC,'secondsBefore', 0.1,...
    'secondsAfter',0.1,'binWidth', 0.001,'plotting',0);
PETHSpikesSupIN.counts = squeeze(mean(PETHSpikesSupIN.counts,1))';

PETHSpikes5IN = bz_PETH_Spikes(HFOs.inPul.peaks,'cellnums', L5C,'secondsBefore', 0.1,...
    'secondsAfter',0.1,'binWidth', 0.001,'plotting',0);
PETHSpikes5IN.counts = squeeze(mean(PETHSpikes5IN.counts,1))';

%% Plot only cells in layer 2/3 and 5 to layer 2/3 optostim


LsupT = zscore(PETHSpikesSupIN.counts,0,2);
L5T   = zscore(PETHSpikes5IN.counts,0,2);

[~,ind1] = sort(LsupT(:,round(PETHSpikesSupIN.relativeBins,3) == 0));
LsupT = LsupT(ind1,:);

[~,ind2] = sort(L5T(:,round(PETHSpikes5IN.relativeBins,3) == 0));
L5T = L5T(ind2,:);

%%

figure
subplot(2,2,1)
imagesc(LsupT)
hold on
title('L2/3 cell response to L2/3 optostim')
ylabel('Cells')
xlabel('Time (s)')
set(gca,'YTick', 1:length(LsupC))
set(gca,'YTickLabel', LsupC(ind1))
set(gca,'XTick',[1:10:length(PETHSpikesSupIN.relativeBins)])
set(gca,'XTickLabel',PETHSpikesSupIN.relativeBins([1:10:length(PETHSpikesSupIN.relativeBins)]))
% plot([round(length(peth.timeEdges)/2) round(length(peth.timeEdges)/2)],[0 length(peth.trials)],'k')
% plot([find(min(abs(peth.timeEdges - pulseEpochs.stimDur)) == abs(peth.timeEdges - pulseEpochs.stimDur))  find(min(abs(peth.timeEdges - pulseEpochs.stimDur)) == abs(peth.timeEdges - pulseEpochs.stimDur))],...
%     [0 length(peth.trials)],'k')



subplot(2,2,3)
imagesc(L5T)
hold on
title('L5 cell response to L2/3 optostim')
ylabel('Cells')
xlabel('Time (s)')
set(gca,'YTick', 1:length(L5C))
set(gca,'YTickLabel', L5C(ind2))
set(gca,'XTick',[1:10:length(PETHSpikes5IN.relativeBins)])
set(gca,'XTickLabel',PETHSpikes5IN.relativeBins([1:10:length(PETHSpikes5IN.relativeBins)]))
% plot([round(length(peth.timeEdges)/2) round(length(peth.timeEdges)/2)],[0 length(peth.trials)],'k')
% plot([find(min(abs(peth.timeEdges - pulseEpochs.stimDur)) == abs(peth.timeEdges - pulseEpochs.stimDur))  find(min(abs(peth.timeEdges - pulseEpochs.stimDur)) == abs(peth.timeEdges - pulseEpochs.stimDur))],...
%     [0 length(peth.trials)],'k')


% %% Plot PETH for HFOs outside optostim this is centered on start
% 
% [peth] = getPETH_epochs(cd, 'epochs', HFOs.outPul.timestamps,'saveAs',['.HFOoutPul.PETH.mat']);
% 
% 
% LsupHFO = peth.rate(Lsup,:);
% L5HFO   = peth.rate(L5,:);
% 
% 
% subplot(2,2,2)
% imagesc(zscore(LsupHFO,0,2))
% hold on
% title('L2/3 cell response to natural HFOs')
% ylabel('Cells')
% xlabel('Time (s)')
% set(gca,'YTick', 1:length(LsupC))
% set(gca,'YTickLabel', LsupC(ind1))
% set(gca,'XTick',[1:8:length(peth.timeEdges)])
% set(gca,'XTickLabel',peth.timeEdges([1:8:length(peth.timeEdges)]))
% 
% 
% 
% 
% subplot(2,2,4)
% imagesc(zscore(L5HFO,0,2))
% hold on
% title('L5 cell response to natural HFOs')
% ylabel('Cells')
% xlabel('Time (s)')
% set(gca,'YTick', 1:length(L5C))
% set(gca,'YTickLabel', L5C(ind2))
% set(gca,'XTick',[1:8:length(peth.timeEdges)])
% set(gca,'XTickLabel',peth.timeEdges([1:8:length(peth.timeEdges)]))

%% Plot PETH for HFOs outside optostim this is for centered on peak

PETHSpikesSup = bz_PETH_Spikes(HFOs.outPul.peaks,'cellnums', LsupC,'secondsBefore', 0.1,...
    'secondsAfter',0.2,'binWidth', 0.001,'plotting',0);
PETHSpikesSup.counts = squeeze(mean(PETHSpikesSup.counts,1));


PETHSpikes5 = bz_PETH_Spikes(HFOs.outPul.peaks,'cellnums', L5C,'secondsBefore', 0.4,...
    'secondsAfter',0.1,'binWidth', 0.001,'plotting',0);
PETHSpikes5.counts = squeeze(mean(PETHSpikes5.counts,1));

%%

subplot(2,2,2)
imagesc(zscore(PETHSpikesSup.counts,0,2)')
hold on
title('L2/3 cell response to natural HFOs')
ylabel('Cells')
xlabel('Time (s)')
set(gca,'YTick', 1:length(LsupC))
set(gca,'YTickLabel', LsupC(ind1))
set(gca,'XTick',[1:10:length(PETHSpikesSup.relativeBins)])
set(gca,'XTickLabel',PETHSpikesSup.relativeBins([1:10:length(PETHSpikesSup.relativeBins)]))




subplot(2,2,4)
imagesc(zscore(PETHSpikes5.counts,0,2)')
hold on
title('L5 cell response to natural HFOs')
ylabel('Cells')
xlabel('Time (s)')
set(gca,'YTick', 1:length(L5C))
set(gca,'YTickLabel', L5C(ind2))
set(gca,'XTick',[1:10:length(PETHSpikes5.relativeBins)])
set(gca,'XTickLabel',PETHSpikes5.relativeBins([1:10:length(PETHSpikes5.relativeBins)]))

























