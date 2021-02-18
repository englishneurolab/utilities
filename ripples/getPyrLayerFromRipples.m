function pyrLayer = getPyrLayerFromRipples(basepath,varargin')

% This function is designed to
%
%   USAGE
%
%   %% Dependencies %%%
%
%   INPUTS
%   basepath    - path in which spikes and optostim structs are located
%
%   Name-value pairs:
%   'basename'  - only specify if other than basename from basepath
%   'saveMat'   - saving the results to
%   'saveAs'    - if you want another suffix for your save
%
%   OUTPUTS
%
%
%   EXAMPLE
%
%
%   HISTORY
%
%
%   TO-DO
%
%

%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);


p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);

cd(basepath)

%% Load in variables

% Load detected Ripples
load([basename '.ripples.events.mat']);
ripChanOriginal = ripples.detectorinfo.detectionchannel;

% Load channelmap
load('rez.mat');
ycoords = rez.ycoords;

%% Calculate PYR layer over ripples

%% Check if Channel is the same as determined by lamina
selRipples = [1:200, length(ripples.timestamps)-200:length(ripples.timestamps)];
[pkValmaxInd, pkIndmaxInd,ripSnip] = findRippleLayerChan(basepath, 'selRipples',selRipples);

[~,r] = max(pkValmaxInd);


mode(r)
[v,i] = sort(ycoords); % 1-indexed
chanMap(i);


% Recalculate Ripples if necessary




end
