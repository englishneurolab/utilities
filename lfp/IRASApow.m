%% This script is designed to get IRASA power spectra out
% Relies on :
%
sessions    = [1:5,16,17];
%%
sessCount   = 0;

for iSess =sessions
    %%
    cd(dirN{iSess})
    basepath =cd; basename = bz_BasenameFromBasepath(basepath);
    
    sessCount   = sessCount +1;
    xmln        = [basepath filesep basename '.xml'];
    fname       = [basepath filesep basename '.lfp'];
    xml         = LoadXml(xmln);
    
    load([basename '.ripples.events.mat'])
    ch      = ripples.detectorinfo.detectionchannel;
    
    lfp = bz_GetLFP(ch);
    % spikes = bz_LoadPhy;
    
    load([basename '_analogin.mat'])
    
    if isfield(analogin,'pos')
        load([basename '.run.states.mat'])
    else
        continue
    end
    
    longEpochs = []; rest = []; inclIdxRest = []; longRest = [];
    
    minRunLength = 3;
    
    % RUN epochs
    longEpochs = run.epochs(run.epochs(:,2)-run.epochs(:,1)>minRunLength,:);
    
    % REST epochs
    rest = getNoRunEpochs(basepath,run);
    
    inclIdxRest = rest(:,2)-rest(:,1)>minRunLength;
    longRest = rest(inclIdxRest,:);
    
    
    %%
    epochsec =3 ;
    
    freqCumul = []; osciCumul=[];
    [status2,interval2] = InIntervals(lfp.timestamps,[longEpochs(:,1) longEpochs(:,1)+epochsec]);
    
    for iInterval = 1:max(interval2)
        spec = amri_sig_fractal(lfp.data(interval2==iInterval),1250,'detrend',1,'frange',[1 150]);
        
        freqCumul= [freqCumul;spec.freq'];
        osciCumul = [osciCumul;spec.osci'];
    end
    
    
    [status3,interval3] = InIntervals(lfp.timestamps,[longRest(:,1) longRest(:,1)+epochsec]);
    freqCumulBase = []; osciCumulBase=[];
    
    for iInterval = 1:max(interval3)
        specBase = amri_sig_fractal(lfp.data(interval3==iInterval),1250,'detrend',1,'frange',[1 150]);
        
        freqCumulBase= [freqCumulBase;specBase.freq'];
        osciCumulBase = [osciCumulBase;specBase.osci'];
    end
    %%
    [r,c] = size(osciCumulBase);
    if r==1
        elem = c;
    else
        elem = r;
    end
    
    vmeanb = nanmean(osciCumulBase);
    vstdb   = nanstd(osciCumulBase);
    vsemb = vstdb./sqrt(elem);
    Upb   = vmeanb+vsemb;
    Lowb  = vmeanb-vsemb;
    
    [r,c] = size(osciCumul);
    if r==1
        elem = c;
    else
        elem = r;
    end
    
    vmean = nanmean(osciCumul);
    vstd   = nanstd(osciCumul);
    vsem = vstd./sqrt(elem);
    Up   = vmean+vsem;
    Low  = vmean-vsem;
    
    
    subplot(3,3,sessCount)
    %%
    plot(mean(freqCumulBase),vmeanb,'k')
    hold on
    plot(mean(freqCumul),vmean,'r')
    
    p = plot(mean(freqCumulBase),Upb,'k:');
    set(p,'LineWidth',0.5);
    
    p = plot(mean(freqCumulBase),Lowb,'k:');
    set(p,'LineWidth',0.5);
    
    p = plot(mean(freqCumulBase),Up,'r:');
    set(p,'LineWidth',0.5);
    
    p = plot(mean(freqCumulBase),Low,'r:');
    set(p,'LineWidth',0.5);
    
    
    legend({'Base >3s','Run >3s'})
    xlim([1 20])
end

