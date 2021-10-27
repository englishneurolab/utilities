 function getLFPFreqPow(basepath)
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
%    - basepath (default = cd)
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
%   - Make option: lfp load in as chunk
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% History
% - (2021/04/19) Code written by Kaiser Arndt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Assign inputs

basename = bz_BasenameFromBasepath(basepath);

% assign freq bands (change as needed)
F.Delta       = [1 4];
F.Theta       = [6 10];
F.Spindle     = [9 16];
F.Beta        = [16 30];
F.GammaSlow   = [30 80];
F.GammaFast   = [80 120];
F.Rip         = [120 200];

freqs = cell2mat(struct2cell(F));

clear F

%% Load in files
lfp = bz_GetLFP('all'); %load in lfp

load([basename '.session.mat']); % load in session meta data, where anatomically organized channels are

channels = session.extracellular.electrodeGroups.channels{1};

%% Whiten LFP

lfpwhiten = bz_whitenLFP(lfp);

%% calculate power for each band in each channel

for i = 1:length(channels)
    for ii = 1:length(freqs)
        [wavespec] = bz_WaveSpec(lfp,'frange', freqs(ii,:), 'nfreqs', freqs(ii,2) - freqs(ii,1) + 1, 'chanID', channels(i))
        data{i,ii} = wavespec.data;
    end
end



























