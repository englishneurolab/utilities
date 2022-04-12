function [evtPSD] = getEventPSD(basepath,events,channel,varargin)
% Create an event triggered PSD using Buzcode structured events.mat files 
%
%
%
% DEPENDENCIES
%  
%    Buzcode
%
% INPUTS
%
%    events---------------- Buzcode *.events.mat structure
%    channel--------------- Channel of the LFP file to load in  
%
% Optional
%
%    'twin'---------------- Time window to make PSD over in seconds
%                           Default = [-0.5 0.5]
%    'frange'-------------- Range of frequencies to plot calculate over 
%                           Default = [1 500]
%    'nfreqs'-------------- Number of frequencies to break the frange into
%                           Default = 500
%    'space'--------------- Spacing to use for the frequencies;'log' or 'lin'
%                           Default = 'log'
%    'subset'-------------- Logical the length of events, specifying subset
%                           to run PSD over Default = [] (all)
%    'saveMat'------------- Logical defining whether to save output to
%                           basepath Default = true
%
% OUTPUT
%
%    evtPSD.data----------- Average PSD over the event
%    evtPSD.freqs---------- All frequencies used in the PSD
%    evtPSD.nfreqs--------- Number of frequencies used
%    evtPSD.samplingRate--- Sampling rate on the PSD/ events
%    evtPSD.channels------- Channel in the LFP used to make the PSD
%    evtPSD.filterparms---- Metadata from bz_WaveSpec
%    evtPSD.eventsName----- Name of events into to the function
%
%
%% Parse inputs

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'twin',[-0.5 0.5],@isvector);
addParameter(p,'frange',[1 500],@isnumeric);
addParameter(p,'nfreqs',[500],@isnumeric);
addParameter(p,'space','log',@isstr);
addParameter(p,'subset',[],@islogical);
addParameter(p,'saveMat',true,@islogical);

parse(p,varargin{:});
twin       = p.Results.twin;
frange     = p.Results.frange;
nfreqs     = p.Results.nfreqs;
space      = p.Results.space;
subset     = p.Results.subset;
saveMat    = p.Results.saveMat;

%% Prep computation

lfp = bz_GetLFP(channel);

lfp = bz_whitenLFP(lfp);

sr = events.detectorinfo.detectionparms.frequency;

if ~isempty(subset)
    events.peaks = events.peaks(subset);
end

lfp_temp = lfp;

wavespec_tot_events = zeros(sum(abs(twin*sr))+1,nfreqs);


%% Compute event average wavespec

for selEvent = 1:length(events.peaks)
    
    ind = find(ismember(lfp.timestamps,events.peaks(selEvent)));
    indwin = twin*sr + ind;
    
    if indwin(1)<0 || indwin(2)>length(lfp.data)
        continue
    end
    
    lfp_temp.data = double(lfp.data(indwin(1):indwin(2)));
    lfp_temp.timestamps = lfp.timestamps(indwin(1):indwin(2));

    wavespec_event_temp = bz_WaveSpec(lfp_temp,'frange',frange,'nfreqs',nfreqs,'space',space);
    wavespec_event_temp.data = abs(wavespec_event_temp.data);
    wavespec_tot_events = wavespec_tot_events + wavespec_event_temp.data; 
    
end


%% package output

evtPSD.data         = wavespec_tot_events/length(events.peaks);
evtPSD.freqs        = wavespec_event_temp.freqs;
evtPSD.nfreqs       = wavespec_event_temp.nfreqs;
evtPSD.samplingRate = wavespec_event_temp.samplingRate;
evtPSD.channels     = wavespec_event_temp.channel;
evtPSD.filterparms  = wavespec_event_temp.filterparms;
evtPSD.eventsName   = inputname(2);

%% Save
if saveMat
    save([basename '.' inputname(2) 'evtPSD.mat'], 'evtPSD')
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    