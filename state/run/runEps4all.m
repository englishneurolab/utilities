% Script to get running epochs for all sessions 

for iSess = sessions
cd(dirN{iSess})
basepath = cd; basename = bz_BasenameFromBasepath(cd);
%%
% % params.radiusDisk   = 26;
% % params.circDisk     = 2*pi*params.radiusDisk;
clear analogin
load([basename '_analogin.mat'])
if ~isfield(analogin,'sr')
    analogin.sr = 30000;
    save([basename '_analogin.mat'])
end


[vel] = getVelocity(analogin,'doFigure',false,'downsampleFactor',3000);
% savefig(gcf,'velocity.fig')
[run] = getRunEpochs(basepath,vel,'minRunSpeed',2);


%     %find how long each epoch last
%     length_run = zeros(length(runEpochs),1);
%     for i = 1%:length(runEpochs)
%         length_run(i,1) = runEpochs(i,2)-runEpochs(i,1);
%     end
%     % find epochs greater than # seconds
%     time_thr = 3; %minsec of epoch to keep
%     long_run_epochs_idx = find(length_run(:,1) >= time_thr);
%     runEpochs_long = runEpochs(long_run_epochs_idx,:);
%     
%     selRunEpochs = runEpochs_long;
%         save([basename '_runEpochs_1_5.mat'],'runEpochs','runEpochs_long','time_thr','min_thresh');

  %%  
end
