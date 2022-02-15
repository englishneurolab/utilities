function [pulseEpochs] = getSinPulseTimes(analogin,varargin)
% This function is designed to 
%
%   USAGE
%
%   [pulseEpochs] = getSinPulseTimes(analogin);
%
%   %% Dependencies %%%
%   getAnaloginVals - in english lab utilities
%   bz_Filter       - in buzcode
%   
%   INPUTS
%   analogin.mat    - from getAnaloginVals in english lab utilities
%       .pulse      - matrix of timestamps X pulse channels
%       .ts         - matrix of 1 X timestamps in seconds
%
%   OPTIONS
%      'stimDur'    - total duration of each stim pulse in seconds
%                     (ex. [.2] = 200ms)
%      'saveMat'    - logical whether to save pulse epochs or not (default
%                     = true)
%
%
%   OUTPUTS
%   
%   
%   EXAMPLE
%   
%   
%   HISTORY
%   - Created by Kaiser Arndt 21/10/25
%
%   
%   TO-DO
%
%% Parse inputs
basename = bz_BasenameFromBasepath(cd);

p = inputParser;
addParameter(p,'stimDur',.2,@isnumeric);
addParameter(p,'saveMat',true,@islogical);

parse(p,varargin{:});
stimDur        = p.Results.stimDur;
saveMat        = p.Results.saveMat;


%% Filter

filtered = bz_Filter(analogin.pulse,'passband',[0 10]); % low pass filter


for i = 1:size(filtered,2)
    [~,LOCS] = findpeaks(filtered(:,i),'MinPeakHeight',1);
    times    = analogin.ts(LOCS);
    pulseEpochs.center{:,i} = times;
end

for i = 1:length(pulseEpochs.center)
    timestamps{i}(:,1) = pulseEpochs.center{i} - stimDur/2;
    timestamps{i}(:,2) = pulseEpochs.center{i} + stimDur/2;
end

pulseEpochs.timestamps = timestamps;
pulseEpochs.stimDur    = stimDur;

if saveMat
    save([basename '.pulseEpochs.mat'],'pulseEpochs')
end







