function optmod = getOptoStim_Kaiser_edit(basepath,varargin)
% collects statistics of the cells recorded during stimulation periods (ccg, p-value,
% base firing rate, stimulation firing rate, measure of how much the firing rate is
% modulated, and which cells are significantly modulated by the stimulation).
%
%%% Dependencies %%%
%
% - buzocde compatible 
% - evt files are made and are named as basename.evt.ABC (.ABC is a 3 letter name of your choice)
% - evt.description fields are named using epoch identifier (ex. on/off, or start/stop) nomenclature and include the shank the stimulations were present on
%       - If only 1 shank/ fiber was stimulated it shouldn't matter the number
% - 
%
%%% Inputs %%%
% 
% - basepath = full path to the desired folder spikes and evt files are located
% - true/ false = state whether the stimulation pulse is occuring on the same shank as the recorded cells (spikes.shankID)
% - 'ABC' = the 3 letter file extension name of your choice for your .evt files
%
%%% Usage %%%
%
% optmod = getOptoStim_Kaiser(cd, false, 'ABC', 'on', 'off') %change when the name of te function is changed
%
% 
%%% To do's %%%
%
% - Make ccg bin sizes and ccg time window for the recording and input
% - Also set this to default values of .001 and 101 respectively
% - Set an output to be the options(your inputs)inputparser
% - Set default basepath/basename?
%
% Code originially written by Sam Mckenzie
% Code addapted/ edited by Kaiser Arndt (5/25/2020)
% Modified by Lianne Klaver 2020
% 
%
%%  Defaults

sameshank = true;

%% Set inputs

% This should be converted into an input parser

if ~isempty(varargin)
    sameshank = varargin{1};
    ext = varargin{2};
    on = varargin{3};
    off = varargin{4};
end

%% Get onset offsets

% Load in the .evt file with start and stop
fils  = getAllExtFiles(basepath,ext,1);
stims = LoadEvents(fils{1});


for j = 1:8 % Set to 8 for possible number of shanks used in recording, could be changed to be user input % soft code this to be read from .xml file for the recording
    
    % Loop through the evt file finding discrete start stop times and the corresponding shank number they were stimulated on
   % when units are stimmed at a certain shank and shank is in stim
   % description
   if strcmpi(on,'on')
    st{j} = unique([stims.time(cellfun(@(a) any(regexp(a,on)) & ...
        any(regexp(a,num2str(j))),stims.description)) ...
        stims.time(cellfun(@(a) any(regexp(a,off)) & ...
        any(regexp(a,num2str(j))),stims.description))],'rows');
    % place times in the corresponding columns
    
        st{j} = st{j}(diff(st{j},[],2)>0,:); % not confident what this does but it works :)

        
   elseif strcmpi(on,'start')
    % when that is not the case.
    if j>1 continue
    else 
    
    st{1} = unique([stims.time(cellfun(@(a) any(regexp(a,on)),stims.description)) ...
        stims.time(cellfun(@(a) any(regexp(a,off)) ,stims.description))],'rows');
    st{1} = st{1}(diff(st{1},[],2)>0,:); % not confident what this does but it works :)
    end
   end    
end

stimShank = find(~cellfun(@isempty,st)); % find the shanks that were used to stimulate by finding the filled columns
spikes = bz_GetSpikes;%('basepath',basepath); % load spikes
sessDur = max(cellfun(@max,spikes.times)); % get duration of the recording
ncel = length(spikes.times); % get number of cells
optmod = struct('ccg',nan(ncel,101),'p',nan(ncel,1),'baserate', nan(ncel,1) , 'stimrate', nan(ncel,1) ,'ratemod', nan(ncel,1) ,'optoMod', nan(ncel,1)); % reserve the space for optmod




%find modulation by stim
for i = stimShank 
    preStim = st{i}-diff(st{i},[],2)-.01; % not sure what this does
    
    if sameshank
        c = find(spikes.shankID==i);
    else
        c = spikes.UID;
    end
    
    
    for j = 1:length(c) % changed from j=c by Kaiser 5/31/20 due to bz_LoadPhy output only having spikes.UID output which corresponds to the actual cluster identifiers
        
        [~, interval] = InIntervals(spikes.times{j},st{i});
        stimR = histoc(interval(interval>0),1:size(st{i},1))./diff(st{i},[],2);
        [~, interval] = InIntervals(spikes.times{j},preStim);
        prestimRate = histoc(interval(interval>0),1:size(st{i},1))./diff(st{i},[],2);
        [optmod.p(j),~] = signtest(stimR,prestimRate);
        optmod.stimrate(j) = nanmean(stimR);
        
        optmod.ccg(j,:) = CrossCorr(st{i}(:,1),spikes.times{j},.001,101); 
        
        [status, ~] = InIntervals(spikes.times{j},MergeEpochs2(cell2mat(st')));
        optmod.baserate(j) = sum(~status)/(sessDur-sum(diff(MergeEpochs2(cell2mat(st')),[],2)));
        optmod.ratemod(j) = (optmod.stimrate(j) - optmod.baserate(j))/ optmod.baserate(j);
        optmod.optoMod(j) = optmod.p(j)<.001 & optmod.ratemod(j)>.5;
        
    end
end

optmod.timestamps = st;
optmod.UID = spikes.UID'; % Find a way to adjust for phy vs klusters structs

basename = bz_BasenameFromBasepath(basepath);
save([basename '.optmod.mat'], 'optmod')
