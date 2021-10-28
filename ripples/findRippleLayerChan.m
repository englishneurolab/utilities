function [peakRipChan] = findRippleLayerChan(basepath,varargin)

% This function is designed to find the center of the pyramidal layer,
% based on the largest amplitude of the ripple. 
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
%   'selRipples' -
%
%   OUTPUTS
%
%
%   EXAMPLE
%   [peakRipChan] = findRippleLayerChan(basepath, 'selRipples',selRipples)
%
%
%
%   HISTORY
%   2021/02 Lianne rebuilt this function after it sadly dissapeared
%
%
%   TO-DO
%   - Calculate this per Anatom Group (Shank)
%
%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

selRipplesValidation = @(x) isnumeric(x) || strcmp(x,'all');

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'saveAs','.peakRipChan.chaninfo.mat',@ischar)
addParameter(p,'selRipples','all',selRipplesValidation);
addParameter(p,'bpFreq',[100 250],@isnumeric)

parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
selRipples      = p.Results.selRipples;
bpFreq          = p.Results.bpFreq;
saveAs          = p.Results.saveAs;

cd(basepath)

%% Load in variables
% Load LFP
lfp = bz_GetLFP('all');

% Load Ripples
load([basename '.ripples.events.mat'],'ripples')

%% Get right LFP snippets
% GetLFP ripple Snippets

if strcmpi(selRipples,'all')
    selRipples = 1:length(ripples.timestamps);
end

for iChan = 1:length(lfp.channels)
    selChanLFP = lfp.data(:,iChan);
    selChanLFPbp = bandpass(double(selChanLFP),bpFreq,lfp.samplingRate);
    ripCount = 0;
    for iRip = selRipples
        ripCount = ripCount + 1;
        ripStartInd = find(lfp.timestamps == ripples.timestamps(iRip,1));
        ripStopInd = find(lfp.timestamps == ripples.timestamps(iRip,2));
        ripSnip{iChan}{ripCount} = selChanLFPbp(ripStartInd:ripStopInd);
        
        % Within snippet find max amplitude per channel
        [pkVal,pkInd] = findpeaks(ripSnip{iChan}{ripCount});
        [pkValmaxVal(iChan,ripCount), pkValmaxIndInd] = max(pkVal);
        [pkValmaxInd(iChan,ripCount)] = pkInd(pkValmaxIndInd);
    end
    
end

%% find max

[v,i] = max(pkValmaxVal); %
i = i-1; %0based
figure
histogram(i)
channelRip = mode(i);
%
peakRipChan.channelOriginal = ripples.detectorinfo.detectionchannel; % 0based
peakRipChan.channel = channelRip; %0based
peakRipChan.pkVal = v;
peakRipChan.pkInd = i;
peakRipChan.ripSnip = ripSnip;

%% And save
if saveMat
    save([basename saveAs],'peakRipChan')
end
end
