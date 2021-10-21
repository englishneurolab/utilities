function plotCCG(ccg,t)




%%

for iUnit = 1:size(ccg,2)
    figure
    for nPlot = 1:size(ccg,3)
        subplot(round(sqrt(size(ccg,3)))+1,round(sqrt(size(ccg,3)))+1,nPlot)
        bar(t,ccg(:,iUnit,nPlot))
    end
end
