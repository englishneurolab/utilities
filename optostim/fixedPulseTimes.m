function [finPulseTimes, groups] = fixedPulseTimes(analogin,pulseLength);
%getPulseTimes - get pulse times for fixed inteval pulses             
%
% USAGE
%    [finPosPulseIdx] = fixedPulseTimes(analogin)
%    
%    Locate the start times of the pulses. The off times are estimated 
%    using the on times and adding the length of the pulse.
%
% INPUTS 
%    analogin       struct containing pulse and ts, shorted to cut out
%                   recording before pulses
%	 pulseLength    length of pulse in seconds, default to 0.1 s	
%
%
% OUTPUT
%
%    finPulseTimes      matrix of two column vectors containing pulse start
%                       times and end times
%     groupVec          Two column matrix containing indecies and group
%                       number
% 
% History
%  Lianne ----- 2021
%  Emma ---- 2/2/2022 Line 85: added absolute value to the diff of pulse
%           create finNegPulseIdx and finPosPulseIdx to filter out
%           artifacts
%           2/3/2022 finNegPulseIdx defined by finPosPulseIdx under assumption
%           of finPosPulseIdx accuracy and pulse length uniform
pulse = analogin.pulse;
ts = analogin.ts;
pulseLength = pulseLength; %default 0.1 seconds
%% Finding depolarizations over time
 selPosPulseIdx = [];

diffPulse = diff(abs(pulse)); 

pulseThreshold = 0.15; %0.15 %2 0.3;%1;%.5*max(diffPulse); %  for m1 +- 0.2, fpr m122 +- 2

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

%% Group Sort: 

i=1
j=1;
group1 = [];
group2 = [];
group3 = [];

for j = 1:length(diffPulse)
    for i = 1:length(finPosPulseIdx)
        if j == finPosPulseIdx(i) && 0.3 < diffPulse(j) && diffPulse(j)<= 0.6
            group1 = [group1  j];
        elseif j == finPosPulseIdx(i) && 0.6 <= diffPulse(j) && diffPulse(j)<= 1.1
            group2 = [group2  j];
         elseif j == finPosPulseIdx(i) && 1.1 <= diffPulse(j)
            group3 = [group3  j];
        end
    end
end

% Convert back to times: 
% the off times are estimated here using the on times and adding the length of the pulse
group1 = [(ts([group1]))'  (ts([group1])+pulseLength)'];
group2 = [(ts([group2]))'  (ts([group2])+pulseLength)'];
group3 = [(ts([group3]))'  (ts([group3])+pulseLength)'];


group1 = [group1  ones(length(group1),1)];
group2 = [group2  2*ones(length(group2),1)];
group3 = [group3  3*ones(length(group3),1)];

%Draft Struct: necessary for output of group sort, finPulseTimes contains
%groups 1-3, unsorted
groups.one = group1;
groups.two = group2;
groups.three = group3;
end