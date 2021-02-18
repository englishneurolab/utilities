function GetCellParams(basepath)
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
%   'saveMat'   - saving the results to [basename,
%                   '.burstMizuseki.analysis.mat']
%   'saveAs'    - if you want another suffix for your save
%
%   OUTPUTS
%   
%   EXAMPLE
%   
%   HISTORY
%
%   TO-DO
%   - Check how to integrate with CellMEtrics from Peter
%   - Replace CrossCorr for buzcodes CCG?
%
%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);


p = inputParser;
addParameter(p,'basename',basename,@isstring);
addParameter(p,'saveMat',false,@islogical);
addParameter(p,'saveAs','_CellParams.mat',@isstring);

parse(p,varargin{:});

basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
saveAs          = p.Results.saveAs;

cd(basepath)

%% import spike data and get ACGs/ CCGs

spikes      = bz_GetSpikes;%('basepath',basepath,'saveMat',true,'forceReload',false);
mono_res 	= bz_GetMonoSynapticallyConnected(basepath,'plot',false);


%waveforms = LoadSpikeWaveforms(fil,length(xml.SpkGrps(i).Channels),xml.SpkGrps(i).nSamples;

%% find ripples and extract PETH

% Load Ripples
% if ripples doesn't exist make a ripple struct thingie?
% else
load([basename '.ripples.events.mat'])
% end


rip_ts  = ripples.peaks ;
rip_st  = ripples.timestamps(:,1);
rip_end = ripples.timestamps(:,2);

loner = rip_st(diff([0;rip_st])>.5); % select long ripples? what are we doing here
rip_peth = [];

for i = 1:length(spikes.times)
rip_peth(i,:) = CrossCorr(loner,spikes.times{i},.01,100);
end

else
    rip_peth = nan(length(spikes.times),101);
end

%% Get ACG fit parameters 

ACG_mat =[];paut=[]; 
idx = 1;
for j = 1:length(spikes.times)
    ACG_mat(idx,:) = 1000*(CrossCorr(spikes.times{j},spikes.times{j},.001,100)/length(spikes.times{j}));
    ACG_mat(idx,51) = 0;
        
    [fmodel,ydata,xdata,paut(idx,:)] = fitpyrint(ACG_mat(idx,:),0:50,0,20);
    idx = idx+1;
    
end

%% Calculate mean firing rate

Rate = []; 
for i=1:length(spikes.times)
    ISI2 = diff([spikes.times{i}; nan]);
    ISI1 = diff([nan;spikes.times{i}]);
    ISI = mean([ISI1 ISI2],2);
    Rate(i)=1/nanmean(ISI);
end
%% get cluster quality

cluster = getClusterQuality(basepath);  % maybe through cellexplorer?

%% save parameters into a structure



for uniti = 1:length(spikes.UID)
    CellParams(uniti).ShankID = spikes.shankID(uniti); 
    CellParams(uniti).CluID = spikes.cluID(uniti); 
    CellParams(uniti).Session = spikes.sessionName; 
   % CellParams(uniti).SpikeTimes = spikes.times{uniti}; 
    CellParams(uniti).ACG = mono_res.prob_noncor(:,uniti,uniti);
    
  
    CellParams(uniti).WaveForm =spikes.rawWaveform{uniti};
   
    CellParams(uniti).LocMaxWaveForm = spikes.maxWaveformCh; 
    CellParams(uniti).Rate = Rate(uniti); 
    CellParams(uniti).RipPETH = rip_peth(uniti,:); 
    CellParams(uniti).paut = paut(uniti,:); 
    CellParams(uniti).badISI = cluster.badISI(uniti); 
    CellParams(uniti).LRation = cluster.LRatio(uniti); 
    CellParams(uniti).IsoDist = cluster.IsolDist(uniti);
end


%% Detect monosynaptic connectivity

if ~isempty(mono_res.sig_con)
pre = unique(mono_res.sig_con(:,1));

for i = pre'
    CellParams(i).post = mono_res.sig_con(mono_res.sig_con(:,1)==i,2) ;
end


post = unique(mono_res.sig_con(:,2));

for i = post'
    CellParams(i).pre = mono_res.sig_con(mono_res.sig_con(:,2)==i,1) ;
end

end
    

%% save
if saveMat
    save([basepath filesep basename saveAs],'CellParams','mono_res');







