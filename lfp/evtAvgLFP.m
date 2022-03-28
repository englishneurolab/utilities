function [events] = evtAvgLFP(events,varargin)
%
% This function is meant to average the LFP signal over all input events
% for each specified channel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Dependencies
%    - Buzcode
%        - *.events.mat
%    - Cell Explorer
%        - session file from cell explorer
%    - lfp file
%    - current folder == folder with .lfp file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input
%    events     - Struct from buzcode containing .peaks and .timestamps
%    channels   - channels to get average LFP, base 0 
%                 (ex. [1 2 3 4], default = all)
%
%%%Options%%%
%    
%    'tWin'     - the time around each event to average in seconds
%                 (default = .5)
%    'channels' - channels to get average LFP, base 0 
%                 (ex. [1 2 3 4], default = all)
%    'evtName'  - string name of the events being input (ex. 'ripples')
%    'sr'       - sampling rate of .lfp (default = 1250)
%    'allEvents - logical of whether to collect all events (default = true)
%    'save'     - logical of whether to save output (default = true)
%    'plot'     - logical of whether to plot or not (default = true)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Usage
%
%    evtAvgLFP(ripples,'channels',[1 3 5 6],'tWin', 1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Todos
%    Add ability to specifiy specific events
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% History
% - (2021/12/16) Code written by Kaiser Arndt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse inputs
p = inputParser;
addParameter(p,'tWin',.5,@isnumeric);
addParameter(p,'plot',true,@islogical);
addParameter(p,'save',true,@islogical);
addParameter(p,'evtName',[],@isstring);
addParameter(p,'sr',1250,@isnumeric);
addParameter(p,'allEvents',true,@islogical);
addParameter(p,'channels',[],@isnumeric);

parse(p,varargin{:})

tWin      = p.Results.tWin;
plotLog   = p.Results.plot;
saveLog   = p.Results.save;
evtName   = p.Results.evtName;
sr        = p.Results.sr; 
allEvents = p.Results.allEvents;
channels  = p.Results.channels;

%% Load in files

basepath = cd;

basename = bz_BasenameFromBasepath(basepath);

load([basename '.session.mat']);


lfp = bz_GetLFP([channels]);



%% Calculate average
% 
% events.traces = cell(length(events.peaks),1);

run_sum = zeros(1,sr+1);% reserve staring matix to add to
events.traces = zeros(length(events.peaks),sr+1)
for ii = 1:length(events.peaks)
    
%     if allEvents
%         
%         [~,str] = min(abs(events.peaks(ii,1) - lfp.timestamps));
%         [~,stp] = min(abs(events.timestamps(ii,2) - lfp.timestamps));
%         
%         events.traces(ii) = {lfp.data(str:stp)};
%         
%         
%     end
    
    if events.peaks(ii) < tWin
        continue
    end
    if events.peaks(ii)+tWin > lfp.timestamps(end)
        continue
    end
    [~,idx] = min(abs((events.peaks(ii)-tWin) - lfp.timestamps));
    temp_evt = double(lfp.data(idx:idx+(sr*tWin*2)))';
    events.traces(ii,:) = temp_evt;
    run_sum = run_sum + temp_evt;
    
    
end
events.avgLFP = run_sum/ii;












































