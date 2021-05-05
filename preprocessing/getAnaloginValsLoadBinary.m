function [analogin] = getAnaloginValsLoadBinary(basepath,varargin)
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
%   'wheelChan'         - 0-based chan or 'none' (default: 0)
%   'pulseChan'         - 0-based chan or 'none' (default: 3)
%   'rewardChan'        - 0-based chan or 'none' (default: 1)
%   'blinkChan'         - 0-based chan or 'none' (default: 6)
%   'samplingRate'      - sampling rate of analogin.dat (default: [30000])
%   'downsampleFactor'  - Downsample original data this many times (default: [0])
%
%   OUTPUTS
%   analogin        -   analogin-channels voltage
%   .pos            -   wheel channel voltage
%   .pulse          -   pulse channel voltage
%   .reward         -   reward channel voltage
%   .blink          -   blink channel voltage
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
%   2021/4 use LoadBinary to circumvent out of memory errors
%   TO DO
%   - Store analogin Channels 0-based index with labels 
%   - -> incorporate %   chunks in getAnaloginVals?

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
addParameter(p,'blinkChan',6,channelsValidation);
addParameter(p,'samplingRate',30000,@isnumeric);
addParameter(p,'downsampleFactor',0,@isnumeric);

parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
wheelChan       = p.Results.wheelChan;
pulseChan       = p.Results.pulseChan;
rewardChan      = p.Results.rewardChan;
blinkChan       = p.Results.blinkChan;
samplingRate    = p.Results.samplingRate;
downsampleFactor = p.Results.downsampleFactor;


cd(basepath)

%%

xml = LoadXml([basename '_analogin.xml']);

num_channels    = xml.nChannels; % ADC input info from header file
fileinfo        = dir([basename '_analogin.dat']);
num_samples_perChan     = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
% 
v = bz_LoadBinary([basename '_analogin.dat'],'frequency',samplingRate,'nChannels',num_channels, 'downsample',downsampleFactor);
v   = v * 0.000050354; % convert to volts, intan conversion factor

% 
 v = v';

%pulse
if isnumeric(pulseChan)
    pulsechan = pulseChan +1;
    pulse   = v(pulsechan,:);
    
%     if downsampleFactor ~=0
%         pulse   = downsample(pulse,downsampleFactor);
%     end
    analogin.pulse   = pulse;
end

%wheel
if isnumeric(wheelChan)
    wheelchan = wheelChan +1;
    pos     = v(wheelchan,:);
%     
%     if downsampleFactor ~=0
%         pos     = downsample(pos,downsampleFactor);
%     end
    analogin.pos     = pos;

end

%reward
if isnumeric(rewardChan)
    rewardchan =rewardChan +1;
    reward  = v(rewardchan,:);
%     if downsampleFactor ~=0
%         reward  = downsample(reward,downsampleFactor);
%     end
    analogin.reward  = reward;
end

%blink light
if isnumeric(blinkChan)
    blinkchan =blinkChan +1;
    blink  = v(blinkchan,:);
%     if downsampleFactor ~=0
%         blink  = downsample(blink,downsampleFactor);
%     end
    analogin.blink  = blink;
end


%time and sr
sr      = samplingRate;
if downsampleFactor ~=0
    sr = samplingRate/downsampleFactor;
end

analogin.ts      = (1:length(v(1,:)))/sr;
analogin.sr      = sr;


if saveMat
    save([basename '_analogin.mat'],'analogin')
end

end

