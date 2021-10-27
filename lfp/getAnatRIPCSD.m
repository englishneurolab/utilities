function [csd, lfpAvg] = getAnatRIPCSD
% 
%   This function creates event triggered CSD using the anatomical order of
%   channels 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Input
%        events      a string following the buzcode naming system for event
%                    names - basename.'events'.events.mat
%
%   Output 
%        Outlined in bz_eventCSD
%
%   Usages
%        [csd, lfpAvg] = getAnatEvtCSD('ripples')
%        [csd, lfpAvg] = getAnatEvtCSD('sharpwaves')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Todo:
%
%
%   Kaiser Arndt 21/2
%   bz_eventCSD from buzcode toolbox%
%
%


%% load lfp, event struct, and sessionInfor for channel layout

basename = bz_BasenameFromBasepath(cd);

lfp = bz_GetLFP('all');

load([basename '.ripples.events.mat']); %make this dependent on input 

load([basename '.sessionInfo.mat'])

%% make CSD

[csd, lfpAvg] = bz_eventCSD(lfp, ripples.peaks, 'channels', sessionInfo.AnatGrps.Channels + 1)