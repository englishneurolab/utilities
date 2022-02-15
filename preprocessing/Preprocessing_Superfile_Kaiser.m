%% Kaiser official preprocessing pipeline

%%
%%%%%%%%%%%%%%%%%%%%%%% 
% % % Spikesorting
%%%%%%%%%%%%%%%%%%%%%%%
% this should be run before running this function

% edit Kilosort_Superfile_Kaiser.m

% use the correct corresponding kilosort variant for your recording

%% 
%%%%%%%%%%%%%%%%%%%%%%%
% % % Session Info
%%%%%%%%%%%%%%%%%%%%%%%
% this is just to make future buzcode functions work
sessionInfo = bz_getSessionInfo

%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % make LFP
%%%%%%%%%%%%%%%%%%%%%%%

bz_LFPfromDat %makes the .lfp file

% will take a Y/N input

%%
session = sessionTemplate(cd,'showGUI',true); 
%makes session info Window, unnecessary to fill out if sessionInfo.mat is already on path

basename = bz_BasenameFromBasepath(cd);
basepath = cd;




%% 
%%%%%%%%%%%%%%%%%%%%%%%
% % % Does the .dat need to be cut?
%%%%%%%%%%%%%%%%%%%%%%%

% CopyDat('m317_220129_155505.dat','m317_220129_155505_HPC.dat', 'channelIx', [1:64])


%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % make lfp spectrogram and find max HFO and SW chan
%%%%%%%%%%%%%%%%%%%%%%%

chunks = 16;

getFFTPow(basepath,session,chunks);%,'secondFilt', [58 60]);

load([basename '.lfpPow.mat'])

[~,I] = max(lfpPow.avgPow(7,:));

HFOchan = lfpPow.channels(I);


[~,I] = max(lfpPow.avgPow(5,:));

SWchan = lfpPow.channels(I);

% Adjust power spectra for 60 hz ***This is not a good way of doing it***

x = lfpPow.freqs > 60 & lfpPow.freqs < 60;
lfpPow.pow(x,:) = 0;


%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % Assign channels
%%%%%%%%%%%%%%%%%%%%%%%



% base 1
Chans.Dig.LinStr    = nan;
Chans.Dig.LinStp    = nan;
Chans.Dig.pulse     = nan;
Chans.Analog.pos    = 5;
Chans.Analog.reward = nan;
Chans.Analog.pulse  = 6;

% For uLED pulse recordings
Chans.Analog.pulseSH1 = 3;
Chans.Analog.pulseSH2 = 4;
Chans.Analog.pulseSH3 = 5;
Chans.Analog.pulseSH4 = 6;

% base 0
Chans.Ripchan       = Ripchan;
Chans.HFOchan       = HFOchan;
Chans.SWchan        = SWchan;


save([basename '.Chans.mat'], 'Chans')
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



analogin = getAnaloginVals(cd,'wheelChan', Chans.Analog.pos, 'pulseChan', Chans.Analog.pulse...
    , 'rewardChan', 'none', 'downsampleFactor', 24);

              

% Velocity

vel = getVelocity(analogin);

% Run epochs

run = getRunEpochs(basepath,vel,'saveMat', true, 'minRunSpeed', 0.5);
%% 
%%%%%%%%%%%%%%%%%%%%%%%
% % % Find Pulse Epochs
%%%%%%%%%%%%%%%%%%%%%%%

% If optostim run this section
[pulseEpochs] = getSinPulseTimes(analogin,varargin);

[pulseEpochs] = getPulseTimes(analogin);


%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % Find HFOs
%%%%%%%%%%%%%%%%%%%%%%%

lfp = bz_GetLFP('all')

HFOs = bz_FindRipples(cd,Chans.HFOchan,'durations',[50 150],...
    'thresholds',[1 2], 'passband',[100 250], 'EMGThresh', 0.9,'saveMat',false);

HFOFilt = bz_Filter(lfp, 'passband', [100 250]);

[HFO_maps,HFO_data,HFO_stats] = bz_RippleStats(HFOFilt.data(:,HFOs.detectorinfo.detectionchannel),HFOFilt.timestamps,HFOs);

[HFOs] = evtAvgLFP(HFOs);

save([basename '.HFOs.stats.mat'], 'HFO_maps','HFO_data','HFO_stats')

save([basename '.HFOs.events.mat'], 'HFOs')

clear('HFO_maps','HFO_data','HFO_stats','HFOFilt')

makeHFOsFile

%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % Find Ripples
%%%%%%%%%%%%%%%%%%%%%%%

ripples = bz_FindRipples(cd,Chans.Ripchan,'durations',[50 150],...
    'thresholds',[2 3], 'passband',[100 250],'saveMat',false);

save([basename '.ripples.events.mat'], 'ripples')

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
% % % Find out pul HFOs
%%%%%%%%%%%%%%%%%%%%%%%
ints = [];
for i = 1:length(pulseEpochs.timestamps)
    x = pulseEpochs.timestamps{i};
    ints = [ints x'];
end
ints = ints';
    


[status,interval,index] = InIntervals(HFOs.peaks,ints);

HFOs.outPul.timestamps = HFOs.timestamps(~status);
HFOs.outPul.peaks      = HFOs.peaks(~status);

HFOs.inPul.timestamps  = HFOs.timestamps(status);
HFOs.inPul.peaks       = HFOs.peaks(status);

save([basename '.HFOs.events.mat'], 'HFOs')

%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % make spikes
%%%%%%%%%%%%%%%%%%%%%%%

%skip with m150 on laptop

spikes = bz_LoadPhy_CellExplorer;



%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % State editor
%%%%%%%%%%%%%%%%%%%%%%%

rejectChannels = [];

bz_EMGFromLFP(cd);

SleepState = SleepScoreMaster(cd); %,'rejectChannels', rejectChannels,'noPrompts', true,'ignoretime',[])% exclude the times of stimulation

%%
% make input struct for the state editor (analogin motion)
basename = bz_BasenameFromBasepath(cd)
lfp = bz_GetLFP([83 95 68]) % top channel, best rip chan, bottom channel only do 3 channels
x = ones(1,3);
inputData.rawEeg = mat2cell(double(lfp.data),length(lfp.data),x)
inputData.eegFS = 1
inputData.Chs = lfp.channels
inputData.MotionType = 'File'

%comment out if getAnaloginVals (line 118) has not been run
inputData.motion = double(bz_LoadBinary([basename '_analogin.dat'],'nChannels', 8, 'channels', Chans.Analog.pos + 1, 'precision', 'uint16', 'downsample', 30000)) * 0.000050354; %state editor motion needs data in a one hz format
inputData.motion(end) = []; % this may be needed if you run into an error
% on line 983
clear lfp
%EHW 21.10.14 - error here at inputData.motion  = double

TheStateEditor(basename) %inputData) % this is the manual state editor, use to check the automation of the sleepscoremaster
% % for troublshooting with Lianne
% % inputData.motion = downsample(analogin.pos,30000)



delete([basename '.SleepStateEpisodes.states.mat'])

inputData.motion(end) = []; % delete basename.eegstates.mat before rerunning the editor, skip if getAnaloginVals (118) has not been run
save([basename '.inputData.mat'], 'inputData')


saveThetaSpec
%%
%%%%%%%%%%%%%%%%%%%%%%%
% % % Cell Metrics
%%%%%%%%%%%%%%%%%%%%%%%
%                       INCOMPLETE - Do not run yet
% this is where the true metadata for the recording is kept
session = sessionTemplate(cd,'showGUI',true);
% Crtl+I - forces use of the .xml probe layout
% if you have a "Kilosort" folder make sure the relatilve path in the
% session info has \Kilosort

load('Chanmap_H3_Acute.mat')
chanCoords.x = xcoords;
chanCoords.y = ycoords;

session.extracellular.chanCoords.x = chanCoords.x;
session.extracellular.chanCoords.y = chanCoords.y;

save([basename '.session.mat'], 'session')
save([basename '.chanCoords.channelInfo.mat'], 'chanCoords')

cell_metrics = ProcessCellMetrics('session', session, 'showGUI', true);

cell_metrics = CellExplorer('metrics',cell_metrics);
% now cell_metrics is finished and ready to be worked with


