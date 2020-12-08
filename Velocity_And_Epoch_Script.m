% Script for Velocity & EpochRun
%% Paths, Sessionname
%Add Basepath for all code and data used
    basepath = ('C:\Users\rcbul\Documents\English Lab\');
%Define Recording Session Name
    basename = 'u19_200313_155505';
%Deine DataPath that contains list of session names;
    data_path = [basepath 'PP_RSC_Data\' basename];
%Add Paths
    addpath(genpath(data_path));
    addpath(genpath([basepath 'Code\']));
    addpath(genpath([basepath 'Sam_Code\']));
    addpath(genpath([basepath 'buzcode-dev\']));
%% Params
    params.radiusDisk   = 26;
    params.circDisk     = 2*pi*params.radiusDisk;
%%  Get Velocity
    %Note: code chooses wheel rotation calculation based on session name including 'mouse' or not
    cd(data_path)
    load([basename '_analogin.mat']);
    [vel_cm_s, time, dt] = getVelocity(analogin, params, basename);
  
 %% Find Epochs of running 
    min_thresh = 3;
    [runEpochs, runIdx] = getRunEpochs(vel_cm_s, dt, time, min_thresh)
    
     %find how long each epoch last
         length_run = zeros(length(runEpochs),1);
         for i = 1:length(runEpochs)
             length_run(i,1) = runEpochs(i,2)-runEpochs(i,1);
         end
     % find epochs greater than # seconds
         time_thr = 5;
         long_run_epochs_idx = find(length_run(:,1) >= time_thr);
         runEpochs_long = runEpochs(long_run_epochs_idx,:);
 %%