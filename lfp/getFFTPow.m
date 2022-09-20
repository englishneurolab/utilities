function getFFTPow(basepath,session,chunks,varargin)
%
% This function is meant to get the power at different frequencies from the
% whitened lfp signal for all channels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Dependencies
%    - Buzcode
%    - Cell Explorer
%    - lfp file
%    - session file from cell explorer
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input
%    basepath - path to data (typical to use cd)
%    session  - session containing metadata, specifically anatomically
%               organized channels from cell explorer
%    chunks   - integer of number of chunks to break the data into (make
%               factor of 32)
%
%%%Options%%%
%    
%    'secondFilt' - range of freqs to bandpass a second time as defined in 
%                   bz_Filter typically used to remove 60Hz ([58 62])
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Usage
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Todos
%   - make channels an optional input
%   - change output to be intiger values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% History
% - (2021/03/16) Code written by Kaiser Arndt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parse inputs

p = inputParser;
addParameter(p,'secondFilt',0,@isnumeric); 

parse(p,varargin{:})

secondFilt = p.Results.secondFilt;

%% Load files
basename = bz_BasenameFromBasepath(basepath);

lfp = bz_GetLFP('all') ;

load([basename '.session.mat']);
load([basename '.sessionInfo.mat']);


%% assign

anatchannels = cell2mat(session.extracellular.electrodeGroups.channels);

channels = sessionInfo.channels;

passband = [0 250];

%freq bands make this an input
F.Delta       = [1 4];
F.Theta       = [6 10];
F.Spindle     = [9 16];
F.Beta        = [16 30];
F.GammaSlow   = [30 80];
F.GammaFast   = [80 100];
F.Rip         = [100 250];

F = cell2mat(struct2cell(F));

%% Whiten LFP
disp('Whitening and filtering LFP signal... Go grab a coffee.');

x = reshape(channels, length(channels)/chunks ,chunks)';





channels = [];
lfpPow.pow = [];
for i = 1:size(x,1)
    
    if ~isempty(session.channelTags.Bad.channels)
        channels = x(i,~ismember(x(i,:), session.channelTags.Bad.channels));
    else
        channels = x(i,:);
    end
    
    lfp = bz_GetLFP(channels);
    
    Fs = lfp.samplingRate;
    L = length(lfp.timestamps);
    
    lfpwhiten = bz_whitenLFP(lfp);
    clear lfp
    
    filtered = bz_Filter(lfpwhiten, 'passband', passband);%'stopband', secondFilt, 'filter', 'fir1');
    clear lfpwhiten


    disp('Computing FFT')
    
    y4yay = [];
    for i = 1:length(channels)
        
        
        y4yay = fft(filtered.data(:,i)); % run fast foureir transform
        P2 = abs(y4yay/L); % compute the 2 sided spectrum
        P1 = P2(1:L/2+1); % compute the 1 sided spectrum
        P1(2:end-1) = 2*P1(2:end-1); %
        
        
        pow(:,i) = sgolayfilt(P1, 5, 5001); % Filter fft
        
    end
    lfpPow.pow = [lfpPow.pow pow];
end

%%

lfpPow.pow = lfpPow.pow(:,anatchannels);

if ~isempty(session.channelTags.Bad.channels)
    lfpPow.pow(:,session.channelTags.Bad.channels) = nan;
end


lfpPow.freqs = Fs*(1:(L/2))/L;% round((Fs*(1:(L/2))/L) + 1);
lfpPow.channels = anatchannels;



%% stats

disp('Saving all my hard work')

% group power response for each channel into different freq bands
[status,interval,index] = InIntervals(lfpPow.freqs,F);


for i = 1:length(F)
    pows{i,:}   = lfpPow.pow(interval == i,:);
    avgPow(i,:) = mean(pows{i});
    stdPow(i,:) = std(pows{i});
end

lfpPow.powBands         = pows;
lfpPow.avgPow           = avgPow;
lfpPow.stdPow           = stdPow;
lfpPow.freqBands        = F;
lfpPow.badChansExcluded = session.channelTags.Bad.channels;


save([basename '.lfpPow.mat'], 'lfpPow','-v7.3') %save tp file size with greater capacity


