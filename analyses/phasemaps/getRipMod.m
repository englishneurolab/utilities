function ripmod = getRipMod(basepath, varargin)

%   USAGE
%   [ripmod] = getRipMod(basepath,<options>)
%
%
%   DEPENDENCIES
%   
%
%
%   INPUTS
%   Name-Value pairs
%   'basename'          -
%   'saveMat'           -
%   'ccg'               -
%   'ccgBaseBins'       -
%   'binsAroundPeak'    -
%   'epochs'            -
%
%
%   OUTPUTS
%   ripmod
%   .mod
%   .time
%
%   EXAMPLES
%
%
%
%   NOTES
%
%
%
%   HISTORY
%   2020/12/05  Lianne pulled this out of the getPhaseMap
%   2020/12/08  Lianne documented this
%
%
%   TO-DO
%
%
%

%% Parse !
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'ccg',[],@isstruct);
addParameter(p,'ccgBaseBins', 1:4000,@isnumeric);
addParameter(p,'binsAroundPeak',50,@isnumeric);
addParameter(p,'epochs',[],@isnumeric);


parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
ccgBaseBins     = p.Results.ccgBaseBins;
binsAroundPeak  = p.Results.binsAroundPeak;
ripple_ccg      = p.Results.ccg;
gd_eps          = p.Results.epochs;

cd(basepath)
%%
if isempty(ripple_ccg)
    [ripple_ccg] = getRipCCG(basepath,spikes,'epochs',gd_eps,'ccgbin', 0.005,'ccgtotsamples',10001,'saveMat',false);
end

ripmod = [];
ccgPeakBin      = ripple_ccg.binlength/2; % to get center bin?

ripmod.mod = nanmean(ripple_ccg.ccg(:,ccgPeakBin - binsAroundPeak:ccgPeakBin+binsAroundPeak),2)...
    ./nanmean(ripple_ccg.ccg(:,ccgBaseBins),2);
ripmod.time       = binsAroundPeak*ripple_ccg.binsize;


end

