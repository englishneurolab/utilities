%% Add the folders with Code to your MATLAB Path
% Change these paths to match with your local folders

% addpath(genpath('E:\Dropbox\EnglishLab_WS3\Code\inhibition_project'))
addpath(genpath('E:\Dropbox\Code\english_lab\'))
addpath(genpath('E:\Dropbox\Code\buzcode\'))
addpath('E:\Dropbox\Code\intan')
addpath('E:\Dropbox\Code\buzsupport')   

%% What Session do you want to look at?
% Change these paths to match with your local folders

% basename = 'm122_191202_144907';
% basepath = 'E:\Data\odor_pilot_camkii\m122\'; % NB forward slashes in Mac OSX
% 
% basename = 'u21_200309_142534';
% basename = 'u19_200310_135409'
basename = 'u19_200313_120452';
% basepath = 'E:\Data\inhibit_onoff\unc5b-hom\';
basepath = 'D:\Data\Axoaxonic_Data_Lianne';

analogin_path   = fullfile([basepath filesep basename]);
spike_path      = fullfile([basepath filesep basename filesep 'ks2']);


params.radiusDisk = 26; % in cm
params.circDisk = 2*pi*params.radiusDisk;

opts.fastTrialsOnly = true;

%% Load the spikes
cd(spike_path)
spikes = bz_LoadPhy; %% Load in the clusters that are spike sorted with phd and are labeled 'good'

%% Go to the folder that has the analogin file to get timestamps for wheel position, stimulations, reward.
cd(analogin_path)

% First get info of analogin
rhdfilename = [basename '_info.rhd'];
read_Intan_RHD2000_file_noprompt(rhdfilename)

analogin_file   = [basename, '_analogin.dat'];

% Get analogin values. In the analogin file we have
if contains(basename,'m1_181220_151127')
    parameters.analoginCh.pulse = 1;
elseif contains(basename,'u21') || contains(basename,'u19')
    parameters.analoginCh.pulse = 4;
else
    parameters.analoginCh.pulse = 7; % change for unc5b?
end
parameters.analoginCh.wheel = 2;
parameters.analoginCh.reward = 1;

opts.downsampleFactor = 300; %(samplingRate/downsampleFactor to get 100Hz) and make the data a bit more manageable.

% Get values from _analogin.dat (pulse, water etc.)
[analogin.pulse, analogin.pos, analogin.reward, analogin.ts] = getAnaloginVals(basename,parameters,board_adc_channels,opts);

% Separate the rotations of the wheel in trials
[len_ep, ts_ep, vel_ep, tr_ep, len_ep_fast, ts_ep_fast, vel_ep_fast] = getWheelTrials(analogin);




%% Here the fun starts: Find which spikes of each cell belong in which trial, and more specific in which bin

for iUnit =1:length(spikes.UID) % we're looping over all the cells we clustered, you can also specify iUnit = 1 to test it out for the first cell and not have your computer overload.
    
    if opts.fastTrialsOnly
        trialTimes  = ts_ep_fast; % downsampled to 100 Hz
        trialPos    = len_ep_fast; % downsampled to 100 Hz
    else
        trialTimes  = ts_ep; % downsampled to 100 Hz
        trialPos    = len_ep; % downsampled to 100 Hz
    end
    
    % First find which spike times fall within each trial (tr_ep)
    % [status,interval] = InIntervals(spikes.times{iUnit},tr_ep);
       
    % Now, for each trial, create position bins and find out how many spikes are in each position bin
    for iTr = 1:length(trialPos)
        halifaxValWheel = round(max(cell2mat(trialPos)),2);% To-do: set actual length in cos % 1.2 for m1
        posWheelinCm = trialPos{iTr}*params.circDisk/max(trialPos{iTr});
        posWheelCmMax = ceil(max(posWheelinCm));
        posWheelCmMin = floor(min(posWheelinCm));
        
        
         % find what position values fall within each position bin
        lengthBinCm = 10; % if i change this i don't have enough posBinsCount for all the spikes
                
        binEdges = 1:lengthBinCm:posWheelCmMax;
        if posWheelCmMax > binEdges(end)
            binEdges = [binEdges posWheelCmMax];
        end
        
        posBinsCount = histoc(posWheelinCm,binEdges); 
        % which posWheelinCm falls within which positionBin (as specified
        % by 1:lengthBinCm:posWheelCmMax)
              
        % first ditch the extra timestamps after peek
        
 % nb last few samples are surpassing the peak ( maybe because of
 % downsampling)
        ts_posbin = mat2cell(trialTimes{iTr},posBinsCount);% all timestamps per trial for positions.
        
        % for iTr = 1
        % sum(posBinsCount) = 40 als length = 10cm
        % sum posBinsCount = 669 als lengthBinCm = 1 cm
        
        
       
        
        
        
        % sum(posBinsCount) == length(trialTimes{iTr}, so distributing
        % those spikes in trial over positions
        
        tr_pos = zeros(length(posBinsCount),2); % zero-allocate.
        for iPosBin = 1:length(posBinsCount) % hardcoded now
            
            
            if ~isempty(ts_posbin{iPosBin})
                tr_pos(iPosBin,:) = [ts_posbin{iPosBin}(1) ts_posbin{iPosBin}(end)]; %% start stop of ts of each position bin  in time
                % seconds in bin per trial
                secTrPosBin = tr_pos(iPosBin,2) - tr_pos(iPosBin,1); % in sec
          
            
            
            elseif isempty(ts_posbin{iPosBin})
                posbinTs(iPosBin,:) = [0.0000001 0.0000002];
                secTrPosBin = [0.00000001];
            end
        end
        
        
        %how many spikes occur in these position intervals?
        [status, interval]= InIntervals(spikes.times{iUnit},tr_pos);
        
        % now find out how many spikes/s are within these posbinS. (normalized FR 0 to 1) By
        % calculating length posbinTs (end-1) and number of timestamps.
        
        numSpkBin      = histoc(interval(interval>0),1:size(tr_pos,1)); % how many timestamps or position values should there be per bin
                
        spkPerSec{iUnit}.trial{iTr} = numSpkBin/secTrPosBin; % to get spikes per second and correct for time spent at each location
        % spkPerSec is still way off now.
        
    end
    
    unitRM_Matrix = cell2mat(spkPerSec{iUnit}.trial)';
    unitRM_Matrix(isnan(unitRM_Matrix))=0; % new
    
    nosc_unitRM{iUnit} = unitRM_Matrix;
    
    
%     zscore_unitRM{iUnit} = zscore(unitRM_Matrix,[],2);
    
end
%% Locate Depolarization Trials
[pulseIdx, noPulseIdx, pulseEpochs] = getPulseTrialIdx(analogin, tr_ep);%parameters.analoginCh

%%

doPlot = true % ;-)
if doPlot
    inh_plotRateMaps
end