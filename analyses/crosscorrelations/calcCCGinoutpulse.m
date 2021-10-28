function [ccginout] = calcCCGinoutpulse(basepath, spikes, pulseEpochs, varargin)

%
%       USAGE
%
%
%       Dependencies
%
%
%
%       INPUTS
%       basepath
%       spikes
%       pulseEpochs
%       
%       Name-Value Pairs
%       'basename'
%       'saveMat' 
%       'binSize'
%       'duration'
%       'normalization'
%
%       OUTPUTS 
%
%
%       EXAMPLE
%       [ccginout] = calcCCGinoutpulse(basepath, spikes, optoStim.timestamps)
%
%       HISTORY
%
%
%       TO-DO
%       Doesnt work with CellExplorer in path, because it also has a CCG
%       that's different from the one inb buzcode
%
%

%% Parse! 

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);
sessionInfo = bz_getSessionInfo;
Fs = sessionInfo.rates.wideband;

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',false,@islogical);
addParameter(p,'saveAs','.ccginout.analysis.mat',@islogical);
addParameter(p,'binSize',0.001,@isnumeric);
addParameter(p,'duration',0.2,@isnumeric);
addParameter(p,'normalization','rate',@isstr);


parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
saveAs          = p.Results.saveAs;
normalization   = p.Results.normalization;
duration       = p.Results.duration;
binSize        = p.Results.binSize;

cd(basepath)


%%
[status_pulse ,~ ] = cellfun(@(a) InIntervals(a,pulseEpochs), spikes.times,'uni', false);

for iUnit = 1:length(spikes.times)
    spkTimIN{iUnit}   = spikes.times{iUnit}(status_pulse{iUnit});
    spkTimOUT{iUnit}   = spikes.times{iUnit}(~status_pulse{iUnit});
end

[ccgIN,t]   = CCG(spkTimIN,[],'Fs',Fs, 'binSize',binSize,'duration', duration, 'norm', normalization);
[ccgOUT,t]  = CCG(spkTimOUT,[],'Fs',Fs, 'binSize',binSize,'duration', duration, 'norm', normalization);

ccginout.ccgIN      = ccgIN;
ccginout.ccgOUT     = ccgOUT;
ccginout.t          = t;
ccginout.binSize    = binSize;
ccginout.duration   = duration;
ccginout.normalization = normalization; 

if saveMat
    save([basename saveAs],'ccginout')
end
end
