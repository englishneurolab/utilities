for iPulse = length(pulseEpochs)
newStart = pulseEpochs(:,2);
newStop = pulseEpochs(:,1);
end

newStart = [0 ;newStart];
newStop = [newStop; time(end)];

noPulseTimes = [newStart newStop];