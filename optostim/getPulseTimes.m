function [pulseEpochs] = getPulseTimes(analogin);
%getPulseTimes - get pulse times for fixed inteval pulses             
%
% USAGE
%    [pulseEpochs] = getPulseTimes(analogin)
%    
%    Locate the start and end times of the pulses
%
% INPUTS - note these are NOT name-value pairs... just raw values
%    analogin       struct containing pulse and ts
%	     	
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     
%    =========================================================================
%
% OUTPUT
%
%    pulseEpochs        matrix of two column vectors containing pulse start
%                       times and end times
%                   
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

%% Finding depolarizations over time
 selPosPulseIdx = [];
 selNegPulseIdx= [];

diffPulse = diff(abs(pulse)); 

% right now this value differs per session and that's not good see if
% implementation of SD criteria

pulseThreshold = 0.15; %0.15 %2 0.3;%1;%.5*max(diffPulse); %  for m1 +- 0.2, fpr m122 +- 2

posPulseIdx = diffPulse > pulseThreshold;
negPulseIdx = diffPulse < -pulseThreshold;

selPosPulseIdx  = find(posPulseIdx~=0);
selNegPulseIdx  = find(negPulseIdx~=0);

if selNegPulseIdx(1)<selPosPulseIdx(1)
    selNegPulseIdx(1)= [];
end

finNegPulseIdx = [];
finPosPulseIdx = [];

for i = 1:length(selPosPulseIdx)-1
    if abs(diffPulse(selPosPulseIdx(i)+1)) < 0.15 
        finPosPulseIdx = [finPosPulseIdx selPosPulseIdx(i)];
    end
end
% 
% for i = 1:length(selNegPulseIdx)-1
%     if abs(diffPulse(selNegPulseIdx(i)+1)) < 0.1 &&  ( ts(selPosPulseIdx(i))- ts(selNegPulseIdx(i))) < 0.1
%         finNegPulseIdx = [ finNegPulseIdx selNegPulseIdx(i)];
%     end
% end



countNeg = 0;
countPos = 0;

for i = 1:length(selNegPulseIdx)-1
    if selNegPulseIdx(i+1) - selNegPulseIdx(i) < 10000 % want dat is 0.333 seconden)
        countNeg = countNeg+1;
        doubleIndNeg(countNeg) = selNegPulseIdx(i+1); 
    end
end

% doubleIndPos = [];
% doubleIndNeg = [];
% 
% for i = 1:length(selPosPulseIdx)-1
%     if selPosPulseIdx(i+1) - selPosPulseIdx(i) < 10000 % want dat is 0.333 seconden)
%         countPos = countPos+1;
%         doubleIndPos(countPos) = selPosPulseIdx(i+1); 
%     end
% end
% 
% 
% delIndxPos = find(ismember(selPosPulseIdx,doubleIndPos));
% delIndxNeg = find(ismember(selNegPulseIdx,doubleIndNeg));
%  selPosPulseIdx(delIndxPos) = [];
%  selNegPulseIdx(delIndxNeg) = [];


pulseEpochs     = [ts(selPosPulseIdx+1)' ts(selNegPulseIdx+1)']; % +1 , because diff % pulse Time

end
