function plotFFTPow(lfpPow)
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% History
% - (2021/05/03) Code written by Kaiser Arndt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

colors = ['b';'g';'r';'c';'m';'y';'k'];

%% plot

figure
subplot(2,1,1)
for i = 1:length(lfpPow.freqBands)
    shadedErrorBar(1:length(lfpPow.channels),lfpPow.powBands{i,:},{@mean,@std},'lineProps',{[colors(i)],'markerfacecolor',[1,.2,.2]})
    hold on 
end
legend(num2str(lfpPow.freqBands))
%%
subplot(2,1,2)
for i = 1:length(lfpPow.freqBands)
    plot(lfpPow.avgPow(i,:),colors(i))
    hold on 
end
legend(num2str(lfpPow.freqBands))

%% plot
figure
hold on
for i = 1:length(layers)
    plot(mean(lfpPow.golayfilt(layers{i},:)), 'DisplayName', ['Layer' layerNum{i}])
end

legend

set(gca, 'XTick', 1:100000:find(lfpPow.freqs == passband(2)))
set(gca, 'XTickLabel', lfpPow.freqs(1:100000:find(lfpPow.freqs == passband(2))))
set(gca, 'XLim', [0 find(lfpPow.freqs == passband(2))])