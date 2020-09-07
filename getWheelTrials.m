function [len_ep, ts_ep, vel_ep, tr_ep, len_ep_fast, ts_ep_fast, vel_ep_fast] =getWheelTrials(analogin)

% Lianne 20191126, adapted from all the permutations of getDiskTrials

% Lianne 20200806, from negative to positive wheel trials,
% % % added options for all the different sessions that we currently have. wheels pos to neg,
% % % start with pos or neg peak.


pos = analogin.pos;
ts = analogin.ts; % in sec


% this should become a function input option:

trialType = 'negtopos' % or 'postoneg';

%% Finding position over time
% These thresholds seem to change per recording: figure this out

[~, trP_idx] = findpeaks(pos, 'MinPeakProminence', 1, 'MinPeakHeight', 1);
[~, trN_idx] = findpeaks(-pos, 'MinPeakProminence', .5, 'MinPeakHeight', -1);

addpath(genpath('E:\Dropbox\MATLAB (1)\AdrienToolBox\TSToolbox'))%TStoolbox


%% Determine if wheel trials go from positive to negative or vice versa

if trN_idx(1) > trP_idx(1)
    firstTrPeak = 'positive_first';
elseif trN_idx(1) < trP_idx(1)
    firstTrPeak = 'negative_first';
end

if strcmpi(firstTrPeak, 'positive_first')
    if strcmpi(trialType,'negtopos')
        % remove first (positive) index that occurs
        if trP_idx(1) < trN_idx(1)
            trP_idx(1) = [];
        end
        
        % insert here:multiple peaks workaround (when clipping of signal
        if length(trP_idx)> length(trN_idx)
            peaksIdx = trP_idx(1);
            for i = 1:numel(trN_idx)-1
                peak_temp = find(trP_idx> trN_idx(i) & trP_idx<trN_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i+1) = trP_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i+1) = NaN;
                else
                    peaksIdx(i+1) = trP_idx(peak_temp);
                end
                
            end
            
            trP_idx = peaksIdx;
            
        elseif length(trN_idx)> length(trP_idx)
            peaksIdx = trN_idx(1);
            for i = 1:numel(trP_idx)-1
                peak_temp = find(trN_idx> trP_idx(i) & trN_idx<trP_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i+1) = trN_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i+1) = NaN;
                else
                    peaksIdx(i+1) = trN_idx(peak_temp);
                end
                
            end
            trN_idx = peaksIdx;
            
        end
        
       
    end
    % in one of the trials i got NaNs? This works but check which trials
    % are taken out.
    
    trP_idx(isnan(trN_idx)) = [];
    trialsCutOut = find(isnan(trN_idx));
    trN_idx(isnan(trN_idx)) = [];
    
     trStart_idx = trN_idx;
        trStop_idx = trP_idx;
    
    %% THIS NEEDS TO BE FIXED
elseif strcmpi(firstTrPeak,'negative_first')
    
    if strcmpi(trialType,'negtopos')
        
        
        % insert here:multiple peaks workaround (when clipping of signal
        if length(trP_idx)> length(trN_idx)
            peaksIdx = trP_idx(1);
            for i = 1:numel(trN_idx)-1
                peak_temp = find(trP_idx> trN_idx(i) & trP_idx<trN_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i+1) = trP_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i+1) = NaN;
                else
                    peaksIdx(i+1) = trP_idx(peak_temp);
                end
                
            end
            
            trP_idx = peaksIdx;
            
            
        elseif length(trN_idx)> length(trP_idx)
            peaksIdx = trN_idx(1);
            for i = 1:numel(trP_idx)-1
                peak_temp = find(trN_idx> trP_idx(i) & trN_idx<trP_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i+1) = trN_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i+1) = NaN;
                else
                    peaksIdx(i+1) = trN_idx(peak_temp);
                end
                
            end
            trN_idx = peaksIdx;
            
        end
        
    end
    % in one of the trials i got NaNs? This works but check which trials
    % are taken out.
    
    trP_idx(isnan(trN_idx)) = [];
    trialsCutOut = find(isnan(trN_idx));
    trN_idx(isnan(trN_idx)) = [];
    
    
    
    if strcmpi(trialType,'postoneg')
        trN_idx(1) = [];
    end
    
    
    if  strcmpi(trialType,'negtopos')
        trStart_idx = trN_idx;
        trStop_idx = trP_idx;
    elseif strcmpi(trialType,'postoneg')
        trStart_idx = trP_idx;
        trStop_idx = trN_idx;
    end
end

%%

% start stop time for trial
tr_ep = [ts(trStart_idx)' ts(trStop_idx)']; % in sec start stop

% % shitty workaround for mouse u19:
% % trP_idx(1) = [];
% % trN_idx(end) = [];
% tr_ep = [ts(trN_idx)' ts(trP_idx)'];

[status, interval] = InIntervals(ts,tr_ep); % detects which times belong to each trial

n1      = histoc(interval(interval>0),1:size(tr_ep,1)); % how many timestamps or position values should there be per bin
len_ep  = mat2cell(pos(status)',n1); % position values per trial in V outpiut of halifax
ts_ep   = mat2cell(ts(status)',n1); % time stamps per trial in seconds
len_ep = cellfun(@(a) movmean(a,1000), len_ep,'uni',0);

%get velocity
vel_ep = cellfun(@(a) diff([nan ;a]),len_ep,'uni',0);

% find indices where mouse runs fast, better for place tuning, otherwise
% spikes might exist not due to speed
% NB if wheel goes from low to high its reverse from when wheel goes from
% high to low: fix this

if strcmpi(trialType,'negtopos')
thres = -.5e-3; % based on ??
else
    thres = .5e-3; % based on ??
end

fast_ep  =cellfun(@(a) find(-a>thres),vel_ep,'uni',0);
ts_ep_fast = cellfun(@(a,b) a(b),ts_ep,fast_ep,'uni',0);
vel_ep_fast = cellfun(@(a,b) a(b),vel_ep,fast_ep,'uni',0);
len_ep_fast = cellfun(@(a,b) a(b),len_ep,fast_ep,'uni',0);

end

% plot start stop above pos to see if fast trial threshold is fine
