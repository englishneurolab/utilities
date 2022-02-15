for iUnit = 1:length(spikes.UID)
figure,plot(SpkVoltage{iUnit},SpkTime{iUnit},'.')
xlabel('voltage wheel')
ylabel('time')
title(['Unit ' num2str(iUnit)])
ax = gca;
ax.YDir = 'reverse';
% set(gcf,'Position',[1000 330 560 1008])
% print(gcf, ['Unit_' num2str(iUnit) '_SpkPerVoltage.pdf'],'-dpdf')
% close
end
%%
for iUnit = 1:length(spikes.UID);
figure,plot(SpkVoltage{iUnit},VelocityatSpk{iUnit},'.')
xlabel('voltage wheel')
ylabel('time')
title(['Unit ' num2str(iUnit)])
ax = gca;
ax.YDir = 'reverse';
% set(gcf,'Position',[1000 330 560 1008])
% print(gcf, ['Unit_' num2str(iUnit) '_VelocityVoltage.pdf'],'-dpdf')
% close
end


%% Exclude times of slow trials