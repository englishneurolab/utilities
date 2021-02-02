% Place Field Check 

% Session
basename = 'm161_200802_155120';     % nice
% basename = 'm161_200804_163218';
% basename = 'm161_200810_153112';
basepath = 'E:\Data\inhibit_onoff\pv-het_arch\';
% disp(['Currently evaluating session:' basename])

% Paths
addpath(genpath('E:\Dropbox\Code\english_lab\'))
addpath(genpath('E:\Dropbox\Code\buzcode\'))
addpath('E:\Dropbox\Code\intan')
addpath('E:\Dropbox\Code\buzsupport')

% Session specific paths
analogin_path   = fullfile([basepath filesep basename]);
spike_path      = fullfile([basepath filesep basename]);

%% Parameters / Options

cd(analogin_path)
% session params
sessionInfo = bz_getSessionInfo(cd);

params.nChans       = sessionInfo.nChannels;
params.sampFreq     = sessionInfo.rates.wideband;
params.Probe0idx    = sessionInfo.channels;

% wheel params
% % params.radiusDisk   = 26; % in cm
% % params.circDisk     = 2*pi*params.radiusDisk;

% analogin
params.analoginCh.pulse     = 4;
params.analoginCh.wheel     = 2;
params.analoginCh.reward    = 1;

%  wheel stuff
% % opts.fastTrialsOnly = 1;

% saving
opts.doSave         = 1;
opts.doSaveFig      = 1;
opts.saveMat = true;

%% Load analogin parameters.
cd(analogin_path)

% First get info of analogin
rhdfilename = [basename '_info.rhd'];
read_Intan_RHD2000_file_noprompt(rhdfilename)

analogin_file   = [basename, '_analogin.dat'];
[analogin.pulse, analogin.pos, analogin.reward, analogin.ts] = getAnaloginVals(basename,params,board_adc_channels,opts);

% Separate the wheel in trials
[len_ep, ts_ep, vel_ep, tr_ep, len_ep_fast, ts_ep_fast, vel_ep_fast] = getWheelTrials(analogin);
%%
cd(spike_path)
spikes = bz_LoadPhy;

% % spkRateperBin % heatmaps

% % [SpkVoltage, SpkTime, VelocityatSpk] = rastersToVoltage(analogin, spikes) % rasters over time
% % plotRasterstoVoltage % spks over Voltage, by time 

plotRastersTrials % spks over Voltage, by trial

