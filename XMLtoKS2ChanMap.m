function XMLtoKS2ChanMap(newChanMapName, elecSpaceX, elecSpaceY, shankSpaceX, probe)

% SessionInfo via XML To KS2 ChanMap for preprocessing with Kilosort2
% Dependencies: Buzcode

% Make sure XML is up to date with bad channels and correct channel groups
% If you need to check or update your details check: bz_getSessionInfo(cd,'editGUI',true)

% % Inputs:
% newChanMapName will be the name of your channelmap
% elecSpaceX: distance between electrodes on each shank in the X direction
% elecSpaceY: distance between electrodes on each shank in the Y direction
% shankSpaceX: distance between shanks
% probe: 'linear' or 'staggered'


%% Set parameters for shank
% This is assuming same layouts per Shank:

interElectrodeSpacingX = elecSpaceX;
interElectrodeSpacingY = elecSpaceY;
interShankSpacingX = shankSpaceX;

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

if strcmpi(probe,'linear')
    xcoords = vecElecX;
    ycoords = vecElecY;
    
elseif strcmpi(probe,'staggered')
    chanOrdered = 1:numChans;
    eIdx    	=  chanOrdered/2 == round(chanOrdered/2);
    xcoords     = vecElecX;
    xcoords(~eIdx) = xcoords(eIdx)+ interElectrodeSpacingX;
    ycoords     = vecElecY;
    
else
    fprintf('probe not recognized, choose ''linear'' or ''staggered'' \n')
end






save([newChanMapName '.mat'], 'chanMap','chanMap0ind','connected','kcoords','xcoords','ycoords')