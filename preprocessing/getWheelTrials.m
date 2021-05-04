function [len_ep, ts_ep, vel_ep, tr_ep, len_ep_fast, ts_ep_fast, vel_ep_fast] =getWheelTrials(analogin)

% Lianne 20191126, adapted from all the permutations of getDiskTrials

% Lianne 20200806, from negative to positive wheel trials,
% % % added options for all the different sessions that we currently have. wheels pos to neg,
% % % start with pos or neg peak.
% Reagan 20210429 - Soft coding parts of code:
%                       - thresholding for wheel
%                       - finding peaks: negtopos, postoneg
    
    pos = analogin.pos;
    ts = analogin.ts; % in sec

% Find out if wheel trials go postoneg or negtopos (Reagan 4/29/21 - I
% think this works?)

    diffmax_postoneg = max(diff(pos));
    diffmax_negtopos = max((diff(-pos)));
    if diffmax_negtopos > diffmax_postoneg
        trialType = 'negtopos';
    elseif diffmax_postoneg > diffmax_negtopos
        trialType = 'postoneg';
    end
%% Finding position over time
% Find max and min voltage
pos_r = rescale(pos);
pospeak_thr = 0.85; % because signal between 0 and 1
negpeak_thr = -0.15;
% 
% pospeak_thr = max(pos)-max(pos)*(1/8); %arbitrary ratio to catch peaks in
% negpeak_thr = min(pos)-min(pos)*(1/8);
voltDrop = pospeak_thr+negpeak_thr;
voltDrop = .4;
% negpeak_thr = min(pos)+min(pos)*(1/4);
[~, trP_idx] = findpeaks(pos_r, 'MinPeakProminence', voltDrop, 'MinPeakHeight', pospeak_thr); 
[~, trN_idx] = findpeaks(-pos_r, 'MinPeakProminence',voltDrop, 'MinPeakHeight', negpeak_thr); 
%addpath(genpath('E:\Dropbox\MATLAB (1)\AdrienToolBox\TSToolbox'))%TStoolbox


%% Determine if wheel trials have positive or negative wheel peak first (to account for beginning and end half laps)

if trN_idx(1) > trP_idx(1)
    firstTrPeak = 'positive_first';
elseif trN_idx(1) < trP_idx(1)
    firstTrPeak = 'negative_first';
end

if trN_idx(end) > trP_idx(end)
    lastTrPeak = 'negative_last';
elseif trN_idx(end) < trP_idx(end)
    lastTrPeak = 'positive_last';
end

if strcmpi(firstTrPeak, 'positive_first')
    if strcmpi(trialType,'negtopos')
        % remove first (positive) index that occurs (we only want full
        % laps)
        if trP_idx(1) < trN_idx(1)
            trP_idx(1) = [];
        end
        
        if strcmpi(lastTrPeak, 'negative_last')
            trN_idx(end) = [];
        end
        % insert here:multiple peaks workaround (when clipping of signal
        if length(trP_idx)> length(trN_idx)
            peaksIdx(1) = trP_idx(1);
            for i = 2:numel(trN_idx)-1
                peak_temp = find(trP_idx> trN_idx(i) & trP_idx<trN_idx(i+1));
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i) = trP_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i) = NaN;
                else
                    if i == 1 %add in if
                         continue
                     else
                     peaksIdx(i) = trP_idx(peak_temp);%take out +1
                    end
                end
            end
            
            trP_idx = peaksIdx;
            
        elseif length(trN_idx)> length(trP_idx)
            peaksIdx(1) = trN_idx(1);
            for i = 2:numel(trP_idx)-1
                peak_temp = find(trN_idx> trP_idx(i) & trN_idx<trP_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i) = trN_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i) = NaN;
                else
                    if i == 1 %add in if
                         continue
                     else
                     peaksIdx(i) = trN_idx(peak_temp);%take out +1
                    end
                end
            end
            trN_idx = peaksIdx;
            
        end
    elseif strcmpi(trialType, 'postoneg')
        %Reagan adding this section in 4/30/21
        % insert here:multiple peaks workaround (when clipping of signal
        %if there are more positive peaks than negative peaks, find the
        %extra peaks and take them out - Just changed everything N to P and
        %P to N
        
        %Reagan add this in - 5/3/21
        if strcmpi(lastTrPeak, 'positive_last')
            trP_idx(end) = [];
        end
        
        if length(trN_idx)> length(trP_idx)
            peaksIdx(1) = trN_idx(1);
            for i = 2:numel(trP_idx)-1
                peak_temp = find(trN_idx> trP_idx(i) & trN_idx<trP_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i) = trN_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i) = NaN;
                else
                    if i == 1 %add in if
                         continue
                     else
                     peaksIdx(i) = trN_idx(peak_temp);%take out +1
                    end
                end
            end
            
            trN_idx = peaksIdx;
            
        elseif length(trP_idx)> length(trN_idx)
            peaksIdx(1) = trP_idx(1);
            for i = 2:numel(trN_idx)-1
                peak_temp = find(trP_idx> trN_idx(i) & trP_idx<trN_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i) = trP_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i) = NaN;
                else
                    if i == 1 %add in if
                         continue
                     else
                     peaksIdx(i) = trP_idx(peak_temp);%take out +1
                    end
                end
            end
            trP_idx = peaksIdx;
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
        
          
        if strcmpi(lastTrPeak, 'negative_last')
            trN_idx(end) = [];
        end
        % insert here:multiple peaks workaround (when clipping of signal
        if length(trP_idx)> length(trN_idx)
            peaksIdx(1) = trP_idx(1);
            for i = 2:numel(trN_idx)-1
                peak_temp = find(trP_idx> trN_idx(i) & trP_idx<trN_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i) = trP_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i) = NaN;
                else
                    if i == 1 %add in if
                         continue
                     else
                     peaksIdx(i) = trP_idx(peak_temp);%take out +1
                    end
                end
            end
            
            trP_idx = peaksIdx;
            
            
        elseif length(trN_idx)> length(trP_idx)
            peaksIdx(1) = trN_idx(1);
            for i = 2:numel(trP_idx)-1
                peak_temp = find(trN_idx> trP_idx(i) & trN_idx<trP_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i) = trN_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i) = NaN;
                else
                    if i == 1 %add in if
                         continue
                     else
                     peaksIdx(i) = trN_idx(peak_temp);%take out +1
                    end
                end
            end
            trN_idx = peaksIdx;
            
        end
        elseif strcmpi(trialType, 'postoneg')
        %Reagan adding this section in 4/30/21
        % insert here:multiple peaks workaround (when clipping of signal
        %if there are more positive peaks than negative peaks, find the
        %extra peaks and take them out - Just changed everything N to P and
        %P to N
        
        if trN_idx(1) < trP_idx(1)
            trN_idx(1) = [];
        end
          
        if strcmpi(lastTrPeak, 'positive_last')
            trP_idx(end) = [];
        end
        
        %something goes wrong here - Reagan note 5.3.21
        % how do we account for multiple peaks in other pos/neg peak
        % vector?? 
        if length(trN_idx)> length(trP_idx)
            peaksIdx(1) = trN_idx(1); % make 1
            for i = 2:numel(trP_idx)-1 %add in 2 to end
                peak_temp = find(trN_idx> trP_idx(i) & trN_idx<trP_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i) = trN_idx(peak_temp); %take out +1
                elseif isempty(peak_temp)
                    peaksIdx(i) = NaN; %take out +1
                else
                     if i == 1 %add in if
                         continue
                     else
                     peaksIdx(i) = trN_idx(peak_temp);%take out +1
                     end
                end
            end  
         
            
            trN_idx = peaksIdx;
            
        elseif length(trP_idx)> length(trN_idx)
            peaksIdx(1) = trP_idx(1);
            for i = 2:numel(trN_idx)-1
                peak_temp = find(trP_idx> trN_idx(i) & trP_idx<trN_idx(i+1));
                
                if numel(peak_temp)>1
                    peak_temp = peak_temp(end);
                    peaksIdx(i) = trP_idx(peak_temp);
                elseif isempty(peak_temp)
                    peaksIdx(i) = NaN;
                else
                    if i == 1 %add in if
                         continue
                     else
                     peaksIdx(i) = trP_idx(peak_temp);%take out +1
                    end
                end    
            end
            trP_idx = peaksIdx;
            
        end  
    end
    
    % in one of the trials i got NaNs? This works but check which trials
    % are taken out.
    
    trP_idx(isnan(trN_idx)) = [];
    trialsCutOut = find(isnan(trN_idx));
    trN_idx(isnan(trN_idx)) = [];
    
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
