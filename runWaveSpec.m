basepath = cd; basename = bz_BasenameFromBasepath(cd);
% rippleChan= 25;
rippleChan = 57;
lfp = bz_GetLFP(rippleChan);
load([basename '_runEpochs1_5.mat'])

selRunIdx = runIdx(runEpochsIdx_long,:); % currently: min 2cm/s  (long is min 3s)
selRunEpochs = runEpochs_long;

%% waveSpec Run ONSET
%%
timMS = 1000;
ops.tw_ws = timMS * lfp.samplingRate/1000; %ms
ops.bl_ws = ops.tw_ws*2;

freqRange = [1 40];
numFreqs = freqRange(end)-freqRange(1)*2;


lfp_time =[];
lfp_data = [];
countRuns = 0;
for iRun = 1:length(selRunEpochs)
    selRunStartIdx = selRunIdx(iRun,1);
    %nb this is to exclude first or last epoch that might fall outside the
    %window of interest)
    if abs(selRunStartIdx-ops.tw_ws) == selRunStartIdx-ops.tw_ws
        countRuns = countRuns + 1;
        %       if abs(lfp.timestamps(selRunStart)-ops.bl_ws) == lfp.timestamps(selRunStart)-ops.bl_ws
        lfp_time(:,countRuns) = lfp.timestamps(selRunStartIdx-ops.tw_ws:selRunStartIdx+ops.tw_ws);
        lfp_data(:,countRuns) = lfp.data(selRunStartIdx-ops.tw_ws:selRunStartIdx+ops.tw_ws);
    end
    
end



lfp_forWS.data = lfp_data;
lfp_forWS.timestamps = lfp_time;
lfp_forWS.samplingRate= 1250;

ws_temp         = bz_WaveSpec(lfp_forWS,'frange',freqRange,'nfreqs',numFreqs,'space','lin');
ws_temp.data    = abs(ws_temp.data);
ws_reshaped     = reshape(ws_temp.data,[length(ws_temp.timestamps),ws_temp.nfreqs,countRuns]);
wavespec_avg    = mean(ws_reshaped,3);

% wavespec for baseline also

lfpb_time = [];
lfpb_data = [];

countBase = 0;
for iRun = 1:length(selRunEpochs)
    selRunStartIdx = selRunIdx(iRun,1);
        countBase = countBase +1;

    %nb this is to exclude first or last epoch that might fall outside the
    %window of interest)
    %     if abs(lfp.timestamps(selRunStart-ops.tw_ws)) == lfp.timestamps(selRunStart-ops.tw_ws
    %     if abs(lfp.timestamps(selRunStart-ops.bl_ws)) == lfp.timestamps(selRunStart-ops.bl_ws
    lfpb_time(:,countBase) = lfp.timestamps(selRunStartIdx-ops.bl_ws:selRunStartIdx-ops.tw_ws);
    lfpb_data(:,countBase) = lfp.data(selRunStartIdx-ops.bl_ws:selRunStartIdx-ops.tw_ws);
    %     end
    %     end
    
end

lfpb_forWS.data         = lfpb_data;
lfpb_forWS.timestamps   = lfpb_time;
lfpb_forWS.samplingRate = 1250;

wsb_temp         = bz_WaveSpec(lfpb_forWS,'frange',freqRange,'nfreqs',numFreqs,'space','lin');
wsb_temp.data    = abs(wsb_temp.data);
wsb_reshaped     = reshape(wsb_temp.data,[length(wsb_temp.timestamps),wsb_temp.nfreqs,countBase]);
wavespecb_avg    = mean(wsb_reshaped,3);
wsb_rep          = (mean(wavespecb_avg,1));


% normalize
normMat         = repmat(wsb_rep,size(wavespec_avg,1),1);
normdata        = wavespec_avg./normMat;

% and plot
figure
imagesc(normdata');
set(gca,'YDir','normal')

colormap(jet)
xLimVec = [0:250:size(normdata)];
xSampAlign =  xLimVec-((xLimVec(end)-xLimVec(1))/2);
xTimeAlign = xSampAlign/lfp.samplingRate;
xlim([xLimVec(1) xLimVec(end)])
set(gca,'XTick',xLimVec,'XTickLabel',num2cell(xTimeAlign))
xlabel('Time(s)');
ylabel('Frequency(Hz)');
set(gca, 'YDir', 'normal');

% freqStep = (freqRange(2)-freqRange(1))./numFreqs;
% YtickVec = 0:20:numFreqs;
% YlabelVec = freqStep*YtickVec;
% for i = 1:length(YlabelVec), YlabelVecStr{i} = num2str(YlabelVec(i));, end
% 
% set(gca, 'YTick', [YtickVec])
% set(gca, 'YTickLabel', {YlabelVec}) % changes the labels of the selected indices in 'YTick' above
%     set(gca, 'XTick', [1:5:size(wavespec_avg)])
%     set(gca, 'XTickLabel', {})
box 'off';
set(gca, 'TickDir', 'out');
t = colorbar;
