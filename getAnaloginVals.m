function [analogin] = getAnaloginVals(basepath,varargin)
%
%   This function is designed to get the analogin files and store them in a
%   seperate .mat file
%
%   USAGE
%
%   %% Dependencies %%%
%
%
%   INPUTS
%   'basename'          - if basename is any different then parentfolder name
%   'wheelChan'         - 0-based (default: '0')
%   'pulseChan'         - 0-based (default: '3')
%   'rewardChan'        - 0-based (default: '1')
%   'samplingRate'      - sampling rate of analogin.dat (default: [30000])
%   'downsampleFactor'  - Downsample original data this many times (default: [0]) 
%
%   OUTPUTS
%   analogin        -   analogin-channels
%   .pos            -   
%   .pulse          -
%   .reward         -
%   .ts             -
%   .sampFreq       -
%
%
%   HISTORY
%   2020/09 Lianne documented and proofed this function for analogin
%
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
addParameter(p,'wheelChan',0,@isnumeric);
addParameter(p,'pulseChan',3,@isnumeric);
addParameter(p,'rewardChan',1,@isnumeric);
addParameter(p,'samplingRate',30000,@isnumeric);
addParameter(p,'downsampleFactor',0,@isnumeric);

parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
wheelChan       = p.Results.wheelChan;
pulseChan       = p.Resuls.pulseChan;
rewardChan      = p.Results.rewardChan;
samplingRate    = p.Results.samplingRate;
downsampleFactor = p.Results.downsampleFactor;


cd(basepath)

%%

rhdfilename = [basename '_info.rhd'];

if exist(rhdfilename,'file')
    read_Intan_RHD2000_file_noprompt(rhdfilename)
else
    read_Intan_RHD2000_file_noprompt('info.rhd')
end

analogin_file   = [basename, '_analogin.dat'];

pulsechan = pulseChan +1;
wheelchan = wheenChan +1;
rewardchan =rewardChan +1;

num_channels    = length(board_adc_channels); % ADC input info from header file
fileinfo        = dir([basename '_analogin.dat']);
num_samples_perChan     = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes

fid = fopen([basename '_analogin.dat'], 'r');
v   = fread(fid, [num_channels, num_samples_perChan], 'uint16');
fclose(fid);
v   = v * 0.000050354; % convert to volts, intan conversion factor


pulse   = v(pulsechan,:);
pos     = v(wheelchan,:);
reward  = v(rewardchan,:);
sr      = samplingRate;

if downsampleFactor ~=0 
    pulse   = downsample(pulse,downsampleFactor);
    pos     = downsample(pos,downsampleFactor); 
    reward  = downsample(reward,downsampleFactor);
    sr = samplingRate/downsampleFactor;
end

analogin.pulse   = pulse;
analogin.pos     = pos;
analogin.reward  = reward;
analogin.ts      = (1:length(pos))/sr;
analogin.sampFreq = sr;

end

