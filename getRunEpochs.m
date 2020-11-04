function [runEpochs, runIdx] = getRunEpochs(vel_cm_s, dt, minRun, time);

%something is going wrong, because runepochs do not span entire recording
% check with Reagan! 

% vel_cm_s from getVelocity
% minRun in cm_s 

thr = 10;% minRun/dt;

% runBins = find(vel_cm_s > thr);
% 
%  for iRun = 1:length(runBins)-1
%      logicRb(iRun) =  runBins(iRun) == runBins(iRun+1)-1; %dit gaat mis?
%      
%  end
 logicRb = vel_cm_s > thr;


 diff_Rb = diff(logicRb);%dit klopt niet gaat altijd van -1 direct naar 1 
 % wat als recording begint met rennen: startIdx = first timestamp
 
 runStartIdx = find(diff_Rb==1)+1;
 runStopIdx = find(diff_Rb==-1)+1;
 
 StartorStop = diff_Rb(diff_Rb~=0);
 if diff_Rb(1) == 0 && StartorStop(1) == -1
     runStartIdx = [1 runStartIdx];
 end
 if diff_Rb(end) == 0 && StartorStop(end) ==1
     runStopIdx=  [runStopIdx length(logicRb)];
 end
 
 runIdx = [runStartIdx' runStopIdx'];
 runEpochs = [time(runStartIdx)' time(runStopIdx)'];
end

 % als dier niet gestopt is met rennen aan het einde recording: stopIdx =
 % last timestamp
 
 