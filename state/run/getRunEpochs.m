function [run] = getRunEpochs(basepath,vel,varargin);
% This function is designed to get the continous velocity in cm/s from the
% analogin.dat file.
%
%   USAGE
%
%   %% Dependencies %%%
%
%
%   INPUTS
%   'vel'  - output from getVelocity.m
%   'minRunSpeed' - min runspeed to take into account
%
%   OUTPUTS
%   runEpochs
%   runIdx
%
%   EXAMPLE
%   [run] = getRunEpochs(basepath,vel,'minRunSpeed',1.5,'saveMat','false')
%
%   HISTORY
%   2020/09 Lianne documented and proofed this function
%   2020/11 Reagan edit 
%   2020/12 Lianne verify and edit
%
%
%   TO-DO
%   - Make it so the function detects whether the wheel is going from plus
%   to minus or vice versa
%   - Normalize wheel trials so thresholding will be more uniform
%   - Add a minRunLength?
%%

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'minRunSpeed',[],@isnumeric);
addParameter(p,'saveAs','.run.states.mat',@isstr);


parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
thr             = p.Results.minRunSpeed;
saveAs          = p.Results.saveAs;

cd(basepath)

vel_cm_s    = vel.vel_cm_s;
time        = vel.time;
dt          = vel.dt;
%%

logicRb = vel_cm_s > thr;
diff_Rb = diff(logicRb); %this is not correct alaways goes from -1 directly to 1

% what if recording starts running: startIdx = first timestamp

%% finding start and stop of running epochs
runStartIdx = find(diff_Rb==1)+1;
runStopIdx = find(diff_Rb==-1)+1;

StartorStop = diff_Rb(diff_Rb~=0);
if ~isempty(runStartIdx)
    if diff_Rb(1) == 0 && StartorStop(1) == -1
        runStartIdx = [1 runStartIdx];
    end
    if diff_Rb(end) == 0 && StartorStop(end) ==1
        runStopIdx=  [runStopIdx length(logicRb)];
    end
    
    %%_____Reagan______________
    % if more starts than stops, introduce end of recording as stop
    if length(runStartIdx) > length(runStopIdx)
        runStopIdx(end+1) = max(time);
    end
    %___________________________
    
    runIdx = [runStartIdx' runStopIdx'];
    runEpochs = [time(runStartIdx)' time(runStopIdx)'];
else
    runEpochs = [NaN NaN];
    runIdx = [NaN NaN];
end
%%

% for backward compatibility with current code
run.epochs = runEpochs;
run.index = runIdx;

% for compatibility with buzcode
run.ints.run = run.epochs;
run.detectorinfo.detectorname = 'getRunEpochs.m';
run.detectorinfo.detectionparms.minRunSpeed = thr;
run.detectorinfo.detectiondate = today('datetime');

% run.idx.states = %[t x 1] vector giving the state at each point in time
% run.idx.timestamps = %[t x 1] vector of times for each timepoint in idx.states
% run.idx.statenames = %{Nstates} cell array for the name of each state
%%

if saveMat
    % Check if file exists:
    frun = [basename saveAs];
    
    if exist(frun,'file')
        overwrite = input([basename, saveAs ' already exists. Overwrite? [Y/N] '],'s');
        switch overwrite
            case {'y','Y'}
                delete(frun)
            case {'n','N'}
                return
            otherwise
                error('Y or N please...')
        end
    end
    
    save([basename saveAs],'run')
end
end

