function aacs = getAACind(basepath, stimtype, varargin)
% This function
%
%   USAGE
%
%   Dependencies:
%
%
%   INPUTS
%   cell_metrics    - output CellExplorer
%   statsP          - p-values for each unit in spikes
%   stimType        -'INH' or 'EXC'
%   inclusionInd    - logical, preDetermined inclusion criteria
%                       (e.g. ratemod in right direction)
%
%   Name-value paired inputs:
%   alpha            - Default p = 0.01;

%
%
%   OUTPUTS
%
%
%   EXAMPLES
%
%
%   NOTES
%   Determining the AACs based off significance, inclusioncriteria (e.g.
%   rate), and putative celltype
%
%   TO-DO
%   - maybe add an session.analysisTags for Opto ChR or Arch, considering the new animals are both ChR and Arch
%   Make sure your stimType is somewhere in the metadata, to be loaded in
%   really%
%
%   HISTORY
%   2020/12/11 Lianne turned this into a well-documented function
%
%
%
%% Parse!
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'saveMat',false,@islogical);
addParameter(p,'alpha',0.01,@isnumeric);


parse(p,varargin{:});
alpha         = p.Results.alpha;
saveMat       = p.Results.saveMat;

cd(basepath)
%%
load([basename '.spikes.cellinfo.mat'])
load([basename '.optoStim.manipulation.mat'])
load([basename '.cell_metrics.cellinfo.mat'])

%% stats
if exist([basename '.dblZeta20_100_100.mat'],'file')
    load([basename '.dblZeta20_100_100.mat'])
else
    runZetaStats20_100(basepath)
end

%% ratemod in the right direction

[rate] = getRatesTrialsBaseStim(spikes, optoStim.timestamps, 'timwin', [-0.5 0.5],'binSize', 0.001,'pulsew',0.05);

baserate = rate.base;
stimrate = rate.stim;



%%
if strcmpi(stimtype,'INH') || strcmpi(stimtype,'inhibition')
    statsP    = dblZetaPArch100;    
      for iUnit= 1:length(baserate)
    inclusionInd(iUnit) = mean(stimrate{iUnit}) < mean(baserate{iUnit});
end
    
    aacs = find(...
        statsP<alpha & inclusionInd... % must be either upmodulated or downmodulated
        &  contains(cell_metrics.putativeCellType,'Interneuron')); 
  
    
elseif strcmpi(stimtype,'EXC') || strcmpi(stimtype,'excitation')
    for iUnit= 1:length(baserate)
    inclusionInd(iUnit) = mean(stimrate{iUnit}) > mean(baserate{iUnit});
end
    statsP     = dblZetaPChR100;
    aacs = find(...
        statsP<alpha & inclusionInd... % must be either upmodulated or downmodulated
        & contains(cell_metrics.putativeCellType,'Interneuron'));
    
end
end
