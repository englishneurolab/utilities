function [evtGain] = getEvtGain(basepath,spikes,events)
%
% This function is meant to calculate the cells gain in firing rate to
% defined events, often opto stims or ripple events.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Dependencies
%    - Buzcode
%    - lfp file
%    - session file from cell explorer
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input
%    spikes ---- spikes struct from bz_LoadPhy output
%    events ---- [Nx2] list of [start stop] times of events to use
%
%%%Options%%%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output
%    evtGain.gain -- [1xN] list of gains for each cell 
%    evtGain.inFR -- [1xN] list of firing rates in events for each cell
%    evtGain.outFR - [1xN] list of firing rates out of events for each cell
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Usage
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Todos
%    Update to find FR in each event and report as output
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% History
% - (2022/05/16) Code written by Kaiser Arndt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load pieces

basename = bz_BasenameFromBasepath(basepath);

load([basename '.session.mat'])

%% Calc durations

sesDur = str2num(session.general.duration);

EvtDur = events(:,2) - events(:,1);

%% Calc Gain

[status,interval,~] = cellfun(@(c)InIntervals(c,events),spikes.times,'UniformOutput',false);

c = arrayfun(@(x)length(find(a == x)), unique(a), 'Uniform', false);
cell2mat(c)

evtCount = cellfun(@sum,status);



% 
% evtFR = evtCount/totEvtDur;
% 
% outEvtCount = cellfun(@(c)sum(~c),status);
% 
% outEvtFR = outEvtCount/(sesDur - totEvtDur);
% 
% gain = evtFR./outEvtFR;

%% Organize ouput


evtGain.gain  = gain;
evtGain.inFR  = evtFR;
evtGain.outFR = outEvtFR;
















