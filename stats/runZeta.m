function zeta = runZeta(basepath,event, varargin)
% This function is designed to 
%
%   USAGE
%
%   %% Dependencies %%%
% 	buzcode
%   ZETA Toolbox (in utilities\external)
%   https://github.com/JorritMontijn/ZETA
%
%   INPUTS
%   basepath    - path in which spikes and optostim structs are located
%
%   Name-value pairs:
%   'basename'  - only specify if other than basename from basepath
%   'saveMat'   - saving the results to [basename,
%                   '.burstMizuseki.analysis.mat']
%   'saveAs'    - if you want another suffix for your save
%   'timeBefore' -
%   'timeAfter' -  
%   'units' - 
%
%   OUTPUTS
%   zeta
%       .P              = p value output of getZeta;
%       .vecLatencies   = vecLatencies output of getZeta;
%       .sZeta          = sZETA output of getZeta;
%       .sRate          = sampleRate;
%       .UID            - unit ID from spikes
%
%
%   EXAMPLE
%
%   [zeta] = runZeta(basepath,optoStim.timestamps(:,1),'saveMat',true);
%   
%   HISTORY
%   2021/02 Lianne updated this
%
%
%   TO-DO
%   - Select over what Units you want do stats 
%
%
%% Parse!
%
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);
unitsValidation = @(x) isnumeric(x) || strcmp(x,'all');


p = inputParser;
addParameter(p,'basename',basename,@isstring);
addParameter(p,'saveMat',false,@islogical);
addParameter(p,'saveAs','.pethzeta.stats.mat',@isstring);
addParameter(p,'timeBefore',0.1,@isnumeric);  % 100 ms baseline
addParameter(p,'timeAfter',0.02,@isnumeric); % 20ms post event-on
addParameter(p,'units','all',@unitsValidation); % 


parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
saveAs          = p.Results.saveAs;
timeBefore      = p.Results.timeBefore;
timeAfter       = p.Results.timeAfter;
units           = p.Results.units;

totalDurWin     = timeBefore + timeAfter;

cd(basepath)
%%
% Load Spikes
spikes = bz_LoadPhy;

%%
if isnumeric(units)
    selUnits = units;
else
    selUnits = 1:length(spikes.UID);
end

for iUnit = selUnits
    %interval check
    [status,~] = InIntervals(spikes.times{iUnit},[event-timeBefore event-timeBefore+totalDurWin]);
    if sum(status~=0)
        [dblZetaP(iUnit),vecLatencies(iUnit,:), sZETA{iUnit},sRate{iUnit}] = getZeta(spikes.times{iUnit},event-timeBefore,totalDurWin,[],0);
    end
    
end

zeta.P              = dblZetaP;
zeta.vecLatencies   = vecLatencies;
zeta.sZeta          = sZETA;
zeta.sRate          = sRate;
zeta.UID            = spikes.UID;

if saveMat
    save([basename saveAs],'zeta')
end
end

