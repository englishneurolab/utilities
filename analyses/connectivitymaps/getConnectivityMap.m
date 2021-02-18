function [connectivity] = getConnectivityMap(basepath,varargin)
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
%   connectivity
%   .sigCell1
%   .sigCell2
%   .description
%   .rez
%
%   EXAMPLE
%
%   HISTORY
%
%   TO-DO
%   - Make this work fully as a function 
%   - Change something with _CellParams.mat dependency , more
%   generalizable, i feel like there's many permutations of this now.
%   - Separate plotting function

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
addParameter(p,'excludeCells',[],@isnumeric);

parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
saveAs          = p.Results.saveAs;
nConnections    = p.Results.nConnections;
excludeCells    = p.Results.excludeCells;



cd(basepath)



%% Monosynaptically connected graph
% Load spikes made from bz_GetSpikes.m
spikes = bz_GetSpikes;
%spikes = bz_LoadPhy;

% Load chanmap % make new for each type of probe from .xlsx files in probe maps
load rez.mat
xcoords = rez.xcoords';
ycoords = rez.ycoords';

% Load CellParams from bz_GetMonoSynapticallyConnected.m , also look at GetCellParams.m
load([basename '_CellParams.mat']) % contains mono_res and CellParams structs.
LocMaxWaveForm = CellParams.LocMaxWaveForm;

connectivity = [];

%% Loop through significant connections in sig_con structure and store cell number with best channel coordinates
for i = 1:length(mono_res.sig_con);
    
    sigCell1 = mono_res.sig_con(i,1); % Collects the first significant cell in the pair
    sigCell2 = mono_res.sig_con(i,2); % Collects the second significant cell in the pair
    
    
    sigCell1_chan = LocMaxWaveForm(1,sigCell1); % Collects the channel that that spike had the best waveform on
    sigCell2_chan = LocMaxWaveForm(1,sigCell2);
    
    sigCell1_x = xcoords(1,sigCell1_chan); % Collects x coordinate of channel
    sigCell1_y = ycoords(1,sigCell1_chan); % Collects y coordinate of channel
    sigCell2_x = xcoords(1,sigCell2_chan);
    sigCell2_y = ycoords(1,sigCell2_chan);
    
    % Store cell and corrdinates
    connectivity.sigCell1(i,1) = sigCell1;
    connectivity.sigCell2(i,1) = sigCell2;
    connectivity.sigCell1(i,2) = sigCell1_x; % x coordinates stored in second row
    connectivity.sigCell2(i,2) = sigCell2_x;
    connectivity.sigCell1(i,3) = sigCell1_y; % y coordinates stored in third row
    connectivity.sigCell2(i,3) = sigCell2_y;
    
end
mem = ismember(connectivity.sigCell2(:,1),excludeCells); % Identify cells on "shank 9"
exc_idx = find(mem,inf); % Pull idices in collected structure

connectivity.sigCell1(exc_idx,:) = [];
connectivity.sigCell2(exc_idx,:) = [];
connectivity.description = {'cell','x','y'};
connectivity.rez = rez;



%%
%

end
% xcoords = connectivity.rez.xcoords;
% ycoords = connectivity.rez.ycoords;

% xmin = min(xcoords); % xcoords and ycoords need to be in a matrix 1 x N (N = number of sites on the probe
% xmax = max(xcoords);
%
% ymin = min(ycoords);
% ymax = max(ycoords);
%
% x = [xmin xmax];
% y = [ymin ymax];
% %% Fix the plotting
% %% Need to change this so that it plots the weakest or strongest connections first to make sure the color is correct %%% %%
% plot(x,y,'LineStyle','none');
% hold on
% c = linspecer(nConnections,'sequential');
% for p = 1:length(connectivity.sigCell1);
%     r = randi([10,30]);
%     s = randi([10,30]);
%     plot((connectivity.sigCell1(p,2))+r,(connectivity.sigCell1(p,3))+s,'ob'); %plot(connectivity.sigCell1(p,2),connectivity.sigCell1(p,3),'ob');
%     plot((connectivity.sigCell2(p,2))+r,(connectivity.sigCell2(p,3))+s,'^r'); %plot(connectivity.sigCell2(p,2),connectivity.sigCell2(p,3),'^r');
%
% %     plot([connectivity.sigCell1(p,2)+r connectivity.sigCell2(p,2)+r], [connectivity.sigCell1(p,3)+s connectivity.sigCell2(p,3)+s],'color',c(p,:));
% end
%
%
%
%
%
% plot([connectivity.sigCell1(:,2) connectivity.sigCell2(:,2)], [connectivity.sigCell1(:,3) connectivity.sigCell2(:,3)])
%
% %% convert hex color code to 1-by-3 rgb array
% x = linspace(-2*pi,2*pi);
% y = sin(x);
% % Convert color code to 1-by-3 RGB array (0~1 each)
% str = '#00FFFF';
% color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
% figure
% plot(x, y, 'Color', color)
%
% %%
% A = rand(10,5);
% cm = colormap(parula(size(A,1)));                           % Default Colormap
% % c = A(:,5);
% for i=1:10
%     x1=A(i,1);
%     y1=A(i,2);
%     x2=A(i,3);
%     y2=A(i,4);
%     plot([x1,x2],[y1,y2],'Color', cm(i,:))
%     hold on
% end