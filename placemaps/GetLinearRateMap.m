function [rm_raster,rm_ep,rm] = GetLinearRateMap(spks,ts,pos,eps,bins,k,dt)
%spks = vector of spike times
%ts =  time stamps (Nx1) for position
%pos = linearized position (Nx1)
%eps = [start stop] times for each trial  
%bins = position bin edges
%k = std. dev. of the Gaussian smoothing kernel
%dt = sampling rate of position (time/frame)

eps = sortrows(eps);
rm_raster = {};
rm_ep = nan(size(bins));
rm = nan(size(bins));


if ~isempty(eps)
    [status,interval] = InIntervals(spks,eps);
    
    n1 = histoc(interval(interval>0),1:size(eps,1));
    spks = spks(status);
    [~,b] = histc(spks,ts);
    len = nan(size(spks,1),1);
    len(b>0) = pos(b(b>0));
    rm_raster = mat2cell( len,n1);
    [status,interval] = InIntervals(ts,eps);
    
    n1 = histoc(interval(interval>0),1:size(eps,1));
    pos = pos(status);
    
    
    
    if ~isempty(pos)
        pos_raster = mat2cell( pos,n1);
        
        rm_ep = cell2mat(cellfun(@(a) nanconvn(histoc(a,bins),k)',rm_raster,'uni',0));
        occ_ep = cell2mat(cellfun(@(a) nanconvn(histoc(a,bins),k)',pos_raster,'uni',0));
        %occ_ep(occ_ep<1) = nan;
        rm = nansum(rm_ep,1)./nansum(occ_ep,1) * dt;
        rm_ep = (rm_ep./occ_ep)*dt;
        
        
    end
end
end


