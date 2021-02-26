function ShortTermPlasticity_noStim(basepath,varargin)
%
% This function is designed to get monosynaptic connections for the cells
% and find which cells are indeed significantly modulated by the
% stimulation The output of this function is used for getPhaseMap and
% Connectivity_Map
%
%
%   USAGE
% 
%
%   % Dependencies %
%   Requires buzcode functions
%   Requires the output of the function getOptoStim (ie, the struct optmod)
%
%   INPUTS
%   basepath
%   
%   Name-value pairs:
%   'basename'  - only specify if other than basename from basepath
%   'saveMat'   - saving the results to [basename,
%                   '.burstMizuseki.analysis.mat']
%   'saveAs'    - if you want another suffix for your save
%
%   OUTPUTS
% 
%
%   EXAMPLE
%
%
%   HISTORY
%   2020/2 Code adapted from ShortTermPlasticity_axax by Kaiser Arndt
%
%   TO-DO
%   - Change name of function

%% Parse!
% 
if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);


p = inputParser;
addParameter(p,'basename',basename,@isstring);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'saveAs','.STP.mat',@isstring);


parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
saveAs          = p.Results.saveAs;

cd(basepath)

%%
mono_res =  bz_GetMonoSynapticallyConnected(basepath,'plot',false);

%% define monosynaptically connected pairs  (currently being edited, not super sure what happens here)
ii=1; % start counter
mono_con_axax_idx = []; % added LK, mono_con_axaxidx was not matching mono_res.sig_con
mono_con_axax = [];
pre_idx =[];
post_idx =[];
prob_uncor =[];
acg_pre =[];
acg_post =[];
prob =[]; % reserve spaces

for i = 1:length(mono_res) % uncommented, lianne
    if ~isempty(mono_res(i).sig_con)% uncommented, lianne
        mono_con_axax_idx =  ismember(mono_res.sig_con(:,2),kp); 
        % find which interneurons of the monosynaptically connected pairs
        % are AACs, this uses cell that are modulated by stimulation, not
        % sure if this is the best way for selecting cells
        
        mono_con_axax = mono_res.sig_con(mono_con_axax_idx,:); % list of AACs with monosynaptic connections
        pre_idx = [pre_idx; mono_res.completeIndex(mono_con_axax(:,1),:)]; % find complete cell index of the presynaptic cell to the AACs
        post_idx = [post_idx; mono_res.completeIndex(mono_con_axax(:,2),:)]; % find the complete index to the AACs
        for k = 1:size(mono_con_axax,1)
            prob_uncor(ii,:) = mono_res.prob_noncor(:,mono_con_axax(k,1),mono_con_axax(k,2));
            acg_pre(ii,:)  = mono_res.prob_noncor(:,mono_con_axax(k,1),mono_con_axax(k,1)); % ACG of presynaptic cells
            acg_post(ii,:)  = mono_res.prob_noncor(:,mono_con_axax(k,2),mono_con_axax(k,2)); % ACG of postsynaptic AACs
            prob(ii,:)  = mono_res.prob(:,mono_con_axax(k,1),mono_con_axax(k,2)); % connection probably from from the mono_res
            ii= ii+1;
        end
        
        
        spikes = bz_GetSpikes('basepath', basepath);
        %% needed for plotting
        for i = 1:size(mono_con_axax,1)
            if size(mono_con_axax,1) == 0
                fprintf('no monosynaptic connections \n')
                continue
            else
                
                ref = spikes.times{mono_con_axax(i,1)};
                target = spikes.times{mono_con_axax(i,2)};
                [status] = InIntervals(ref,gd_eps);
                ref = ref(status);
                [status] = InIntervals(target,gd_eps);
                target = target(status);
                ses(i) = ShortTermCCG(ref,target,.0008,.2,'time', [ logspace(log10(5),log10(3000),20)/1000 inf]);
            end
        end
        
        %% Organize output
        if size(mono_con_axax,1) == 0
            fprintf('no monosynaptic connections \n')
            STP = 0
        else
            STP.mono_con_axax_idx = mono_con_axax_idx;
            STP.mono_con_axax = mono_con_axax;
            STP.pre_idx = pre_idx;
            STP.post_idx = post_idx;
            STP.prob_uncor = prob_uncor;
            STP.acg_pre = acg_pre;
            STP.acg_post = acg_post;
            STP.prob = prob;
            STP.gd_eps = gd_eps;
            STP.ses = ses; % really only needed for plotting

        end
    end
    STP.kp = kp;
    
    %%
    %save all variable to output file
    if saveMat
            save([basename  'saveAs'], 'STP')
    end