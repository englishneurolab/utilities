function getFFTPow(basepath,session)
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
%
%%%Options%%%
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% History
% - (2021/03/16) Code written by Kaiser Arndt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load files
basename = bz_BasenameFromBasepath(basepath);

lfp = bz_GetLFP('all') ;

load([basename '.session.mat'])


%% assign

channels = session.extracellular.electrodeGroups.channels{1};

passband = [0 250];

%freq bands make this an input
F.Delta       = [1 4];
F.Theta       = [6 10];
F.Spindle     = [9 16];
F.Beta        = [16 30];
F.GammaSlow   = [30 80];
F.GammaFast   = [80 120];
F.Rip         = [120 250];

F = cell2mat(struct2cell(F));

%% Whiten LFP
disp('Whitening LFP signal');

lfpwhiten = bz_whitenLFP(lfp);
lfpwhiten.channels = lfp.channels;
clear lfp
%% Filter out spiking activity

disp('Filtering LFP signal... Go grab a coffee');

% run in chunks
x = reshape(lfpwhiten.channels, 16,4)';

for i = 1:size(x,1)
    filtered = bz_Filter(lfpwhiten, 'passband', passband, 'filter', 'fir1', 'channels', x(i,:));
    
    data(:,x(i,:)+1) = filtered.data;
end
clear whiten
clear filtered
%%
disp('Computing FFT')
Fs = lfpwhiten.samplingRate;
L = length(lfpwhiten.timestamps);

y4yay = [];

for i = 1:length(channels)
    
    y4yay = fft(data(:,channels(i))); % run fast foureir transform
    P2 = abs(y4yay/L); % compute the 2 sided spectrum
    P1 = P2(1:L/2+1); % compute the 1 sided spectrum
    P1(2:end-1) = 2*P1(2:end-1); % 
    
    
    lfpPow.pow(:,i) = sgolayfilt(P1, 5, 5001); % Filter fft
    
end



lfpPow.freqs = Fs*(1:(L/2))/L% round((Fs*(1:(L/2))/L) + 1);
lfpPow.channels = channels;

% 
% res = zeros(length(lfpPow.freqs),1);
% res(1:round((L/2)/(Fs/2)):end) = 1;
% res = logical(res);

% lfpPow.freqs = lfpPow.freqs(res);
% lfpPow.pow = lfpPow.pow(res,:);


%% stats

disp('Saving all my hard work')

% group power response for each channel into different freq bands
[status,interval,index] = InIntervals(lfpPow.freqs,F);


for i = 1:length(F)
    pows{i,:}   = lfpPow.pow(interval == i,:);
    avgPow(i,:) = mean(pows{i});
    stdPow(i,:) = std(pows{i});
end

lfpPow.powBands  = pows;
lfpPow.avgPow    = avgPow;
lfpPow.stdPow    = stdPow;
lfpPow.freqBands = F;


save([basename '.lfpPow.mat'], 'lfpPow','-v7.3') %save tp file size with greater capacity


