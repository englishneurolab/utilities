% make time-voltage pairs for powerspectrum
sessCount =0;
for iSess =sessions
    %%
cd(dirN{iSess})
basepath =cd;, basename = bz_BasenameFromBasepath(basepath);
    % run.epochs
sessCount = sessCount +1;
xmln    = [basepath filesep basename '.xml'];
fname   = [basepath filesep basename '.lfp'];
xml     = LoadXml(xmln);

 load([basename '.ripples.events.mat'])
ch      = ripples.detectorinfo.detectionchannel;

% sessionInfo = bz_getSessionInfo(basepath);
% sampFreq = sessionInfo.rates.wideband;

lfp = bz_GetLFP(ch);
% spikes = bz_LoadPhy;

  load([basename '_analogin.mat'])
  if isfield(analogin,'pos')
  %       if exist([basename, '.run2cm.states.mat'])
  %           load ([basename, '.run2cm.states.mat'])
  %       else
  %
  %  [vel] = getVelocity(analogin,'doFigure',false,'downsampleFactor',3000);
  %  [run] = getRunEpochs(basepath,vel,'minRunSpeed',2,'saveMat',false);
  %       end
       load([basename '.run.states.mat'])
       run2 = load([basename '.run2cm.states.mat']);
%% 
minRunLength = 3;

% RUN epochs
longEpochs = run.epochs(run.epochs(:,2)-run.epochs(:,1)>minRunLength,:);

% REST epochs
rest = zeros(1,length(run2.run.epochs)+1)';
rest(2:end,1) = run2.run.epochs(:,2);
rest(1,1) = 0;
rest(1:end-1,2) = run2.run.epochs(:,1);
rest(end,:) = [];

IdxRest = rest(:,2)-rest(:,1)>minRunLength;
longRest = rest(IdxRest,:);


[status,interval] = InIntervals(lfp.timestamps,longEpochs);
[status2,interval2] = InIntervals(lfp.timestamps,longRest);

subplot(3,3,sessCount)
hold on

lfp_norun_data = double(lfp.data(status2));
lfp_norun_time = lfp.timestamps(status2);

lfp_norun = [lfp_norun_time,lfp_norun_data];

[spectrum,f,s] = MTSpectrum(lfp_norun,'frequency',1250,'show','off');

PlotMean(f,log(spectrum),real(log(spectrum-s)),log(spectrum+s),':','k')


lfp_run_data = double(lfp.data(status));
lfp_run_time = lfp.timestamps(status);

lfp_run = [lfp_run_time, lfp_run_data];

if ~isempty(lfp_run)
[spectrum,f,s] = MTSpectrum(lfp_run,'frequency',1250,'show','off');

PlotMean(f,log(spectrum),real(log(spectrum-s)),log(spectrum+s),':','r')
end

xlim([0 25])
% legend({'No Run', 'CI','CI','Run','CI','CI'})
xlabel('Frequency')
ylabel('Amplitude')

title(['Powerspectrum iSess ' num2str(iSess)])
end
% 
end