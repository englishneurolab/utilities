function [analogin] = getAnaloginVals(basepath,varargin)
%
%   This function is designed to get the analogin files and store them in a
%   seperate .mat file
%
%   USAGE
%   
%   %%% Dependencies %%%
%   Must have an [basename '_analogin.xml'] file in the basepath
%
%
%   INPUTS
%   'basename'          - if basename is any different then parentfolder name
%   'wheelChan'         - 1-based chan or 'none' (default: 1)
%   'pulseChan'         - 1-based chan or 'none' (default: 4)
%   'rewardChan'        - 1-based chan or 'none' (default: 2)
%   'samplingRate'      - sampling rate of analogin.dat (default: [30000])
%   'downsampleFactor'  - Downsample original data this many times (default: [0])
%
%   OUTPUTS
%   analogin        -   analogin-channels voltage
%   .pos            -   wheel channel voltage
%   .pulse          -   pulse channel voltage
%   .reward         -   reward channel voltage
%   .ts             -   times in seconds
%   .sr             -   sampling rate of analogin data
%
%   EXMAPLE
%   [analogin] = getAnaloginVals(basepath,'wheelChan',2,'pulseChan','none')
%
%   HISTORY
%   2020/09 Lianne documented and proofed this function for analogin
%   2020/12 Lianne added option to exclude channels by specifying them as
%   'none'. Also the analogin channels are now 0-based inputs. 
%   2021/2 Kaiser changed reading the rhd channels for loading an
%   analogin.xml file
%   2021/10 Kaiser changed loading in analogin to bz_LoadBinary from fwrite
%
%   TO DO
%   - Store analogin Channels 0-based index with labels 

%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

channelsValidation = @(x) isnumeric(x) || strcmp(x,'none');

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'wheelChan',0,channelsValidation);
addParameter(p,'pulseChan',3,channelsValidation);
addParameter(p,'rewardChan',1,channelsValidation);
addParameter(p,'samplingRate',30000,@isnumeric);
addParameter(p,'downsampleFactor',0,@isnumeric);

parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
wheelChan       = p.Results.wheelChan;
pulseChan       = p.Results.pulseChan;
rewardChan      = p.Results.rewardChan;
samplingRate    = p.Results.samplingRate;
downsampleFactor = p.Results.downsampleFactor;


cd(basepath)

%%
chans = [];
if isnumeric(wheelChan)
    chans = [chans wheelChan];
end
if isnumeric(pulseChan)
    chans = [chans pulseChan];
end
if isnumeric(rewardChan)
    chans = [chans rewardChan];
end

analog = double(bz_LoadBinary([basename '_analogin.dat'], 'frequency', samplingRate, ...
    'nChannels', 8, 'channels', chans));
v   = analog .* 0.000050354; % convert to volts, intan conversion factor

clear analog

%wheel
if isnumeric(wheelChan)
    pos     = v(:,1);
    
    if downsampleFactor ~=0
        pos     = downsample(pos,downsampleFactor);
    end
    analogin.pos     = pos;

end

clear pos

%pulse
if isnumeric(pulseChan)
    pulse   = v(:,ismember(chans, pulseChan));
    
    if downsampleFactor ~=0
        pulse   = downsample(pulse,downsampleFactor);
    end
    analogin.pulse   = pulse;
end

clear pulse

%reward
if isnumeric(rewardChan)
    reward  = v(:,3);
    if downsampleFactor ~=0
        reward  = downsample(reward,downsampleFactor);
    end
    analogin.reward  = reward;
end

clear reward


%time and sr
sr      = samplingRate;
if downsampleFactor ~=0
    sr = samplingRate/downsampleFactor;
end

analogin.ts      = (1:length(analogin.pos(:,1)))/sr;
analogin.sr      = sr;


if saveMat
    save([basename '_analogin.mat'],'analogin','-V7.3')
end

end

