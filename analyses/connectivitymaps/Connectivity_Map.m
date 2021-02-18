function [out] = getConnectivityMap(basepath,varargin)

% This function is designed to 
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
%   'saveMat'   - saving the results to [basename,
%                   '.burstMizuseki.analysis.mat']
%   'saveAs'    - if you want another suffix for your save
%   'nConnections' - % number of significant connections
%   'excludeCells - % range of cells that were identified but not needed
%
%   OUTPUTS
%   
%   EXAMPLE
%   
%   HISTORY
%
%   TO-DO
%   make this work as a function


%% Parse!
% 
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);


p = inputParser;
addParameter(p,'basename',basename,@isstring);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'saveAs','.connectivity.analysis.mat',@isstring);
addParameter(p,'nConnections',60,@isnumeric);
addParameter(p,'excludeCells',[124:127],@isnumeric);

parse(p,varargin{:});
basename    = p.Results.basename;
saveMat     = p.Results.saveMat;
saveAs      = p.Results.saveAs;
nConnections = p.Results.nConnections;
excludeCells = p.Results.excludeCells;



cd(basepath)



%% Monosynaptically connected graph
% Load spikes made from bz_GetSpikes.m
spikes = bz_GetSpikes;
%spikes = bz_LoadPhy;

% Load chanmap % make new for each type of probe from .xlsx files in probe maps
% do something here

% Load CellParams from bz_GetMonoSynapticallyConnected.m , also look at GetCellParams.m
load([basename '_CellParams.mat']) % contains mono_res and CellParams structs.
LocMaxWaveForm = CellParams.LocMaxWaveForm;

SCs = [];

%% Loop through significant connections in sig_con structure and store cell number with best channel coordinates
for i = 1:length(mono_res.sig_con);
    
    sc1 = mono_res.sig_con(i,1); % Collects the first significant cell in the pair
    sc2 = mono_res.sig_con(i,2); % Collects the second significant cell in the pair
    

    sc1_chan = LocMaxWaveForm(1,sc1); % Collects the channel that that spike had the best waveform on
    sc2_chan = LocMaxWaveForm(1,sc2); 
    
    sc1_x = xcoords(1,sc1_chan); % Collects x coordinate of channel
    sc1_y = ycoords(1,sc1_chan); % Collects y coordinate of channel
    sc2_x = xcoords(1,sc2_chan);
    sc2_y = ycoords(1,sc2_chan);
    
    % Store cell and corrdinates 
    SCs.sc1(i,1) = sc1;
    SCs.sc2(i,1) = sc2;
    SCs.sc1(i,2) = sc1_x; % x coordinates stored in second row
    SCs.sc2(i,2) = sc2_x;
    SCs.sc1(i,3) = sc1_y; % y coordinates stored in third row
    SCs.sc2(i,3) = sc2_y; 

end    
mem = ismember(SCs.sc2(:,1),excludeCells); % Identify cells on "shank 9" 
exc_idx = find(mem,inf); % Pull idices in collected structure

SCs.sc1(exc_idx,:) = [];
SCs.sc2(exc_idx,:) = [];

xmin = min(xcoords); % xcoords and ycoords need to be in a matrix 1 x N (N = number of sites on the probe
xmax = max(xcoords);

ymin = min(ycoords);
ymax = max(ycoords);

x = [xmin xmax];
y = [ymin ymax];

%% %%% Need to change this so that it plots the weakest or strongest connections first to make sure the color is correct %%% %%
plot(x,y,'LineStyle','none');
hold on
c = linspecer(nConnections,'sequential');
for p = 1:length(SCs.sc1);
    r = randi([10,30]);
    s = randi([10,30]);
    plot((SCs.sc1(p,2))+r,(SCs.sc1(p,3))+s,'ob'); %plot(SCs.sc1(p,2),SCs.sc1(p,3),'ob');
    plot((SCs.sc2(p,2))+r,(SCs.sc2(p,3))+s,'^r'); %plot(SCs.sc2(p,2),SCs.sc2(p,3),'^r'); 
    
    plot([SCs.sc1(p,2)+r SCs.sc2(p,2)+r], [SCs.sc1(p,3)+s SCs.sc2(p,3)+s],'color',c(p,:));
end





plot([SCs.sc1(:,2) SCs.sc2(:,2)], [SCs.sc1(:,3) SCs.sc2(:,3)])

%% convert hex color code to 1-by-3 rgb array
x = linspace(-2*pi,2*pi);
y = sin(x);
% Convert color code to 1-by-3 RGB array (0~1 each)
str = '#00FFFF';
color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
figure
plot(x, y, 'Color', color)

%% 
A = rand(10,5);
cm = colormap(parula(size(A,1)));                           % Default Colormap
% c = A(:,5);
for i=1:10
    x1=A(i,1);
    y1=A(i,2);
    x2=A(i,3);
    y2=A(i,4);
    plot([x1,x2],[y1,y2],'Color', cm(i,:))
    hold on
end