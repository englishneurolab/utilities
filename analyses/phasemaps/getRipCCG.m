function [ripple_ccg] = getRipCCG(basepath,spikes,varargin)

%   USAGE
%
%   DEPENDENCIES
%
%   INPUTS
%   basepath        -
%   spikes          -
%
%   Name-value pairs
%   'basename'      -
%   'epochs'        -
%   'saveMat'       -
%   'ccgbin'        -
%   'ccgtotsamples' -
%
%
%   OUTPUTS
%
%   EXAMPLES
%
%   NOTES
%
%   HISTORY
%
%   TO-DO
%   If no gd_eps --> gd_eps is entire session?


%% Parse !
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'ccgbin', 0.005,@isnumeric);
addParameter(p,'ccgtotsamples',10001,@isnumeric);
addParameter(p,'ccgdur',0.2,@isnumeric);
addParameter(p,'epochs',[],@isnumeric);



parse(p,varargin{:});
basename    = p.Results.basename;
saveMat     = p.Results.saveMat;
ccgbin      = p.Results.ccgbin;
ccgtotsamples = p.Results.ccgtotsamples;
ccgdur      = p.Results.ccgdur;
gd_eps      = p.Results.epochs;



%%
if isempty(gd_eps)
    disp('No gd_eps')
    % OR: gd_eps is entire session
end


% Get ripple CCGs
cid = [];
rip_ccg = [];
NN = [];
ix = 1;

load([basename '.ripples.events.mat'])
% rip = LoadEvents([basepath '/' basename '.evt.rip']);
% t   = rip.time(cellfun(@any,regexp(rip.description,'start')));
t = ripples.timestamps(:,1);

for j = 1:length(spikes.times)
    [status] = InIntervals(spikes.times{j},gd_eps);
    
    if isfield(spikes,'cluID')
        cid = [cid;spikes.shankID(j) spikes.cluID(j)];
    else
        cid = [cid;spikes.shankID(j) spikes.UID(j)];
    end
    
    rip_ccg(ix,:) = CrossCorr(t,spikes.times{j}(status),ccgbin,ccgtotsamples)/length(t);
%     rip_ccg(ix,:) = CCG(t,spikes.times{j}(status),'binSize',ccgbin,'duration',ccgdur,'norm','rate');
    NN(ix) = sum(status);
    ix = ix+1;
    
    
end

ripple_ccg.ccg          = rip_ccg;
ripple_ccg.binsize      = ccgbin;
ripple_ccg.binlength    = ccgtotsamples;
% ripple_ccg.ccgdur       = ccgdur;
ripple_ccg.ccglength     = ccgbin*(ccgtotsamples-1); % for plotting

%%
if saveMat
    % Check if file exists:
    fripccg = [basename '.ripple_ccg.mat'];
    
    if exist(fripccg,'file')
        overwrite = input([basename,'.ripple_ccg already exists. Overwrite? [Y/N] '],'s');
        switch overwrite
            case {'y','Y'}
                delete(fripccg)
            case {'n','N'}
                return
            otherwise
                error('Y or N please...')
        end
    end
    
    save([basename '.ripple_ccg.mat'],'ripple_ccg')
end

end
