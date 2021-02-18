function [pulses] = makePulsesStruct(basename,pulseEpochs)
% This function is designed to 
%
%   USAGE
%
%   %% Dependencies %%%
%   
%   INPUTS
%   basepath    - path in which spikes and optostim structs are located
%
%   Name-value pairs:
%   'basename'  - only specify if other than basename from basepath
%   'saveMat'   - saving the results to 
%   'saveAs'    - if you want another suffix for your save
%
%   OUTPUTS
%   
%   
%   EXAMPLE
%   
%   
%   HISTORY
%
%   
%   TO-DO


%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);


p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);


parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;

%%

cd(basepath)
pulses.timestamps  = pulseEpochs;
pulses.peaks = (pulseEpochs(:,2)-pulseEpochs(:,1))/2;
pulses.amplitude = [];
pulses.amplitudeUnits = [];
pulses.eventID = ones(length(pulseEpochs),1);
pulses.eventIDlabels = cell(1,length(pulses.timestamps));
pulses.eventIDlabels(:) = {'OptoStim'};
% pulses.eventIDlabels: cell array with labels for classifying various event types defined in stimID (cell array, Px1).
% pulses.eventIDbinary: boolean specifying if eventID should be read as binary values (default: false).
pulses.center = pulses.peaks;%;
pulses.duration = pulseEpochs(:,2)-pulseEpochs(:,1);
pulses.detectorinfo = 'getPulseEpochs';

save(strcat(basename, '.pulses.events.mat'), 'pulses')
end
