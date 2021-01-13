% Script for Velocity & EpochRun
%% Paths, Sessionname
%Add Basepath for all code and data used
    basepath = ('C:\Users\rcbul\Documents\English Lab\');
%Define Recording Session Name
    session_name = 'u19_200313_155505';
%Deine DataPath that contains list of session names;
    data_path = [basepath 'PP_RSC_Data\' session_name];
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
    load([session_name '_analogin.mat']);
    [vel_cm_s, time, dt] = getVelocity(analogin, params, session_name);
  
 %% Find Epochs of running 
    min_thresh = .75
    [runEpochs, runIdx] = getRunEpochs(vel_cm_s, dt, time, min_thresh)
    
     %find how long each epoch last
         length_run = zeros(length(runEpochs),1);
         for i = 1:length(runEpochs)
             length_run(i,1) = runEpochs(i,2)-runEpochs(i,1);
         end
     % find epochs greater than # seconds
         time_thr = 5;
         long_run_epochs_idx = find(length_run(:,1) >= time_thr)
         runEpochs_long = runEpochs(long_run_epochs_idx,:);
 %% Plot: Velocity graph with coordinated Wavespec graph
 % INPUT: Define which epoch you want to graph
    epoch_idx = 6; %any epoch in runEpochs_long
 
    %Define the start and stop of the epoch you want to graph
        epoch_lim = runEpochs_long(epoch_idx,:); %seconds    
    %Plot Velocity 
        figure
        subplot(2,1,1)
        t = time;
        t_ds = downsample(t,10);
        vel_ds = downsample(vel_cm_s, 10);
        plot(t_ds, vel_ds)
        xlim([epoch_lim(1) epoch_lim(2)])
    
    % Wavespec plot
        cd(data_path)
        load('wavespecall.mat'); %sampled at 1250 per second
        subplot(2,1,2)
        normdata = abs(ws_temp.data);
        %normdata_ds = downsample(normdata, 125); %10 samples per second
        imagesc(normdata');
        set(gca,'YDir','normal');
        colormap(jet)
        xlabel('Time(s)');
        ylabel('Frequency(Hz)');
        xlim([epoch_lim(1)*1250 epoch_lim(2)*1250])