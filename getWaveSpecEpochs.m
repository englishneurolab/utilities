function [wavespec_epochs] = getWaveSpecEpochs(basepath, run, varargin);
% This function is designed to get the continous velocity in cm/s from the
% analogin.dat file. 
%
%   USAGE
%
%   %% Dependencies %%%
%
%
%   INPUTS
%   basepath  - out
%   epochs    -
%
%   Name-value pairs
%   'timMS'        - Default: 1000
%

%   OUTPUTS
%   wavespec epochs
%   .data    -
%   .timestamps        -
%   .freqs          -
%   .nfreqs
%   .samplingRate   
%   .channels
%   .filterparms
%
%   EXAMPLES
%   
%
%   HISTORY
%   2020/12 Lianne documented and proofed this function
%
%   TO-DO
%  

%%
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);



%%
xmln    = [basepath filesep basename '.xml'];
fname   = [basepath filesep basename '.lfp'];
xml     = LoadXml(xmln);

load([basename '.ripples.events.mat'])
ch      = ripples.detectorinfo.detectionchannel;
lfp     = bz_GetLFP(ch);
%%
timMS = 1; %s
ops.tw_ws = timMS * lfp.samplingRate ;
ops.bl_ws = ops.tw_ws*2;

freqRange = [1 15];
numFreqs = freqRange(end)-freqRange(1);

selRunEpochs = run.epochs; % in seconds
selRunIdx = run.index; % matching indices

lfp_time =[];
lfp_data = [];
countRuns = 0;

for iRun = 1:length(selRunEpochs)
    selRunStartIdx = selRunIdx(iRun,1);
    %nb this is to exclude first or last epoch that might fall outside the
    %window of interest)
    if abs(selRunStartIdx-ops.tw_ws) == selRunStartIdx-ops.tw_ws
        countRuns = countRuns + 1;
        %       if abs(lfp.timestamps(selRunStart)-ops.bl_ws) == lfp.timestamps(selRunStart)-ops.bl_ws
        lfp_time(:,countRuns) = lfp.timestamps(selRunStartIdx-ops.tw_ws:selRunStartIdx+ops.tw_ws);
        lfp_data(:,countRuns) = lfp.data(selRunStartIdx-ops.tw_ws:selRunStartIdx+ops.tw_ws);
    end
end

lfp_forWS.data = lfp_data;
lfp_forWS.timestamps = lfp_time;
lfp_forWS.samplingRate= 1250;

ws_temp         = bz_WaveSpec(lfp_forWS,'frange',freqRange,'nfreqs',numFreqs,'space','lin');
ws_temp.data    = abs(ws_temp.data);
ws_reshaped     = reshape(ws_temp.data,[length(ws_temp.timestamps),ws_temp.nfreqs,countRuns]);
wavespec_avg    = mean(ws_reshaped,3);

wavespec_epochs.ws_temp = ws_temp;
wavespec_epochs.avg = wavespec_avg;
end
