function burstIndex = burstinessMizuseki_epochs(basepath,varargin)
%
% This function is designed to get the burstiness Index out as specified by
% Mizuseki et al. 2012.
% By default we are looking at burstiness outside optogenetic stimulation,
% with an ISI of 6ms and a minimum of 2 spikes in a row to quantify a burst
%
%   USAGE
%   burstIndex = burstinessMizuseki_epochs(basepath, varargin)
%
%
%   %% Dependencies %%%
%   Dependent on buzcode for loading in and InIntervals
%
%   INPUTS
%   basepath    - path in which spikes and optostim structs are located
%
%   Name-value pairs:
%   'basename'  - only specify if other than basename from basepath
%   'proximityBurstSpikes' - ISI used for defining a burst (default: 0.006 (6ms bursts))
%   'saveMat'   - saving the results to [basename,
%                   '.burstMizuseki.analysis.mat']
%   'saveAs'    - if you want another suffix for your save
%   'epochs'    - [N x 2] matrix of concatenated epochs as a reference for burstiness
%                  'in' and 'out'
%   'epochName' - string variable as a label to store in burstIndex struct
%   'optoExcl'  - excluding optoStim in burstiness calculation (default:
%                   true)
%
%   OUTPUTS
%   burstIndex
%    .out       - burstiness outside the pulse
%    .in        - burstiness inside the pulse
%    .epochs    - other excluded epochs
%    .epochName - label to attach to excluded epochs
%
%   EXAMPLE
%    burstIndex = burstinessMizuseki_epochs(basepath,'epochs',runEpochs,'epochName', 'run5cms', 'saveMat',false)
%
%   HISTORY
%   2021/02 Lianne made this from CellExplorer examples
%
%   TO-DO
%   - savePath
%
%  % hahaha
%%
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
% set defaults
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'epochs',[],@isnumeric);
addParameter(p,'epochName',[], @isstr);
addParameter(p,'proximityBurstSpikes', 0.006, @isnumeric);
addParameter(p,'saveAs','.burstMizuseki.analysis.mat',@isstr);
addParameter(p,'optoExcl',true,@islogical);

% find name-value pairs input
parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
epochs          = p.Results.epochs;
saveAs          = p.Results.saveAs;
epochName       = p.Results.epochName;
proximBurstSpks = p.Results.proximityBurstSpikes;

cd(basepath)
%%

% Loading in the spikes
spikes = bz_LoadPhy;

% Check if we have optostim manipulation epochs, provided we want to remove
% them from our calculation

if optoExcl
    if exist([ basename '.optoStim.manipulation.mat'],'file')
        load([ basename '.optoStim.manipulation.mat'],'optoStim')
        
        % Get spikes outside of the optostim
        [status_opto ,~ , ~ ] = cellfun(@(a) InIntervals(a,optoStim.timestamps),...
            spikes.times,'UniformOutput', false);
        for iUnit = 1:length(spikes.times)
            spikesTimes{iUnit}   = spikes.times{iUnit}(~status_opto{iUnit});
        end
    else
        fprintf([basename '.optoStim.manipulation.mat does not exist.\n' ...
            'Continuing without excluding optostim epochs.\n'])
        spikesTimes  = spikes.times;
    end
else
    spikesTimes = spikes.times;
end


% Excluding other epochs

% NB this also works if 'epochs' is empty --> burstIndex.out will be empty
[status_epoch ,~ , ~ ] = cellfun(@(a) InIntervals(a,epochs), spikesTimes,'UniformOutput', false);

for iUnit = 1:length(spikes.times)
    spkTimOutEpochs{iUnit}  = spikesTimes{iUnit}(~status_epoch{iUnit});
    spkTimInEpochs{iUnit}   = spikesTimes{iUnit}(status_epoch{iUnit});
end


% Find the spikeTimes that are closer to each other than the specified ISI
% It calculates the fraction of spikes with a ISI for following or
% preceding spikes < 0.006

% I got this from Peter Petersen's code in CellExplorer's
% ProcessCellmetrics

% Calculate for spikes outside the specified epochs
for iUnit = 1:length(spkTimOutEpochs)
    for jj = 2:length(spkTimOutEpochs{iUnit})-1
        bursty(jj) =  any(diff(spkTimOutEpochs{iUnit}(jj-1 : jj + 1)) < proximBurstSpks);
    end
    burstIndexOUT(iUnit) = length(find(bursty > 0))/length(bursty);
end

% Calculate for spikes within the specified epochs
for iUnit = 1: length(spkTimInEpochs)
    bursty =[];
    for jj = 2:length(spkTimInEpochs{iUnit})-1
        bursty(jj) =  any(diff(spkTimInEpochs{iUnit}(jj-1 : jj + 1)) < proximBurstSpks);
    end
    burstIndexIN(iUnit) = length(find(bursty > 0))/length(bursty); % Fraction of spikes ...
    % with a ISI for following or preceding spikes < 0.006
end

% Store variables in a struct
burstIndex.out      = burstIndexOUT;
burstIndex.in       = burstIndexIN;
burstIndex.epochs   = epochs;
burstIndex.epochName = epochName;

% Save the variables
% Note that by default saveAs is [basename
% '.burstMizuseki.analysis.mat']

if saveMat
    save([basename saveAs],'burstIndex')
end


end

