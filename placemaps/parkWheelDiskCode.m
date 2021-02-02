% [trN_idx] = LocalMinima(pos, 10^4,1)%LocalMinima(x, NotCloserThan, LessThan)
% [trP_idx] = LocalMinima(-pos, 10^4, -3)

% smoothPos = movmean(pos,1000);
% [trN_idx] = LocalMinima(smoothPos, 100,1.2);%10^4
% [trP_idx] = LocalMinima(-smoothPos, 2000, -3);%10^4

% trP = find(diff(smoothPos)>1*10^-3);
% trN = find(diff(smoothPos)<(-2*10^-3));
         
         % % if trN_idx(1) < trP_idx(1)
         % %     trN_idx(1) = [];
         % % end
         % % if length(trP_idx) > length(trN_idx)
         % %     trP_idx(end) = [];
         % % end
  


%           
%           if length(trN_idx)>length(trP_idx)
%               if more negative peaks than positive peaks: extra negative peak at
%                   the end. % trial runs from negative to positive.
%                   trN_idx(end) = [];
%               end
%           

% % k = normpdf([1:40],20,5); % stats toolbox
% % 
% % %get smoothed position
% % len_ep = cellfun(@(a) nanconvn(a,k'),len_ep,'uni',0);
% % 

% % extra values, due to smoothing %quick fix
% % idx_surplus = [];
% % idx_surplus = cellfun(@(a) find(a == max(a)), len_ep,'uni',0);% more values because plateauing, correct for that
% % % idx_plateau = cellfun(@(a) numel(a), idx_surplus,'uni',0);
% %
% % rmIdx = cellfun(@(a) a(1), idx_surplus,'uni',0);    %shorter, take the first idx where of the plateau is reached
% %
% % for iTr = 1:numel(len_ep)
% %     len_ep{iTr}(rmIdx{iTr}+1:end) = [];% nu gooi ik het laatste stukje trial weg vanwege het smoothen, moet misschien anders?
% %     ts_ep{iTr}(rmIdx{iTr}+1:end) = [];
% % end

%% FROM FINDSTIM

   [status,interval] = InIntervals(spikes.times{iUnit},tr_ep);
               
        % spk_ep %30000 Hz