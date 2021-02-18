for iUnit= 1:size(ccgNullIN{1},2)
    for iPair = 1:size(ccgNullIN{1},3)
        for iSh = 1:length(ccgNullIN)
            allNullIN(iSh,:) = ccgNullIN{iSh}(:,iUnit,iPair);
            allNullOUT(iSh,:) = ccgNullOUT{iSh}(:,iUnit,iPair);
        end
        
        %%
        significantBinsIN(:,iUnit,iPair) = ccgIN(:,iUnit,iPair)'>prctile(allNullIN,95) | ...
            ccgIN(:,iUnit,iPair)'<prctile(allNullIN,5);
        significantBinsOUT(:,iUnit,iPair) = ccgOUT(:,iUnit,iPair)'>prctile(allNullIN,95)|...
            ccgOUT(:,iUnit,iPair)'>prctile(allNullOUT,95);
        %%
    end
end

           
    