
function ses = ShortTermCCG(ref,target,binsize,duration,varargin)


% This function calculates the conditional cross correlation between two
% time series (ref and target). The CCG can be conditioned in two modes,
% 'burst' or 'time'. In burst mode, each reference spike is categorized as
% to as to whether it occurs solo (0) as the 1st to Nth event within a
% burst (1-N) defined as events that occur within time<ISI
% In 'time' mode, the reference times are categorized based off of the
% inter-event interval, binned at ts_bin
% 
% pre = presynaptic spike times
% post = postsynaptc spike times
% binsize = size of CCG bin
% duration = time window of CCG
% see below for varagin inputs
%
% Example: 
%
% In 'burst' mode
% ses = ShortTermCCG(ref,target,.0008,.2,'burst',.01)
%
% In 'time' mode
% ses = ShortTermCCG(ref,target,.0008,.2,'time', [ logspace(log10(5),log10(1000),15)/1000 inf])
%
% To do both modes
% ses = ShortTermCCG(ref,target,.0008,.2,'time', [ logspace(log10(5),log10(1000),15)/1000 inf],'burst',.01)

% Dependencies
% CCGCond, CCGHeartCrossGroup, CCGHeartWithinGroup,kspike, GetTransProb, cch_conv


%assumes sorted inputs
ref = sort(ref);
target = sort(target);

conv_wind = .015;

for i = 1:2:length(varargin)
    
    
    
%handle varargin
 switch varargin{i}
     case 'burst'
         
         burst_ISI = varargin{i+1};
         
         
         %calculate number in burst (0 = no burst)
         b_ISI = kspike(ref,burst_ISI);
         b_ISI = b_ISI+1; %no condition =0
         
        
        %build condition CCG
        times = [ref;target];
        groups = [ones(length(ref),1); 2*ones(length(target),1)];
        
        conditions = [b_ISI;ones(length(target),1)];
        
        [times,b] = sort(times);
        groups = groups(b);
        conditions = conditions(b);
        
        
        [ccg,n,t] = CCGCond(times,groups,conditions,'binsize',binsize,'duration',duration,'across_groups',false);
        ccg = double(squeeze(ccg(:,1,2,:))');
        ses.burst.ccg = ccg;
        ses.burst.n = squeeze(n(:,1,2,:));
        ses.burst.t_lag = t;
        ses.burst.burst_ISI = burst_ISI;
         
     case 'time'
        
         ts_bin = varargin{i+1};
         
         
         %bin reference time series by one back interval
           [~,b_ISI] = histc(diff([0;ref]),ts_bin);
           
           %exclude events where diff(ref) > ts_bin(end)
           kp = (b_ISI>0);
        ref1 = ref(kp);
        b_ISI = b_ISI(kp);

        
        %build condition CCG
        times = [ref1;target];
        groups = [ones(length(ref1),1); 2*ones(length(target),1)];
        
        conditions = [b_ISI;ones(length(target),1)];
        
        [times,b] = sort(times);
        groups = groups(b);
        conditions = conditions(b);
        
        
        [ccg,n,t] = CCGCond(times,groups,conditions,'binsize',binsize,'duration',duration,'across_groups',false);
        ccg = double(squeeze(ccg(:,1,2,:))');
        
        %get trans prob at every ISI
        for ii = 1:size(ccg,1)
           [ses.trans(ii),ses.prob(ii,:),ses.prob_uncor(ii,:)] = GetTransProb(ccg(ii,:)',n(1,1,2,ii),binsize,conv_wind);
            
        end
        ses.time.ccg = ccg;
        ses.time.n = squeeze(n(:,1,2,:));
        ses.time.t_lag = t;
        ses.time.bins = ts_bin;
     otherwise
         error('Wrong conditional type')
 end
 
    


end


  
  
   
        
         