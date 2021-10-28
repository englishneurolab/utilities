function textChannels(basepath,varargin)

% This function is designed to plot the channel numbers as text with a colored dot
% next to a point of interest
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
%   'saveMat'   - saving the results to 
%   'saveAs'    - if you want another suffix for your save
%   'markerChans' - 
%
%   OUTPUTS
%   
%   
%   EXAMPLE
%   plotTextChannels(basepath, 'markerChans',[aacChan, ripChan])  
%
%   HISTORY
%
%   
%   TO-DO
%   % Make the number of dots you want to insert different
%
%
%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);


p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'saveAs','.peakRipChan.chaninfo.mat',@ischar)
addParameter(p,'markerChans',[],@isnumeric);



parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
saveAs          = p.Results.saveAs;
markerChans     = p.Results.markerChans;

cd(basepath)

%% Load in the variables

% load('rez.mat')
% chanMap = rez.ops.chanMap;
% xcoords = rez.xcoords;
% ycoords = rez.ycoords;
% chanMap0ind = chanMap-1;

load('chanMap.mat')

figure

text(xcoords,ycoords,num2str(chanMap0ind))
xlim([min(xcoords)-10, max(xcoords)+10])
ylim([min(ycoords)-10 ,max(ycoords)+10])
box off
xlabel('distance (um)')
ylabel('distance (um)')
if ~isempty(markerChans)
    % % text(xcoords,ycoords,num2str(chanMap0ind))
    % % xlim([min(xcoords)-10, max(xcoords)+10])
    % % ylim([min(ycoords)-10 ,max(ycoords)+10])
    
 
    
    markerColor = {'k','m','r','g','b','y'};
    for markerChan = 1:length(markerChans)
        plot(xcoords(markerChan)-1,ycoords(markerChan),'o','MarkerFaceColor',markerColor(markerChan))
    end
end
% % make 
% aacChanMap = chanMap == spikes.maxWaveformCh(iAAC)+1;
% ripChanMap = chanMap == rippleChan+1;
% % hold on
% % plot(xcoords(aacChanMap)-.5,ycoords(aacChanMap),'mo','MarkerFaceColor','m')
% % text(xcoords,ycoords,num2str(chanMap0ind))
% % xlim([min(xcoords)-10, max(xcoords)+10])
% % ylim([min(ycoords)-10 ,max(ycoords)+10])

% box off
% xlabel('distance (um)')
% ylabel('distance (um)')
% lloc = legend({'Ripple','AAC'},'Location','northoutside','Box','off','NumColumns',2);
end

