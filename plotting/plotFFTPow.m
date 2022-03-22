function plotLFPPow(lfpPow)
%
% This function is meant to plot the output from the getFFTPow function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Dependencies
%    - Buzcode
%    - Cell Explorer
%    - lfp file
%    - session file from cell explorer
%    - getFFTPow function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input
%    - lfpPow - Output from the getFFTPow function that power for
%               different frequency bands
%
%%%Options%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output
%    - Plots for lfp power for different freq bands
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Usage
%    - plotFFTPow(lfpPow)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Todos
%    - Iron out the actual way I want to plot these things
%    - Fix color soft coding
%    - Add way to omit bad channels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% History
% - (2021/05/03) Code written by Kaiser Arndt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load files
basename = bz_BasenameFromBasepath(cd)



load([basename '.session.mat'])


if ~isempty(session.channelTags.Bad.channels)
    badChans = ismember(cell2mat(session.extracellular.electrodeGroups.channels), session.channelTags.Bad.channels);
    
    chans = setxor(cell2mat(session.extracellular.electrodeGroups.channels), session.channelTags.Bad.channels);
else
    chans = session.extracellular.electrodeGroups.channels{1};
    
end


%% 

colors = ['b';'g';'r';'c';'m';'y';'k'];

%% Plot total anatomical spectrigram (set ==250 or ==500)

figure
if exist('badChans')
    imagesc(lfpPow.pow(1:find(lfpPow.freqs == 250),~badChans)')
else
    imagesc(lfpPow.pow(1:find(lfpPow.freqs == 250),:)')
end
hold on
title('Frequency power across anatomical channels')

ylabel('Channels')
set(gca, 'YTick', 1:length(chans))
yticklabels([chans])

xlabel('Frequency (Hz)')
set(gca, 'XTick', 1:100000:find(lfpPow.freqs == 250))
xticklabels([round(lfpPow.freqs(1:100000:find(lfpPow.freqs == 250)))])

colormap('Jet')

hold off
%% Plot avg power of freq bins across channels

figure

for i = 1:length(lfpPow.freqBands)
    shadedErrorBar(1:length(lfpPow.channels),lfpPow.powBands{i},{@mean,@std},'lineProps',{[colors(i)],'markerfacecolor',[1,.2,.2]})
    hold on 
end
legend(num2str(lfpPow.freqBands))
view([90 -90])
set(gca, 'XDir','reverse')
% %%
% figure
% for i = 1:length(lfpPow.freqBands)
%     plot(lfpPow.avgPow(i,:),colors(i))
%     hold on 
% end
% legend(num2str(lfpPow.freqBands))
% view([90 -90])
% set(gca, 'XDir','reverse')
% %% 
% figure
% hold on
% for i = 1:length(layers)
%     plot(mean(lfpPow.golayfilt(layers{i},:)), 'DisplayName', ['Layer' layerNum{i}])
% end
% 
% legend
% 
% set(gca, 'XTick', 1:100000:find(lfpPow.freqs == passband(2)))
% set(gca, 'XTickLabel', lfpPow.freqs(1:100000:find(lfpPow.freqs == passband(2))))
% set(gca, 'XLim', [0 find(lfpPow.freqs == passband(2))])