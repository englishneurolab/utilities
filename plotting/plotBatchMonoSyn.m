function plotBatchMonoSyn(cell_metrics,sessions_aligned)
% plotMonoSyn = plots monosynaptic connections
%
%
%  USAGE
%
%    getPETH(cell_metrics, sessions_aligned)
%
%  Dependencies
%    buzcode
%    cell explorer
%        - Batched cell_metrics output sessions
%    Anatomically aligned session
%    make active folder the batch folder
%    GetTransProb
%
%
%  INPUTS
%    cell_metrics     = batched output from cell explorer
%    sessions_aligned = all pieces from Align_Cell_Chans_Across_Sessions
%    
%
%  OUTPUT
%    figure = monosyn plot
%
%   
%    
%  NOTES
% 
%
%  TO-DO
%
% HISTORY 
% 2021/11/1     Created by Kaiser, code co-opted from Sam McKenzie function
%               plotConnectivityMap
%% load other components and calc transmission prob

homepath = cd;
load('Chanmap_H3_Acute.mat')
sig_con = cell_metrics.putativeConnections.excitatory;

trans = [];
cell_count = 0;
for i = 1:length(sessions_aligned.paths)
    cd(sessions_aligned.paths{i});
    basename = bz_BasenameFromBasepath(sessions_aligned.paths{i});
    load([basename '.mono_res.cellinfo.mat']);
    temp = [];
    for j = 1:size(mono_res.sig_con ,1)
        rawCCG = mono_res.ccgR(:,mono_res.sig_con(j,1),mono_res.sig_con(j,2));
        [temp(j),~,~,~] = GetTransProb(rawCCG',mono_res.n(j),mono_res.binSize,.015);
    end
    trans = [trans temp];

end

cd(homepath);




%%
%%

% Jitter measurements
x1 = sessions_aligned.chanDepthAligned + (rand(length(sessions_aligned.chanDepthAligned),1) * 5);
y1 = xcoords(sessions_aligned.AlignMaxWaveformChan) + (rand(length(sessions_aligned.chanDepthAligned),1) * 5);

bins = [0 logspace(-3,log10(.5),10) 1];

[~,b] = histc(trans,bins);
col = linspecer(length(bins),'jet');

figure
hold on
for i = 1:length(cell_metrics.cellID)
    if strcmp(cell_metrics.putativeCellType{i},'Pyramidal Cell')
        plot(x1(i),y1(i),'^','color','r', 'MarkerSize', 8)
    else
        plot(x1(i),y1(i),'o','color','k', 'MarkerSize', 8) 
    end
end

for i = 1:size(sig_con,1)
    
    plot([x1(sig_con(i,1)) x1(sig_con(i,2))],[y1(sig_con(i,1)) y1(sig_con(i,2))],'color',col{b(i)},'linewidth',3);%col{b(ix)},'linewidth',3)
    
end

camroll(90)
cmap = colormap(jet) ; %Create Colormap
cbh = colorbar ; %Create Colorbar
cbh.Ticks = linspace(0, 1, 12) ; %Create 8 ticks from zero to 1
cbh.TickLabels = num2cell(round(10*log10(bins))/10) ;
 
 
set(gca,'ydir','reverse')