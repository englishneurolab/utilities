function [pow] = getPowerSpectrum(basepath,varargin)
%%%% OLD~~%%%%

% This function analyzes 
%
%   USAGE 
%   
%   Dependencies: Buzcode, Englishlab\utilities, output
%
%   INPUTS
%   Name-value paired inputs:
%   'basepath'      - folder in which .STP.mat and 'phmod.mat' can be found 
%                   (Required input, Default is pwd)
%
%   OUTPUTS
%   pow
%   .
%   .
%   .
%
%   EXAMPLES
%
%
%   NOTES
%
%
%   TO-DO
%
%
%   HISTORY
%
%
%
%

%% Parse



basename = bz_BasenameFromBasepath(basepath);

%%
xmln    = [basepath filesep basename '.xml'];
fname   = [basepath filesep basename '.lfp'];
xml     = LoadXml(xmln);

load([basename '.ripples.events.mat'])
ch      = ripples.detectorinfo.detectionchannel;

sessionInfo = bz_getSessionInfo(basepath);
sampFreq = sessionInfo.rates.wideband;

lfp = bz_GetLFP(ch);
%%

dLFP = double(lfp.data);
lfplp = lowpass(dLFP,200,1250);
%demean datastill?

%tapers (Sleppian); tapsmofreq =1 now
% tap = dpss(length(dLFP),length(dLFP)*(1./sampFreq))'; 
%%This now gives out of error memories! 
% remove the last taper 
% tap = tap(1:(end-1), :);


%compute FFT      

% % % phase-shift??
% %           if timedelay ~= 0
% %             dum = dum .* exp(-1i*angletransform(:,ifreqoi));
% %           end
% %           dum = dum .* sqrt(2 ./ endnsample);
% %           spectrum(itap,:,ifreqoi) = dum;
% %         end
% %       end % for nfreqoi

samplingRate = lfp.samplingRate;
nqSamp = samplingRate;

yfft = fft(lfp.data, nqSamp);
lfplp = lowpass(double(lfp.data),200,1250);
lpyfft = abs(fft(lfplp,nqSamp));

xfft = 1:2:nqSamp;

figure
plot(xfft,abs(yfft(1:length(abs(yfft))/2)))

xlim([1 200])
xlabel('Frequency Hz')  
ylabel ('Power') 



end
