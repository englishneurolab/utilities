function [events] = makePulseFile(basepath,varargin)
%
%   Make an .evt.ait file to read into Neuroscope
%
%   USAGE
%
%   %% Dependencies %%%
%
%
%   INPUTS
%   'basename'      - Default: bz_BasenameFromBasepath)
%   'numEvents'     - Default:2
%   'epochs'        - []

%
%   OUTPUTS
%
%   EXAMPLE
%   [events] = makePulseFile(basepath,'epochs',pulseEpochs)
%
%
%   HISTORY
%   2020/12/7 Lianne made this into a function
% 
%   TO-DO
%   Figure out what "you need the ROX bc neuroscope is buggy and uses this
%   to parse files" means
%   Include input : %   'description'   - Default: {'start','stop'}
%   'pulseType'     - required !!! (Default:'square', for a block pulse).



%% Parse!
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'numEvents',2,@isnumeric);
addParameter(p,'epochs',[],@isnumeric);
addParameter(p,'saveMat',true,@islogical);

parse(p,varargin{:});
numEvents    = p.Results.numEvents;
pulseEpochs  = p.Results.epochs;
saveMat      = p.Results.saveMat;

cd(basepath)
%%
numeventtypes = numEvents;
pulseFile = [basename '.evt.ait'];

if saveMat
    if exist(pulseFile,'file')
        overwrite = input([basename,'.evt.ait already exists. Overwrite? [Y/N] '],'s');
        switch overwrite
            case {'y','Y'}
                delete(pulseFile)
            case {'n','N'}
                return
            otherwise
                error('Y or N please...')
        end
    end
end

lengthAll                   = length(pulseEpochs)*numeventtypes;
events.time                 = zeros(1,lengthAll);
events.time(1:2:lengthAll)  = pulseEpochs(:,1);
events.time(2:2:lengthAll)  = pulseEpochs(:,2);

% Populate events.description field
events.description                  = cell(1,lengthAll);
events.description(1:2:lengthAll)   = {'start'};
events.description(2:2:lengthAll)   = {'stop'};

if saveMat
    % Save .evt file for viewing in neuroscope - will save in your current directory
    SaveEvents(fullfile(cd,pulseFile),events)
end
