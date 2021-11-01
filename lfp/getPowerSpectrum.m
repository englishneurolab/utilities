function [pow] = getPowerSpectrum(basepath,lfp,varargin)

% This function is designed to
%
%   USAGE
%
%   %% Dependencies %%%
%   FMA toolbox in buzcode

%   INPUTS
%   basepath    - path in which spikes and optostim structs are located
%   lfp         - lfp over which you want to calculate powerspectrum, needs
%                   to be a struct with .data and .samplingRate
%
%   Name-value pairs:
%   'basename'  - only specify if other than basename from basepath
%   'saveMat'   - saving the results to [basename,
%                   '.burstMizuseki.analysis.mat']
%   'saveAs'    - if you want another suffix for your save
%   'channels'

%   OUTPUTS
%
%
%   EXAMPLE
%
%
%   HISTORY
%
%
%   TO-DO
%   - Epochs? Maybe we should move towards a system in which you feed in
%   different lfps dependent on your epochs, instead of building that in
%   the function
%   - Channel selection needs to be built in
%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

channelsValidation = @(x) isnumeric(x) || strcmp(x,'all');

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'saveAs','.pow.analysis.mat',@islogical);
addParameter(p,'channels','all',channelsValidation);
addParameter(p,'doIRASA',true,@islogical);
addParameter(p,'doFMA',true,@islogical);
addParameter(p,'doPlot',true,@islogical);
addParameter(p,'freqRange',[1 150],@isnumeric);

parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
saveAs          = p.Results.saveAs;
channels        = p.Results.channels;
doIRASA         = p.Results.doIRASA;
doFMA           = p.Results.doFMA;
doPlot          = p.Results.doPlot;
freqRange       = p.Results.freqRange;

%% Calculate Powerspectra

if doFMA
    % FMA
    
    % needs epochs? idk
    lfp_fma = [double(lfp.data), lfp.timestamps]; % 1 row data, 1 row timestamps Nx2
    [spectrum,f,s] = MTSpectrum(lfp_fma,'frequency',lfp.samplingRate,'show','off','range',freqRange);
    
    pow.fma.spectrum    = spectrum;
    pow.fma.f           = f;
    pow.fma.s           = s;
%     pow.fma.method      = method;
    
    if doPlot
        figure,
        PlotMean(pow.fma.f,log(pow.fma.spectrum),real(log(pow.fma.spectrum-pow.fma.s)),log(pow.fma.spectrum+pow.fma.s),':','r')
    end
end


if doIRASA
    % IRASA
    % for IRASA the epochs need to be matched if you do epochs
    
    osciCumul=[];
    [~,interval] = InIntervals(lfp.timestamps,epochs);
    
    for iInterval = 1:max(interval)
        spec = amri_sig_fractal(lfp.data(interval==iInterval),lfp.samplingRate,'detrend',1,'frange',freqRange);
        osciCumul  = [osciCumul;spec.osci'];
    end
    
    pow.irasa.freq = spec.freq';
    pow.irasa.osci.all = osciCumul;
    
    
    [r,c] = size(osciCumul);
    if r==1
        elem = c;
    else
        elem = r;
    end
    
    vmean = nanmean(osciCumul);
    vstd   = nanstd(osciCumul);
    vsem = vstd./sqrt(elem);
        
    pow.irasa.osci.mean = vmean;
    pow.irasa.osci.sem  = vsem;
    
    %%
    if doPlot
        Up   = vmean+vsem;
        Low  = vmean-vsem;
        plot(mean(freqCumulBase),vmean,'k')
        hold on
        
        p = plot(mean(freqCumulBase),Up,'k:');
        set(p,'LineWidth',0.5);
        
        p = plot(mean(freqCumulBase),Low,'k:');
        set(p,'LineWidth',0.5);
    end
    
    
end