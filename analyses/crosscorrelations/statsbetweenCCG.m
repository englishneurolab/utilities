% paired T per bin?
iUnit = 1;
iPair = 3;

for iSh = 1:length(ccgNullIN)
    allNullIN(iSh,:) = ccgNullIN{iSh}(:,iUnit,iPair);
    allNullOUT(iSh,:) = ccgNullOUT{iSh}(:,iUnit,iPair);
end

significantBinsIN(:,iUnit,iPair) = ccgIN(:,iUnit,iPair)'>prctile(allNullIN,95) | ...
    ccgIN(:,iUnit,iPair)'<prctile(allNullIN,5);
significantBinsOUT(:,iUnit,iPair) = ccgOUT(:,iUnit,iPair)'>prctile(allNullOUT,95)|...
    ccgOUT(:,iUnit,iPair)'>prctile(allNullOUT,95);

timSize = size(ccgIN,2);
xt      = [1:50:timSize];
xl      = t(xt);
strxl   = string(xl);

%% plot
fig = figure;
set(gcf,'Position',[50 50 1200 800]);
set(gcf,'PaperOrientation','landscape');
subplot(1,3,1)

mO = max(max(ccgOUT(:,iUnit,iPair)));
b2=bar(mean(allNullOUT));
b2.FaceAlpha = 0.75;
b2.EdgeColor = 'none';
b2.BarWidth = 0.9;
hold on 
b1=bar(ccgOUT(:,iUnit,iPair));
b1.FaceAlpha = 0.75;
b1.EdgeColor = 'none';
b1.BarWidth = 0.9;



hold on, plot(find(significantBinsOUT(:,iUnit,iPair)),repmat(mO, 1,length(find(significantBinsOUT(:,iUnit,iPair)))),'r*')
set(gca,'XTick', xt,'XTickLabel',strxl)
axis square
box off
l1 = legend({'OUT','NullOUT'});
title('Out')


subplot(1,3,2)

mI = max(max(ccgIN(:,iUnit,iPair)));

b3=bar(ccgIN(:,iUnit,iPair));
b3.FaceAlpha = 0.75;
b3.EdgeColor = 'none';
b3.BarWidth = 0.9;

hold on
b4=bar(mean(allNullIN));
b4.FaceAlpha = 0.75;
b4.EdgeColor = 'none';
b4.BarWidth = 0.9;
hold on, plot(find(significantBinsIN(:,iUnit,iPair)),repmat(mI, 1,length(find(significantBinsIN(:,iUnit,iPair)))),'b*')
set(gca,'XTick', xt,'XTickLabel',strxl)

axis square
box off
l2 = legend({'IN','NullIN'});
title('In')

subplot(1,3,3)

b5=bar(ccgIN(:,iUnit,iPair));
b5.FaceAlpha = 0.75;
b5.EdgeColor = 'none';
b5.BarWidth = 0.9;

hold on
b5=bar(ccgOUT(:,iUnit,iPair));
b5.FaceAlpha = 0.75;
b5.EdgeColor = 'none';
b5.BarWidth = 0.9;

mM= max([mO,mI]);

[P,H] = signrank(ccgIN(:,iUnit,iPair)', ccgOUT(:,iUnit,iPair)')

text(1,mM,['p = ' num2str(P)])
l3 = legend({'IN','OUT'});
set(gca,'XTick', xt,'XTickLabel',strxl)

axis square
box off


set(l1,'Position',[0.1766    0.2114    0.1250    0.0550])
set(l2,'Position',[0.4599 0.2114    0.1250    0.0550])
set(l3,'Position',[0.7358 0.2114    0.1250    0.0550])

han = axes(fig,'visible','off');
    han.Title.Visible = 'on';
    han.XLabel.Visible = 'on';
    han.YLabel.Visible = 'on';
    ylabel(han,'Count')
%     xlabel(han,'time (s)')