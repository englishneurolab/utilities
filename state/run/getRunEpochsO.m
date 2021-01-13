function [runEpochs, runIdx] = getRunEpochs(vel_cm_s, dt,time, thr);
%can add minRun as input - Reagan
%something is going wrong, because runepochs do not span entire recording
% check with Reagan! 

% vel_cm_s from getVelocity
% minRun in cm_s 

% runBins = find(vel_cm_s > thr);
% 
%  for iRun = 1:length(runBins)-1
%      logicRb(iRun) =  runBins(iRun) == runBins(iRun+1)-1; %this is going wrong?
%      
%  end
 logicRb = vel_cm_s > thr;


 diff_Rb = diff(logicRb);%this is not correct alaways goes from -1 directly to 1 
 % what if recording starts running: startIdx = first timestamp
 
 %% finding start and stop of running epochs
 runStartIdx = find(diff_Rb==1)+1;
 runStopIdx = find(diff_Rb==-1)+1;
 
 StartorStop = diff_Rb(diff_Rb~=0);
 if diff_Rb(1) == 0 && StartorStop(1) == -1
     runStartIdx = [1 runStartIdx];
 end
 if diff_Rb(end) == 0 && StartorStop(end) ==1
     runStopIdx=  [runStopIdx length(logicRb)];
 end
 
 %%_____Reagan______________
    if length(runStartIdx) > length(runStopIdx)
          %runStartIdx(end) = [];   %% Just get rid of 
          %OR: Stop at end of recording,
           runStopIdx(end+1) = max(time);
    end
 %___________________________
  
 runIdx = [runStartIdx' runStopIdx'];
 runEpochs = [time(runStartIdx)' time(runStopIdx)'];
end

 % if animal has not stopped running at the end of recording: stopIdx =
 % last timestamp
 
 