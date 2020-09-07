function [pulse, pos, reward, ts] = getAnaloginVals(basename,parameters,board_adc_channels, options)
% needs an options.downsampleFactor!

% Lianne, 20191126


% downsampleFactor = options.downsampleFactor;
pulsechan = parameters.analoginCh.pulse;
wheelchan = parameters.analoginCh.wheel;
rewardchan = parameters.analoginCh.reward;



    num_channels    = length(board_adc_channels); % ADC input info from header file
    fileinfo        = dir([basename '_analogin.dat']);
    
    num_samples_perChan     = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes

    fid = fopen([basename '_analogin.dat'], 'r');
    v   = fread(fid, [num_channels, num_samples_perChan], 'uint16');
    fclose(fid);
    v   = v * 0.000050354; % convert to volts, intan conversion factor 


pulse   = v(pulsechan,:);
% pulse   = downsample(pulse,downsampleFactor); % to 100Hz;
pos     = v(wheelchan,:);
% pos     = downsample(pos,downsampleFactor); % to 100Hz
reward  = v(rewardchan,:);
% reward  = downsample(reward,downsampleFactor);


% figure,
% plot(pulse)
%
% figure,
% plot(pos)

% sr = 100;  % because position signal is downsampled to 100 Hz
sr=30000;
ts = (1:length(pos))/sr;
