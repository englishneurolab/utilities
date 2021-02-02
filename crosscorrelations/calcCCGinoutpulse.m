function [ccginout,t] = calcCCGinoutpulse(basepath, spikes, pulseEpochs, varargin)

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
%       HISTORY
%
%
%       TO-DO


%% Parse! 

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);
sessionInfo = bz_getSessionInfo;
Fs = sessionInfo.rates.wideband;

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'binSize',0.001,@isnumeric);
addParameter(p,'duration',0.2,@isnumeric);
addParameter(p,'normalization','rate',@isstr);


parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
normalization   = p.Results.normalization;
duration       = p.Results.duration;
binSize        = p.Results.binSize;

cd(basepath)


%%
[status_pulse ,~ , ~ ] = cellfun(@(a) InIntervals(a,pulseEpochs), spikes.times,'UniformOutput', false);

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


end
    