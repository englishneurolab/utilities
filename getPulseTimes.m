function [pulseEpochs] = getPulseTimes(analogin);

pulse = analogin.pulse;
ts = analogin.ts;

%% Finding depolarizations over time

diffPulse = diff(pulse);

% right now this value differs per session and that's not good 
posPulseIdx = diffPulse > 2;%0.3;%1;%.5*max(diffPulse); %  for m1 +- 0.2, fpr m122 +- 2
negPulseIdx = diffPulse < -2;%-0.3;%-1%-.5*max(diffPulse); % 


selPosPulseIdx  = find(posPulseIdx~=0);
selNegPulseIdx  = find(negPulseIdx~=0);

if selNegPulseIdx(1)<selPosPulseIdx(1)
    selNegPulseIdx(1)= [];
end

countNeg = 0;
countPos = 0;
for i = 1:length(selNegPulseIdx)-1
    if selNegPulseIdx(i+1) - selNegPulseIdx(i) < 10000 % want dat is 0.333 seconden)
        countNeg = countNeg+1;
        doubleIndNeg(countNeg) = selNegPulseIdx(i+1); 
    end
end

doubleIndPos = [];
doubleIndNeg = [];

for i = 1:length(selPosPulseIdx)-1
    if selPosPulseIdx(i+1) - selPosPulseIdx(i) < 10000 % want dat is 0.333 seconden)
        countPos = countPos+1;
        doubleIndPos(countPos) = selPosPulseIdx(i+1); 
    end
end


delIndxPos = find(ismember(selPosPulseIdx,doubleIndPos));
delIndxNeg = find(ismember(selNegPulseIdx,doubleIndNeg));
 selPosPulseIdx(delIndxPos) = [];
 selNegPulseIdx(delIndxNeg) = [];


pulseEpochs     = [ts(selPosPulseIdx+1)' ts(selNegPulseIdx+1)']; % +1 , because diff % pulse Time

end
