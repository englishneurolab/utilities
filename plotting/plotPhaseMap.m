function plotPhaseMap(varargin)
%
% This function is meant to plot PhaseMaps output from getPhaseMap
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DEPENDENCIES
%    - buzcode
%    - utilities from English lab github
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUTS
%    spaceing - str telling the kind of spacing used in the analysis
%               (default = 'log')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% OUTPUT
%    - figure with phasemap of all cells in the session
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TODOs
%    - make input to plot specific cells
%    - make not dependent on multiple sessions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HISTORY
%    - yyyy-mm-dd code written by Lianne Klaver
%    - 2021-02-25 code made into a function by Kaiser Arndt
%% Parse

p = inputParser;
addParameter(p,'spacing','log',@isstr);

parse(p,varargin{:});
spacing = p.Results.spacing;

%% Load information
basepath = cd; 
basename = bz_BasenameFromBasepath(basepath);
load([basename '.ph_mod.mat'])

%% Plotting

figure

plotCount = 0;

SPDim = round(sqrt(size(ph_mod.ph_rate,3)));

for i = 1:size(ph_mod.ph_rate,3);
     
    plotCount = plotCount + 1 % set subplot location
    
    k = gaussian2Dfilter([10 10],[.5 .5]); % set gaussian kernel to convolve with
    
    pmVals = nanconvn((ph_mod.ph_rate(:,1:end-1,i)),k);
    %= values to plot, nfreq-1 because the values fall within those lines
    subplot(SPDim,SPDim, plotCount);
    imagesc(ph_mod.ph_bin,[],nanconvn((ph_mod.ph_rate(:,1:end-1,i)),k)...
        ,[min(linearize(ph_mod.ph_rate(:,1:end-1,i)))...
        max(linearize(ph_mod.ph_rate(:,1:end-1,i)))])
    
    % labeling
    hold on
    colormap('jet')
    plot(ph_mod.ph_bin,10+cos(ph_mod.ph_bin)*10,'w')
    set(gca,'ytick',0:10:length(ph_mod.freq),'yticklabel',round(ph_mod.freq(1:10:end)))
    set(gca,'ydir','normal')
    ylabel(['Frequency ' '(' spacing ' spacing)'])
    xlabel('Oscillation Phase')
    colorbar
    
    
end
