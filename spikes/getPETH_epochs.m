function [peth] = getPETH_epochs(basepath, varargin)
% getPETH = calculate PETHs around given epochs
%
%
%  USAGE
%
%    [peth] = getPETH(basepath,<options>)
%
%  INPUTS
%    
%  Name-value paired inputs:
%    'basepath'     - folder in which .spikes.cellinfo.mat can be found (required, Default
%                   is pwd)
%    'basename'     - basefile name to load
%    'epochs'       - [N x 2] matrix of epochs that PETH should be over
%                   centered around
%    'timwin'       - time window over which PETH should be
%                   calculated (Default: [-0.4 0.4])
%    'binSize'      - binSize in which spikes are binned in PETH 
%    'saveMat'      - 
%    'saveAs'       - File extension as a suffix to the basename for saving.
%                   Default: [basename '.peth.mat']
%
%  OUTPUT
%
%    peth           struct with a PETH around epochs events
%    .rate          [Nt x Nd] matrix of the LFP data
%    .count         [Nt x 1] vector of timestamps to match LFP data
%    .timeEdges     [] vector of timeEdges for rate and count histograms
%    .binSize       [1 x 2] vector of start/stop times of LFP interval
%    .timwin        time window, in seconds, of PETH

%
%  EXAMPLES
%  [peth] = getPETH_epochs(basepath,'epochs',pulseEpochs,'timwin',[-0.4 0.4], ...
%               'binSize', 0.01, 'saveAs', '.pethPulse.mat')
%  [peth] = getPETH_epochs(basepath,'saveMat',false)  
%   
%    
% NOTES
% 
%
% TO-DO
%
%
% HISTORY 
% 2020/12/4     Lianne documented and proofed this function
%
%

%% Parse! 
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'timwin',[-0.4 0.4],@isvector);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'binSize',0.01,@isnumeric);
addParameter(p,'epochs',0.01,@isnumeric);
addParameter(p,'saveAs','.peth.mat',@isstr);

parse(p,varargin{:});
basename        = p.Results.basename;
timwin          = p.Results.timwin;
saveMat         = p.Results.saveMat;
binSize         = p.Results.binSize;
epochs          = p.Results.epochs;
saveAs          = p.Results.saveAs;

%%
cd(basepath)
load([basename '.spikes.cellinfo.mat'],'spikes')

% Set parameters for PETHs
timeEdges   = timwin(1):binSize:timwin(2);

timeBefore  = abs(timwin(1));
timeAfter   = timwin(2);

trlCenteredEpochStart   = epochs(:,1)-timeBefore;
trlCenteredEpochStop    = epochs(:,1)+timeAfter;

trlCenteredEpoch = [trlCenteredEpochStart trlCenteredEpochStop];

% Align the spikes to be centered around epoch start

spike_toEpochStart = realignSpikes(spikes, trlCenteredEpoch);

% Calculate PETH centered around epoch start

peth.rate    = zeros(length(spikes.times), length(timeEdges)-1);
peth.count   = zeros(length(spikes.times), length(timeEdges)-1);


for iUnit = 1:length(spikes.times)
    
    spikeTrl = cell(1,length(epochs));
    for iEpoch = 1:length(epochs)
        spikeTrl{iEpoch} = spike_toEpochStart{iUnit}{iEpoch} - epochs(iEpoch,1);
    end
    
    countHisto  = histcounts(cell2mat(spikeTrl'),timeEdges);
    rateHisto   = countHisto/length(epochs)*1/binSize; %
    
    peth.rate(iUnit,:)   = rateHisto;
    peth.count(iUnit,:)  = countHisto;
    peth.trials{iUnit}   = spikeTrl;
end

peth.timeEdges = timeEdges;
peth.binSize = binSize;
peth.timwin  = timwin;


if saveMat
    save([basename saveAs],'peth')
end

end

