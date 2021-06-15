function [csd, csdDat] = getAnatCSD2dat(basepath,session,varargin)
%
% This function computes the current source density using bz_CSD cade and
% makes it into a .dat file for neuroscope viewing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Dependencies
%    - Buzcode
%    - Cell Explorer
%    - lfp file
%    - session file from cell explorer
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input
%    - basepath   - path to data
%    - session    - session struct from cellexplorer
%
%%%Options%%%
%
%    - 'channels' - channels to use in the analysis (Default is
%      anatomically ordered channels from cell explorer session)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Usage
%    - [csd, csdDat] = getAnatCSD2dat(cd,session,'channels, [4 5 6]);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Todos
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% History
% - (2021/03/16) Code written by Kaiser Arndt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parse Inputs

p = inputParser;
addParameter(p,'channels',session.extracellular.electrodeGroups.channels{1,1},@isvector);

parse(p,varargin{:});
channels = p.Results.channels;

%% 

basename = bz_BasenameFromBasepath(basepath)

%% Load in files
lfp = bz_GetLFP('all');

load([basename '.session.mat'])


%% make csd

csd = bz_CSD(lfp, 'plotCSD', false, 'plotLFP', false, 'channels', channels);

%% make csdDat

v = csd.data';

csdDat = v(:);

%% write csdDat to .dat file
fileID = fopen([basename '.anatCSD.dat'], 'w');
fwrite(fileID, csdDat, 'int16');
fclose(fileID)

























