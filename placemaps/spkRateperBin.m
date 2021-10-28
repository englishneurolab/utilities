    % get Spks per Bin for Heatmap
    %%
    for iUnit = 1%:length(spikes.UID)
        tic
        
        % find out what position each spike is
        % by binning positions
        
        trialTimes  = ts_ep; 
        trialPos    = len_ep;
        
        radiusDisk = 26;
        circDisk = 2*pi*radiusDisk;
        numBins = 10; % equally spaced over track
        
        
        %%
        for iTr = 1:28%length(len_ep)
            %% IF VELOCITY OF TRIAL IS FAST ENOUGH
            if isempty(len_ep{iTr}) %% LEN_EP_FAST
                continue
            else
                clear posbinTs
                lengthWheel =round(max(cell2mat(len_ep)),1);
                
                if  max(cell2mat(len_ep))/lengthWheel > 1
                    lengthWheel = lengthWheel + 0.1; % hoe doe je anders ceil op 1 decimaal?
                end
                
                posBinSize = lengthWheel/numBins;
                posEdges = 0:posBinSize:lengthWheel;
                posBinsCount = histcounts(len_ep{iTr},posEdges); 
                
                ts_posbin = mat2cell(trialTimes{iTr},posBinsCount);% all timestamps per trial for positions.
                
                for iPosBin = 1:length(posBinsCount) % hardcoded now
                    if ~isempty(ts_posbin{iPosBin})
                        posbinTs(iPosBin,:) = [ts_posbin{iPosBin}(1) ts_posbin{iPosBin}(end)]; % in time
                        % seconds in bin per trial
                        secTrPosBin = [posbinTs(iPosBin,2) - posbinTs(iPosBin,1)]; % in sec
                    [status, interval]= InIntervals(spikes.times{iUnit},posbinTs(iPosBin,:));
                    numSpkBin(iPosBin) = sum(status);
                    else %this is still very wonky? fix this part of the code!!
                        continue
% % posbinTs(iPosBin,:) = [0.0000001 0.0000002];
% %                         secTrPosBin = [0.0000000001];
                    end
                end
                
                %how many spikes per unit fall in these intervals?
                [status, interval]= InIntervals(spikes.times{iUnit},posbinTs);
                if sum(status)~= 0
                % now find out how many spikes/s are within these posbins. By
                % calculating length posbinTs (end-1) and num timestamps.(normalized FR 0 to 1)
                % how many timestamps or position values should there be per bin
                numSpkBin      = histcounts(interval(interval>0),1:size(posbinTs,1));
                spkPerSec{iUnit}.trial{iTr} = numSpkBin/secTrPosBin; % number of spikes per posbin per trial / seconds in position bin
                end
            end
        end
        
        %% 
        nosc_unitRM{iUnit} = cell2mat(spkPerSec{iUnit}.trial');
         figure, imagesc(nosc_unitRM{iUnit});
        clear  rowmin rowmax numSpkBin posbinTs secTrPosBin
    toc
    end