function XMLtoKS2ChanMap(basepath, varargin)

% SessionInfo via XML To KS2 ChanMap for preprocessing with Kilosort2
% Dependencies: Buzcode

% Make sure XML is up to date with bad channels and correct channel groups
% If you need to check or update your details check: bz_getSessionInfo(cd,'editGUI',true)


%  USAGE
%
%    [peth] = getPETH(basepath,<options>)
%
%  INPUTS
%    
%  Name-value paired inputs:
%    'basepath'     - folder in which XML can be found (required, Default
%                   is pwd)
%   'newMapName     - str with the output name of your channelMap (Default: chanMap_new.mat
%   'spaceX'        - distance between electrodes on each shank in the X
%   direction. Default: 20 micron
%   'spaceY'        - distance between electrodes on each shank in the Y
%   direction. Default: 20 micron
%   'spaceShank'    - distance between shanks. Default: 100 micron. 
%   'probeType'     - 'linear' or 'staggered' (default: 'linear')
%
%  OUTPUT
%
%  EXAMPLES
%    
% NOTES
% 
%
% TO-DO
%
%
% HISTORY 
% 2020/09/07     Lianne set up this function
%

%% Parse!
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'newMapName',['chanMapNew.mat'],@isstr);
addParameter(p,'spaceX',20,@isnumeric);
addParameter(p,'spaceY',20,@isnumeric);
addParameter(p,'spaceShank',100,@isnumeric);
addParameter(p,'probeType','linear',@isstr);

parse(p,varargin{:});
newMapName  = p.Results.newMapName;
spaceX      = p.Results.spaceX;
spaceY      = p.Results.spaceY;
spaceShank  = p.Results.spaceShank;
probeType   = p.Results.probeType;

%% Set parameters for shank
% This is assuming same layouts per Shank:

interElectrodeSpacingX = spaceX;
interElectrodeSpacingY = spaceY;
interShankSpacingX = spaceShank;

%probe now only takes 'linear' or 'staggered'


%% Makes the chanMap

sessionInfo = bz_getSessionInfo;
numShanks = size(sessionInfo.ElecGp,2);
numChans = sessionInfo.nChannels;

chanVec = 1:numChans;

% Order the channels according to XML
vecChanDoub = [];
vecShankNum = [];

for iShank = 1:numShanks
    for iChan = 1:size(sessionInfo.ElecGp{iShank}.channel,2)
        selChanDoub = str2num(sessionInfo.ElecGp{iShank}.channel{iChan});
        vecChanDoub = [vecChanDoub; selChanDoub];
        vecShankNum = [vecShankNum; iShank];
    end
end

% ChanMap for Kilosort
chanMap0ind = vecChanDoub;
chanMap     = vecChanDoub+1;

% Disconnect bad channels
connected   = ones(numChans,1);

if isfield(sessionInfo, 'badchannels')
    badChIdx = ismember(chanMap0ind, sessionInfo.badchannels);
    connected(badChIdx)=0;
end

% Grouping of channels (shanknums)
kcoords = vecShankNum;

% Determine the location of the channels

vecElecX = [];
vecElecY=[];

startX = 0;
for iShank = 1:numShanks
    for iChan = 1:size(sessionInfo.ElecGp{iShank}.channel,2)
        startY = 0;
        vecElecX = [vecElecX, startX+(iChan-1)*interElectrodeSpacingX];
        vecElecY =[vecElecY, startY+(iChan-1)*interElectrodeSpacingY];
    end
    startX =  iShank*interShankSpacingX;
end

if strcmpi(probeType,'linear')
    xcoords = vecElecX;
    ycoords = vecElecY;
    
elseif strcmpi(probeType,'staggered')
    chanOrdered = 1:numChans;
    eIdx    	=  chanOrdered/2 == round(chanOrdered/2);
    xcoords     = vecElecX;
    xcoords(~eIdx) = xcoords(eIdx)+ interElectrodeSpacingX;
    ycoords     = vecElecY;
end






save([newMapName '.mat'], 'chanMap','chanMap0ind','connected','kcoords','xcoords','ycoords')