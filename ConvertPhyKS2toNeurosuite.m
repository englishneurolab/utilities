function ConvertPhyKS2toNeurosuite(basepath,basename,ks_basepath)

%% WORK IN PROGRESS

% Converts Phy1 and kilosort1 or Phy2/kilosort2 output files into
% klusters-compatible fet,res,clu,spk files.  assumes a 16bit .dat,
% .xml file is present in "basepath" (home folder) and  that they are named
% basename.dat and basename.xml. It assumes that your directory is
% structured as follow:
%
% ###
% .
% +-- _folder(basename)
% |   +-- basename.dat
% |   +-- basename.xml
% |   +-- _Kilosort_date_time
% |   |   +-- spike_clusters.npy
% |   |   +-- spike_times.npy
% |   |   +-- cluster_group.tsv
% |   |   +-- pc_features.npy
% |   |   +-- templates.npy
% |   |   +-- rez.mat
% |   |   +-- cluster_ids.npy (ks1 only)
% |   |   +-- shanks.npy (ks1 only)
% |   |   +-- cluster_info.tsv (ks2 only)
%
% ###
%
% KILOSORT1/PHY1 USERS:
% cluster_ids.npy and shanks.npy are generated by a phy1 plugin
% -Export Shanks- found in this link https://github.com/petersenpeter/phy-plugins)
%
% KILOSORT2/PHY2 USERS:
% The output of kilosort2 and phy2 are enough for this code to run. Your
% structure of session/folders should be the same as shown above
%
% Inputs:
%   basepath    -  directory path to the main recording folder with .dat and .xml
%                  as well as kilosort folder generated by Kilosortwrapper
%   basename    -  shared file name of .dat and .xml (default is last part of
%                  current directory path, ie most immediate folder name)
%   ks_basepath - directory containing
%
%
% Eliezyer de Oliveira, 2018
%
% - reviewed in 11/2019 - added the functionality to convert also the  outputs of phy2
% - Minor bugfixes by Lianne Klaver 08/2020 to make it work with phy2/ks2
% outputs.


if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end
savepath = basepath;

% p = inputParser;
% addParameter(p,'kilosort2',true,@islogical)
% parse(p,varargin{:})


%finding the last Kilosort folder in order
if exist('ks_basepath','var')
    KSdir = ks_basepath;
else
    auxDir = dir;
    auxKSD = find([auxDir.isdir]);
    for i = auxKSD
        if strfind(auxDir(i).name,'ks2') % or: Kilosort
            KSdir = auxDir(i).name;
        end
    end
end

%loading phy files
cd(fullfile(basepath,KSdir));

if ~exist('rez','var')
    load(fullfile(basepath,KSdir,'rez.mat'))
end


par = LoadParameters(fullfile([basepath],[basename '.xml'])); %this is load differently the xml file than before (EFO 3/3/2019)

totalch = par.nChannels;
sbefore = 16;%samples before/after for spike extraction
safter = 16;%... could read from SpkGroups in xml
if isfield(par,'SpkGrps')
    if isfield(par.SpkGrps,'nSamples')
        if ~isempty(par.SpkGrps(1).nSamples);
            if isfield(par.SpkGrps,'PeakSample')
                if ~isempty(par.SpkGrps(1).PeakSample);
                    sbefore = par.SpkGrps(1).PeakSample;
                    safter = par.SpkGrps(1).nSamples - par.SpkGrps(1).PeakSample;
                end
            end
        end
    end
end

if exist(rez.ops.fbinary,'file')
    datpath = rez.ops.fbinary;
else
    datpath = fullfile(basepath,[basename '.dat']);
end

%% identify timestamps that are from good clusters
clusters = readNPY('spike_clusters.npy');
S = tdfread('cluster_group.tsv');
group = S.group;
cluster_id = S.cluster_id;

%getting good clusters only
GClusters = strfind(group(:,1)','g');
ExtClus = cluster_id(GClusters);

% Separating idx by cluster
auxiliarC = find(ismember(clusters,ExtClus));
%% getting spike information

spktimes = uint64(readNPY('spike_times.npy'));
spktimes = spktimes(auxiliarC);
clu = uint32(readNPY('spike_clusters.npy'));
clu = clu(auxiliarC);
pcFeatures = readNPY('pc_features.npy');
pcFeatures = pcFeatures(auxiliarC,:,:);
% pcFeatureInds = uint32(readNPY('pc_feature_ind.npy'))';
% templates = readNPY('templates.npy');


cluster_info = tdfread('cluster_info.tsv');
clu_channels = cluster_info.channel;
shanks = zeros(size(clu_channels));

for s = 1:length(par.spikeGroups.groups)
    temp1 = ismember(clu_channels,par.spikeGroups.groups{s});
    shanks(temp1) = s;
end

cluShank = cluster_info.id; %this is just the ID of the cluster, bad naming that needs change.

cd(basepath)
folder_name = 'Phy2Clus';

mkdir(fullfile(savepath,folder_name))


%% assigning cluster ids to shanks

auxC = unique(clu);
templateshankassignments = zeros(size(auxC));
for idx = 1:length(auxC)
    temp = find(cluShank == auxC(idx));
    templateshankassignments(idx) = shanks(temp);
end
grouplookup = rez.ops.kcoords;
allgroups = unique(grouplookup);
allgroups(allgroups==0) = [];

for groupidx = 1:length(allgroups)
    
    %if isfield(par.SpkGrps(groupidx),'Channels')
    %if ~isempty(par.SpkGrps(groupidx).Channels)
    % for each group loop through, find all templates clus
    tgroup          = allgroups(groupidx);%shank number
    ttemplateidxs   = find(templateshankassignments==tgroup);%which templates/clusters are in that shank
    %     ttemplates      = templates(:,:,ttemplateidxs);
    %     tPCFeatureInds  = pcFeatureInds(:,ttemplateidxs);
    
    tidx            = ismember(clu,auxC(ttemplateidxs));%find spikes indices in this shank
    tclu            = clu(tidx);%extract template/cluster assignments of spikes on this shank
    tspktimes       = spktimes(tidx);
    
    gidx            = find(rez.ops.kcoords == tgroup);%find all channels in this group
    channellist     = [];
    
    
    for ch = 1:length(par.spikeGroups.groups{groupidx})
        if sum(ismember(gidx,par.spikeGroups.groups{groupidx}(:)+1))
            channellist = par.spikeGroups.groups{groupidx}(:)+1;
            break
        end
    end
    if isempty(channellist)
        disp(['Cannot find spkgroup for group ' num2str(groupidx) ])
        continue
    end
    
    %% spike extraction from dat
    if groupidx == 1;
        dat             = memmapfile(datpath,'Format','int16');
    end
    tsampsperwave   = (sbefore+safter);
    ngroupchans     = length(channellist);
    valsperwave     = tsampsperwave * ngroupchans;
    wvforms_all     = zeros(length(tspktimes)*tsampsperwave*ngroupchans,1,'int16');
    wvranges        = zeros(length(tspktimes),ngroupchans);
    wvpowers        = zeros(1,length(tspktimes));
    
    for j=1:length(tspktimes)
        try
            w = dat.data((double(tspktimes(j))-sbefore).*totalch+1:(double(tspktimes(j))+safter).*totalch);
            wvforms=reshape(w,totalch,[]);
            %select needed channels
            wvforms = wvforms(channellist,:);
            %         % detrend
            %         wvforms = floor(detrend(double(wvforms)));
            % median subtract
            wvforms = wvforms - repmat(median(wvforms')',1,sbefore+safter);
            wvforms = wvforms(:);
            
        catch
            disp(['Error extracting spike at sample ' int2str(double(tspktimes(j))) '. Saving as zeros']);
            disp(['Time range of that spike was: ' num2str(double(tspktimes(j))-sbefore) ' to ' num2str(double(tspktimes(j))+safter) ' samples'])
            wvforms = zeros(valsperwave,1);
        end
        
        %some processing for fet file
        wvaswv = reshape(wvforms,tsampsperwave,ngroupchans);
        wvranges(j,:) = range(wvaswv);
        wvpowers(j) = sum(sum(wvaswv.^2));
        
        lastpoint = tsampsperwave*ngroupchans*(j-1);
        wvforms_all(lastpoint+1 : lastpoint+valsperwave) = wvforms;
        %     wvforms_all(j,:,:)=int16(floor(detrend(double(wvforms)')));
        if rem(j,100000) == 0
            disp([num2str(j) ' out of ' num2str(length(tspktimes)) ' done'])
        end
    end
    wvranges = wvranges';
    
    %% Spike features
    %     for each template, rearrange the channels to reflect the shank order
    tdx = [];
    for tn = 1:size(pcFeatures,3)
        %         %         tTempPCOrder = tPCFeatureInds(:,tn);%channel sequence used for pc storage for this template
        for k = 1:length(channellist);
            %             %             i = find(tTempPCOrder==channellist(k));
            if ~isempty(k)
                tdx(tn,k) = k;
            else
                tdx(tn,k) = nan;
            end
            %
        end
    end
    
    featuresperspike = 3; % kilosort default
    
    % initialize fet file
    fets    = zeros(sum(tidx),size(pcFeatures,2),size(pcFeatures,3));
    pct     = pcFeatures(tidx,:,:);
    
    %for each cluster/template id, grab at once all spikes in that group
    %and rearrange their features to match the shank order
    allshankclu = unique(tclu);
    
    for tc = 1:length(allshankclu)
        tsc     = allshankclu(tc);
        i       = find(tclu==tsc);
        tforig  = pct(i,:,:);%the subset of spikes with this clu ide
        tfnew   = tforig; %will overwrite
        
        ii      = tdx(tc,:);%handling nan cases where the template channel used was not in the shank
        gixs    = ~isnan(ii);%good vs bad channels... those shank channels that were vs were not found in template pc channels
        bixs    = isnan(ii);
        g       = ii(gixs);
        
        tfnew(:,:,gixs) = tforig(:,:,gixs);%replace ok elements
        tfnew(:,:,bixs) = 0;%zero out channels that are not on this shank
        try
            fets(i,:,1:length(par.spikeGroups.groups{groupidx})) = tfnew(:,:,1:length(par.spikeGroups.groups{groupidx}));
        catch
            keyboard
        end
    end
    %extract for relevant spikes only...
    % and heurstically on d3 only take fets for one channel for each original channel in shank... even though kilosort pulls 12 channels of fet data regardless
    tfet1 = squeeze(fets(:,1,1:size(pct,3)));%lazy reshaping
    tfet2 = squeeze(fets(:,2,1:size(pct,3)));
    tfet3 = squeeze(fets(:,3,1:size(pct,3)));
    fets = cat(2,tfet1,tfet2,tfet3)';%     fets = h5read(tkwx,['/channel_groups/' num2str(shank) '/features_masks']);
    %     fets = double(squeeze(fets(1,:,:)));
    %mean activity per spike
    %     fetmeans = mean(fets,1);%this is pretty redundant with wvpowers
    %     %find first pcs, make means of those...
    %     featuresperspike = 4;
    %     firstpcslist = 1:featuresperspike:size(fets,1);
    %     firstpcmeans = mean(fets(firstpcslist,:),1);
    %
    %     nfets = size(fets,1)+1;
    %     fets = cat(1,fets,fetmeans,firstpcmeans,wvpowers,wvranges,double(tspktimes'));
    fets = cat(1,double(fets),double(wvpowers),double(wvranges),double(tspktimes'));
    fets = fets';
    % fets = cat(1,nfets,fets);
    
    %% writing to clu, res, fet, spk
    
    cluname = fullfile(savepath, [basename '.clu.' num2str(tgroup)]);
    resname = fullfile(savepath, [basename '.res.' num2str(tgroup)]);
    fetname = fullfile(savepath, [basename '.fet.' num2str(tgroup)]);
    spkname = fullfile(savepath, [basename '.spk.' num2str(tgroup)]);
    %fet
    SaveFetIn(fetname,fets);
    
    %clu
    % if ~exist(cluname,'file')
    tclu = cat(1,length(unique(tclu)),double(tclu));
    fid=fopen(cluname,'w');
    %     fprintf(fid,'%d\n',clu);
    fprintf(fid,'%.0f\n',tclu);
    fclose(fid);
    clear fid
    % end
    
    %res
    fid=fopen(resname,'w');
    fprintf(fid,'%.0f\n',tspktimes);
    fclose(fid);
    clear fid
    
    %spk
    fid=fopen(spkname,'w');
    fwrite(fid,wvforms_all,'int16');
    fclose(fid);
    clear fid
    
    disp(['Shank ' num2str(tgroup) ' done'])
    %end
    %end
end
clear dat
copyfile(fullfile(savepath, [basename,'.clu.*']),fullfile(savepath, folder_name)) %makes a copy of the original clu files


function SaveFetIn(FileName, Fet, BufSize);

if nargin<3 | isempty(BufSize)
    BufSize = inf;
end

nFeatures = size(Fet, 2);
formatstring = '%d';
for ii=2:nFeatures
    formatstring = [formatstring,'\t%d'];
end
formatstring = [formatstring,'\n'];

outputfile = fopen(FileName,'w');
fprintf(outputfile, '%d\n', nFeatures);

if isinf(BufSize)
    
    temp = [round(100* Fet(:,1:end-1)) round(Fet(:,end))];
    fprintf(outputfile,formatstring,temp');
else
    nBuf = floor(size(Fet,1)/BufSize)+1;
    
    for i=1:nBuf
        BufInd = [(i-1)*nBuf+1:min(i*nBuf,size(Fet,1))];
        temp = [round(100* Fet(BufInd,1:end-1)) round(Fet(BufInd,end))];
        fprintf(outputfile,formatstring,temp');
    end
end
fclose(outputfile);