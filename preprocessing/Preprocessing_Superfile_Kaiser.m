%% Kaiser official preprocessing pipeline

%%
%%%%%%%%%%%%%%%%%%%%%%% 
% % % Spikesorting
%%%%%%%%%%%%%%%%%%%%%%%
% this should be run before running this function

% edit Kilosort_Superfile.m

% use the correct corresponding kilosort variant for your recording

%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % Assign channels
%%%%%%%%%%%%%%%%%%%%%%%
% base 0

basename = bz_BasenameFromBasepath(cd);
basepath = cd;

Chans.Dig.LinStr    = nan;
Chans.Dig.LinStp    = nan;
Chans.Dig.pulse     = nan;
Chans.Analog.pos    = 1;
Chans.Analog.reward = nan;
Chans.Analog.pulse  = nan
Chans.ripchan       = 38;
Chans.SWchan        = 61;

save([basename '.Chans.mat'], 'Chans')


%% 
%%%%%%%%%%%%%%%%%%%%%%%
% % % Session Info
%%%%%%%%%%%%%%%%%%%%%%%
% this is just to make future buzcode functions work
bz_getSessionInfo

%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % make LFP
%%%%%%%%%%%%%%%%%%%%%%%

bz_LFPfromDat

%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % Find Ripples
%%%%%%%%%%%%%%%%%%%%%%%

ripples = bz_FindRipples(cd,Chans.ripchan,'durations',[50 150],...
    'thresholds',[1 2], 'passband',[100 250], 'EMGThresh', 0.95,'saveMat',true);

makeRipFile

%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % Find Sharpwaves
%%%%%%%%%%%%%%%%%%%%%%%


sharpwaves = bz_FindRipples(cd,Chans.SWchan,'durations',[5 50],...
    'thresholds',[0 1], 'passband',[25 100], 'EMGThresh', 0.95,'saveMat',false);

save([basename '.sharpwaves.events.mat'], 'sharpwaves')

makeSPWFile



%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % pos and reward
%%%%%%%%%%%%%%%%%%%%%%%
%base 1 inputs

% analogin = [];
% analogin.pos = double(bz_LoadBinary([basename '_analogin.dat'],'nChannels', 8, 'channels', Chans.Analog.pos + 1 , 'precision', 'uint16')) * 0.000050354;
% analogin.reward = double(bz_LoadBinary([basename '_analogin.dat'],'nChannels', 8, 'channels', Chans.Analog.reward + 1, 'precision', 'uint16')) * 0.000050354;
% 
% save([basename '_analogin'], 'analogin')

analogin = getAnaloginVals(cd,'wheelChan', Chans.Analog.pos, 'pulseChan', 'none', 'rewardChan', 'none');


% Velocity

vel = getVelocity(analogin);
%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % make spikes
%%%%%%%%%%%%%%%%%%%%%%%

spikes = bz_LoadPhy

%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % Cell Metrics
%%%%%%%%%%%%%%%%%%%%%%%
% this is where the true metadata for the recording is kept
session = sessionTemplate(cd,'showGUI',true);
% Crtl+I - forces use of the .xml probe layout
% if you have a "Kilosort" folder make sure the relatilve path in the
% session info has \Kilosort
load('Chanmap_H3_Acute.mat')
chanCoords.x = xcoords;
chanCoords.y(session.extracellular.electrodeGroups.channels{1}) = ycoords;

save([basename '.chanCoords.channelInfo.mat'], 'chanCoords')

cell_metrics = ProcessCellMetrics('session', session);

cell_metrics = CellExplorer('metrics',cell_metrics);
% now cell_metrics is finished and ready to be worked with

%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % State editor
%%%%%%%%%%%%%%%%%%%%%%%

rejectChannels = [];

EMGFromLFP = bz_EMGFromLFP(cd)
SleepState = SleepScoreMaster(cd,'overwrite', true, ...
    'rejectChannels', rejectChannels)% exclude the times of stimulation

% make input struct for the state editor (analogin motion)
basename = bz_BasenameFromBasepath(cd)
lfp = bz_GetLFP([58 Chans.ripchan 5]) % top channel, best rip chan, bottom channel only do 3 channels
x = ones(1,3);
inputData.rawEeg = mat2cell(double(lfp.data),length(lfp.data),x)
inputData.eegFS = 1
inputData.Chs = lfp.channels
inputData.MotionType = 'File'
inputData.motion = double(bz_LoadBinary([basename '_analogin.dat'],'nChannels', 8, 'channels', Chans.Analog.pos + 1, 'precision', 'uint16', 'downsample', 30000)) * 0.000050354; %state editor motion needs data in a one hz format
% inputData.motion(end) = []; % this may be needed if you run into an error
% on line 983
clear lfp


TheStateEditor(basename, inputData) % this is the manual state editor, use to check the automation of the sleepscoremaster
% for troublshooting with Lianne
% inputData.motion = downsample(analogin.pos,30000)
inputData.motion(end) = []; % delete basename.eegstates.mat before rerunning the editor
save([basename '_inputData.mat'], 'inputData')


