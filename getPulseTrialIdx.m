function [pulseIdx, noPulseIdx, pulseEpochs] = getPulseTrialIdx(analogin, tr_ep)

% now depends on trials, make it more robust for all pulses

pulse = analogin.pulse;
ts = analogin.ts;

%% Finding depolarizations over time

diffPulse = diff(pulse);
posPulseIdx = diffPulse > .5*max(diffPulse); %  for m1 +- 0.2, fpr m122 +- 2
negPulseIdx = diffPulse < -.5*max(diffPulse); % 

selPosPulseIdx  = find(posPulseIdx~=0);
selNegPulseIdx  = find(negPulseIdx~=0);

pulseEpochs     = [ts(selPosPulseIdx+1)' ts(selNegPulseIdx+1)']; % +1 , because diff % pulse Time

% tr_ep; % contains the start and stop of trial
% trlIdx of depolarization falls within trial y/n


countPulse = 0;

for iPulse = 1:length(pulseEpochs)
%     countPulse = countPulse+1;
    for iTr = 1:length(tr_ep)
        if pulseEpochs(iPulse,1) > tr_ep(iTr,1) && pulseEpochs(iPulse,2) < tr_ep(iTr,2)
        countPulse = countPulse+1;
               pulseIdx(countPulse) = iTr;
        else 
            continue
        end
    end
end

trialVec = 1:length(tr_ep);
noPulseIdx = trialVec(~ismember(trialVec,pulseIdx));

end
