function [ccginout] = getCCGinout(basepath, spikes, epochs, varargin)

%
%       USAGE
%
%
%       Dependencies
%       Buzcode
%
%
%       INPUTS
%       basepath            -
%       epochs              - epochs to calculate CCG "in" and "out" of the epoch over
%
%       Name-Value Pairs
%       'basename'          - basename
%       'saveMat'           - do you want to store ccginout (default:'true')
%       'binSize'           - in seconds (default: 0.001)
%       'duration'          - of total CCG in seconds (default, 0.2)
%       'normalization'     - 'rate' or 'count' (default: 'rate')

%       OUTPUTS
%       ccginout
%         .ccgIN
%         .ccgOUT
%         .t
%         .binSize
%         .duration
%         .normalization
%
%
%       EXAMPLES
%       [ccginout] = getCCGinout(basepath, spikes, pulseEpochs)
%
%
%       HISTORY
%       2021-01   Lianne documented this code
%
%       TO-DO
%       - Option to run it over a subset of clusters?
%       - Move all parameters to .ccgparams.[var]


%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename    = bz_BasenameFromBasepath(basepath);
sessionInfo = bz_getSessionInfo;
Fs          = sessionInfo.rates.wideband;

p = inputParser;
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'binSize',0.001,@isnumeric);
addParameter(p,'duration',0.2,@isnumeric);
addParameter(p,'normalization','rate',@isstr);


parse(p,varargin{:});
saveMat         = p.Results.saveMat;
normalization   = p.Results.normalization;
duration        = p.Results.duration;
binSize         = p.Results.binSize;

cd(basepath)

%%

% Load in the spikes
%spikes = bz_LoadPhy;- reagan commented out 5.3.21

if ~isempty(epochs)
    % Get spikes in or out epoch
    [status_pulse ,~ , ~ ] = cellfun(@(a) InIntervals(a,epochs), spikes.times,'UniformOutput', false);
    
    for iUnit = 1:length(spikes.times)
        spkTimIN{iUnit}   = spikes.times{iUnit}(status_pulse{iUnit});
        spkTimOUT{iUnit}   = spikes.times{iUnit}(~status_pulse{iUnit});
    end
    
    
    % Calculate CCGs
    
    [ccgIN,t]   = CCG(spkTimIN,[],'Fs',Fs, 'binSize',binSize,'duration', duration, 'norm', normalization);
else
    spkTimOUT = spikes.times;
end

[ccgOUT,t]  = CCG(spkTimOUT,[],'Fs',Fs, 'binSize',binSize,'duration', duration, 'norm', normalization);


% Store variables into struct
if ~isempty(epochs)
    ccginout.ccgIN      = ccgIN;
else 
    ccginout.ccgIN = {'no epochs specified'};
end

ccginout.ccgOUT     = ccgOUT;
ccginout.t          = t;
ccginout.binSize    = binSize;
ccginout.duration   = duration;
ccginout.normalization = normalization;

if saveMat
    save([basename '.ccginout.mat'],'ccginout')
end



end
