
%define paths
basepaths = dirN;




%%

%loop through and get all cell features
for i =  1%:length(basepaths)
    tic
    cd(dirN{i})
%     basepath = cd; basename=bz_BasenameFromBasepath(basepath);
    sl = regexp(basepaths{i},'/');
    basename = basepaths{i}(sl(end)+1:end);
    if ~exist([basepaths{i} '/' basename '_CellParams.mat'],'file')
        GetCellParams(basepaths{i})
    end
    toc
end



%%
%collect all cell features (delete celltype if it is defined)

CellParams =[];
for i = 1%:length(basepaths)
    basename = bz_BasenameFromBasepath(basepaths{i});
    fil = [basepaths{i} filesep  basename '_CellParams.mat'];
    
    v = load(fil);
    
    if isfield(v.CellParams,'cellType')
        v.CellParams = rmfield(v.CellParams,'cellType');
    end
    
    
    
    CellParams = [CellParams;v.CellParams'];
    i
end

%%
%collect all features

[sessions,~,SessionID] = unique({CellParams.Session}','stable');

cid = [SessionID cell2mat({CellParams.ShankID}') cell2mat({CellParams.CluID}')];
Rate = (cell2mat({CellParams.Rate}))';
ACG = cell2mat({CellParams.ACG})';
paut = cell2mat({CellParams.paut}');
LRation = cell2mat({CellParams.LRation})';
badISI = cell2mat({CellParams.badISI})';
WaveForm = cell2mat({CellParams.WaveForm}');
assymetry =[];width = [];
%optoMod = (cellfun(@(a) a.optoMod ,{CellParams.optoMod}))'==1;
wvAmp  =min(WaveForm,[],2);

for i = 1:size(WaveForm,1)
    
    wv = WaveForm(i,:)/max(WaveForm(i,:));
    [~,b1] = min(wv);
    [a] = max(wv(1:b1));
    [b] = max(wv(b1:end));
    assymetry(i,:) = (a-b)/(a+b);
    width(i,:) = ((find(wv<(min(wv))/2,1,'last') - find(wv<(min(wv))/2,1,'first')))/30000;
    WaveForm(i,:) = WaveForm(i,:)/max(WaveForm(i,:));
end

%nspk = cellfun(@length,{CellParams.SpikeTimes})';

%%

%smooth ACG

for i = 1:size(ACG,1)
    ACG1(i,:) =   smooth(ACG(i,:),10);
end
[~,modalISI] = max(ACG1(:,253:end),[],2);
%%

%now cluster into two clusters
close all
nclu = 2;
paut(paut(:,[2 ])<0,2) = 1e-6;

kp  = Rate>.1;
X = [Rate paut(:,[2 ]) assymetry width ];

X = nanzscore(X,[],1);
X = X(kp,:);
idx1 = kmeans(X,nclu,'MaxIter',1000);

idx = nan(length(Rate),1);
idx(kp) = idx1;

idx1 = idx;

%asign cluster with max neurons PYR (this assumption will break one day)
if sum(idx==1)<sum(idx==2)
    
    
    idx(idx1==1) = 2;
    idx(idx1==2) = 1;
    
end

%% now cluster again to split FS and RS INT

X = [ paut(:,1:4) Rate ];

X = nanzscore(X,[],1);


kp = idx==2;
idx2 = kmeans(X(kp,:),nclu,'MaxIter',1000);
idx2(idx2==1) = 3;
idx(kp) = idx2;

%%
%visualize

for i = 1:3
    figure
    
    imagesc(sortby(nanzscore(ACG(idx==i ,:),[],2),modalISI(idx==i,1)))
    
    
    
end
figure
for i = 1:3
    plot(nanmean(ACG(idx==i ,:)))
    hold on
end