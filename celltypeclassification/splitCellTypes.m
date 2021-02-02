function [pyrs, ints, aacs] = splitCellTypes(basepath)
% This function splits celltypes based off of cell_metrics as derived from
% CellExplorer
%
%   USAGE 
%
%   Dependencies: 
%   Buzcode, Englishlab\utilities,spikes.cellinfo.mat,
%   optoStim.manipulation.mat, cell_metrics.cellinfo.mat,
%   .dblZeta20_100_100.mat
%
%   INPUTS
%   basepath
%
%   Name-value paired inputs:
%
%   OUTPUTS
%
%
%   EXAMPLES
%
%
%   NOTES
%  
%
%   TO-DO
%   - maybe add an session.analysisTags for Opto ChR or Arch, considering the new animals are both ChR and Arch
%   - Move stats + getRatesTrialsBaseStim into the AAC functions   
%
%   HISTORY
%% 

cd(basepath)
basename = bz_BasenameFromBasepath(cd);

load([basename '.spikes.cellinfo.mat'])
load([basename '.cell_metrics.cellinfo.mat'])

if ~isempty(regexp(basename,'mouse', 'once')) % mouse-mice are excitation
    
    intsall = find(contains(cell_metrics.putativeCellType,'Interneuron'));
    aacs =  getAACind(basepath, 'excitation');
    intsind = ~ismember(intsall, aacs);
    ints = intsall(intsind);
    
elseif isempty(regexp(basename,'mouse', 'once')) % u and m have been inhibition (SO FAR)   
    intsall = find(contains(cell_metrics.putativeCellType,'Interneuron'));
    aacs    = getAACind(basepath,'inhibition');
    intsind = ~ismember(intsall, aacs);
    ints    = intsall(intsind);
end

pyrs = find(strcmpi(cell_metrics.putativeCellType,'Pyramidal Cell'));
pyrs = pyrs(~ismember(pyrs,aacs));

end
