for iSess = 6%16:17%length(dirN)
cd(dirN{iSess})
basepath = cd; basename = bz_BasenameFromBasepath(cd);
%%
params.radiusDisk   = 26;
params.circDisk     = 2*pi*params.radiusDisk;

    load([basename '_analogin.mat']);
    [vel_cm_s, time, dt] = getVelocity(analogin, params, basename);
    
    min_thresh = 1.5; %cm/sec
    [runEpochs, runIdx] = getRunEpochs(vel_cm_s, dt, time, min_thresh);
    
    %find how long each epoch last
    length_run = zeros(length(runEpochs),1);
    for i = 1%:length(runEpochs)
        length_run(i,1) = runEpochs(i,2)-runEpochs(i,1);
    end
    % find epochs greater than # seconds
    time_thr = 3; %minsec of epoch to keep
    long_run_epochs_idx = find(length_run(:,1) >= time_thr);
    runEpochs_long = runEpochs(long_run_epochs_idx,:);
    
    selRunEpochs = runEpochs_long;
        save([basename '_runEpochs_1_5.mat'],'runEpochs','runEpochs_long','time_thr','min_thresh');

  %%  
end
