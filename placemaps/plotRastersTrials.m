%% Get Voltage of each spike within a trial
% slow code - maybe make this a cellfun?

ts  = analogin.ts;
pos = analogin.pos;
%Generate spk_ep
for iUnit = 1:length(spikes.UID)
    for iTr = 1:length(tr_ep)
       [status,interval] = InIntervals(spikes.times{iUnit},tr_ep);
       spk_ep{iUnit}.trial{iTr} = spikes.times{iUnit}(interval==iTr); 
       
      % find associated voltage to each spike in the trial
      spkEpVoltIdx = find(ismember(ts,spk_ep{iUnit}.trial{iTr}));
      spkEpVoltage{iUnit}.trial{iTr} = pos(spkEpVoltIdx);
    end

end
save spkVoltage.mat

%% This actually plots rasters over trials by position

for iUnit = 1:length(spikes.UID)
       plotOffset = 0;
       figure

    for iTr = 1:length(tr_ep)
    plotOffset = plotOffset+1;
    plot(spkEpVoltage{iUnit}.trial{iTr}, ones(1,length(spkEpVoltage{iUnit}.trial{iTr}))*plotOffset,'k.')
    hold on
   
    end
    
    xlabel('Voltage')
    ylabel('Trials')
    title(['Unit ' num2str(iUnit)])
ax = gca;
ax.YDir = 'reverse';
set(gcf,'Position',[1000 330 560 1008])
print(gcf, ['SpkEpVoltage_Unit_' num2str(iUnit) '.pdf'],'-dpdf')
close
end 
    

% %% Plot spk_ep per trial
% 
% for iTr = 1:10
%     figure, plot(ts_ep{iTr},len_ep{iTr})
%     set(gcf,'Position', [555         232         497        1097])
%     plotOffset = -5;
%     
%     for iUnit = 1:length(spikes.UID)
%         
%         hold on
%         plot(spk_ep{iUnit}.trial{iTr},repmat(plotOffset,1,length(spk_ep{iUnit}.trial{iTr})),'k.');
%         plotOffset = plotOffset - 1;
%     end
% end
% 
% 
% %% Plot rasters trials per neuron per location
% 
%     for iUnit = 1:length(spikes.UID)
%         figure
%             plotOffset = -5;
% 
%         for iTr = 1:20
%         hold on
%         selSpikes = spk_ep{iUnit}.trial{iTr};
%         if ~isempty(selSpikes)
%         plot(selSpikes-selSpikes(1),repmat(plotOffset,1,length(selSpikes)),'k.');
%         end
%         plotOffset = plotOffset - 1;
%     end
% end
