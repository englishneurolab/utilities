function [finPulseTimes] = PulseTimes(analogin,pulseLength, pulseThreshold);
%getPulseTimes - get pulse times for fixed inteval pulses             
%
% USAGE
%    [finPosPulseIdx] = fixedPulseTimes(analogin)
%    
%    Locate the start times of the pulses and estimate the finish time
%    by adding the pulse length to the start time
%
%
% INPUTS 
%    analogin       struct containing pulse and ts, shorted to cut out
%                   recording before pulses
%	 pulseLength    length of pulse in seconds, default to 0.1 s	
%   
%    pulseThreshold default: 0.15
%
%    
% OUTPUT
%
%    finPulseTimes      matrix of two column vectors containing pulse start
%                       times and end times
%
% TODO
%
%   for non-standard pulse lengths, develop an effective way to locate the
%   end of the pulses
%
pulse = analogin.pulse;
ts = analogin.ts;
pulseLength = pulseLength; %default 0.1 seconds
%% Finding depolarizations over time
 selPosPulseIdx = [];

diffPulse = diff(abs(pulse)); 

pulseThreshold = pulseThreshold;

% Threshold check one
posPulseIdx = diffPulse > pulseThreshold;
selPosPulseIdx  = find(posPulseIdx~=0);

% Make finPosPulseIdx 
finPosPulseIdx = [];
for i = 1:length(selPosPulseIdx)-1
    if abs(diffPulse(selPosPulseIdx(i)+1)) < 0.15 
        finPosPulseIdx = [finPosPulseIdx selPosPulseIdx(i)];
    end
end

% Convert back to times: the off times are estimated here using the on times and adding the length of the pulse
finPulseTimes = [(ts([finPosPulseIdx]))'  (ts([finPosPulseIdx])+pulseLength)'];
end