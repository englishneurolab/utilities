function [pkValmaxInd, pkIndmaxInd,ripSnip] = findRippleLayerChan(basepath, 'selRipples',selRipples);

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
%
%   OUTPUTS
%   
%   
%   EXAMPLE
%   
%   
%   HISTORY
%
%   
%   TO-DO
%   % This function disappeared sadly, rebuilt it
%

%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

channelsValidation = @(x) isnumeric(x) || strcmp(x,'none');

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);