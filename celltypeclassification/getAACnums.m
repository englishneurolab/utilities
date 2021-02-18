function aacs = getAACnums(cell_metrics,statsP,stimtype,inclusionInd, varargin)
% This function
%
%   USAGE
%
%   Dependencies:
%
%
%   INPUTS
%   cell_metrics    - output CellExplorer
%   statsP          - p-values for each unit in spikes
%   stimType        -'INH' or 'EXC'
%   inclusionInd    - logical, preDetermined inclusion criteria
%                       (e.g. ratemod in right direction)
%
%   Name-value paired inputs:
%   alpha            - Default p = 0.01;

%
%
%   OUTPUTS
%
%
%   EXAMPLES
%
%
%   NOTES
%   Determining the AACs based off significance, inclusioncriteria (e.g.
%   rate), and putative celltype
%
%   TO-DO
%   - maybe add an session.analysisTags for Opto ChR or Arch, considering the new animals are both ChR and Arch
%   Make sure your stimType is somewhere in the metadata, to be loaded in
%   really%
%
%   HISTORY
%   2020/12/11 deprecated? newer version with inclusion criteria in it
%
%
%
%% Parse!
p = inputParser;
addParameter(p,'saveMat',false,@islogical);
addParameter(p,'alpha',0.01,@isnumeric);
addParameter(p,'statsP',0.01,@isnumeric);


parse(p,varargin{:});
alpha         = p.Results.statsP;
saveMat       = p.Results.saveMat;

%%

if strcmpi(stimtype,'INH') || strcmpi(stimtype,'inhibition')
    %      aacs = find(cell_metrics.optoStim_modulationIndex<modL & ...
    %          cell_metrics.optoStim_modulationIndex ~= Inf &...
    aacs = find(...
        statsP<alpha & inclusionInd... % must be either upmodulated or downmodulated
        &  contains(cell_metrics.putativeCellType,'Interneuron')) ;
    
    
elseif strcmpi(stimtype,'EXC') || strcmpi(stimtype,'excitation')
    %     aacs = find(cell_metrics.optoStim_modulationIndex>modH &  ...
    %         cell_metrics.optoStim_modulationIndex ~= Inf &...
    aacs = find(...
        statsP<alpha & inclusionInd... % must be either upmodulated or downmodulated
        & contains(cell_metrics.putativeCellType,'Interneuron'));
    
    
    
end

end
