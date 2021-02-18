function cluster = getClusterQuality(basepath)
% calculate ISI violation
basename = bz_BasenameFromBasepath(basepath);
% load spikes
fname = [basepath filesep basename '.spikes.cellinfo.mat'];
if exist(fname)
    v=load(fname);
    spikes = v.spikes;
else
    cd(basepath)
    spikes = bz_GetSpikes;
end
nclu = length(spikes.times);
cluster.badISI = cellfun(@(a) mean(diff([nan;a])<.002),spikes.times)';
% calculate isolation distance


% get all good shanks
ushank = unique(spikes.shankID);
ushank = ushank(:)';
ix=1;
for i= ushank
    fetname  = [basepath filesep basename '.fet.' num2str(i)];
    cluname  = [basepath filesep basename '.clu.' num2str(i)];
    
    if exist(fetname) && exist(cluname)
        clu = load(cluname);
        
        clu = clu(2:end);
        
        
        %get unique clusters on shank
        
        uclu = unique(spikes.cluID(spikes.shankID==i));
        uclu = uclu(:)';
        Fet= LoadFeatures(fetname);
        
        if size(Fet,1) ~= size(clu,1)
            error(['clu has different number of spikes than fet'])
        end
        
        for j = uclu
            
            
            IsolDist(ix) = IsolationDistance(Fet(:,1:end-3),find(clu == j));
            LRatio(ix) = L_Ratio(Fet(:,1:end-3),find(clu == j));
            ix = ix+1;
        end
        cluster.IsolDist = IsolDist;
        cluster.LRatio=LRatio;
        
    else
        warning(['missing clu or fet'])
        cluster.IsolDist = nan(nclu,1);
        cluster.LRatio= nan(nclu,1);
    end
    
end

end

