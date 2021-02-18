function plotTextChannels(basepath,varargin)

% This function is designed to plot the channel numbers as text with a colored dot
% next to a point of interest 
%
%   USAGE
%
%   %% Dependencies %%%
%   It loads in a chanMap.mat, which should be located in the basepath and 
%   contains at a minimum the following variables:
%   chanMap     -   [nChannels x 1] with the channel numbers (1-based) 
%   xcoords     -   [nChannels x 1] with the corresponding channels' 
%                   x coordinate in um
%   ycoords     -   [nChannels x 1] with the corresponding channels' y
%                   coordinates in um 
%
%
%   INPUTS
%   basepath    - path in which spikes and optostim structs are located
%
%   Name-value pairs:
%   'basename'  - only specify if other than basename from basepath
%   'saveMat'   - saving the results to 
%   'saveAs'    - if you want another suffix for your save
%   'markerChans' - next to what channel do you want a marker?
%
%   OUTPUTS
%   a plot
%   
%   EXAMPLE
%   plotTextChannels(basepath, 'markerChans',[aacChan, ripChan])  
%
%   HISTORY
%   2021/02 - Lianne made this into a function
%   
%   TO-DO
%   % Now it only takes up to 6 dots
%   % maybe make channelMap_path an input variable
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
% chanMap0ind = chanMap-1;
% xcoords = rez.xcoords;
% ycoords = rez.ycoords;

load('chanMap.mat')

figure
 text(xcoords,ycoords,num2str(chanMap0ind))
 xlim([min(xcoords)-10, max(xcoords)+10])
 ylim([min(ycoords)-10 ,max(ycoords)+10])

hold on
    
   if ~isempty(markerChans)
 
markerColor = {'k','m','r','g','b','y'};
for markerChan = 1:length(markerChans)
    plot(xcoords(markerChan)-1,ycoords(markerChan),'o','MarkerFaceColor',markerColor{markerChan})
end

   end
   
box off
xlabel('distance (um)')
ylabel('distance (um)')
% lloc = legend({'Ripple','AAC'},'Location','northoutside','Box','off','NumColumns',2);
   end


