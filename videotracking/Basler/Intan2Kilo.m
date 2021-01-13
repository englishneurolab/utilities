
%%rename intan files (cd into directory and ctr -enter)



dirName  = pwd;
sl = regexp(dirName,'/');
basename = dirName(sl(end)+1:end);

Process_Intan_kilosort(basename);


xmlfil = getAllExtFiles(dirName,'xml',0);
%%concatenate files
datfil = getAllExtFiles(dirName,'dat',0);

datfil = datfil(cellfun(@any,regexp(datfil,[basename '-[0-9]'])));
digitalfils = cellfun(@any,regexp(datfil,'digitalin'));
analogfils = cellfun(@any,regexp(datfil,'analogin'));
auxfils = cellfun(@any,regexp(datfil,'auxiliary'));
datafil = ~ (analogfils | auxfils | digitalfils);

datafil = datfil(datafil);
auxfils = datfil(auxfils);
digfils = datfil(digitalfils);
analogfils = datfil(analogfils);

outfil_xml = [basename '.xml'];
outfil_dat = [basename '.dat'];
analogfils_dat = [basename '_analogin.dat'];
auxfils_dat = [basename '_auxiliary.dat'];
digitalfils_dat = [basename '_digitalin.dat'];
%data file
if length(datafil)>1
    cmd = [];
    for i = 1:length(datafil)
        cmd = [cmd datafil{i} ' ' ];
    end
    cmd = ['cat ' cmd ' > ' outfil_dat];
    status = system(cmd);
    
    if status ==0
        for i = 1:length(datafil)
            cmd = ['rm ' datafil{i} ];
            system(cmd)
            if i ==1
                
                cmd = ['mv ' xmlfil{i} ' ' outfil_xml];
                system(cmd)
            else
                cmd = ['rm ' xmlfil{i} ];
                system(cmd)
            end
            
        end
    end
    
    
    
elseif length(datafil)==1
    cmd = ['mv ' datafil{1} ' ' outfil_dat];
    system(cmd)
    
    cmd = ['mv ' xmlfil{1}  ' ' outfil_xml];
    system(cmd)
end


%analogin file
if length(analogfils)>1
    cmd = [];
    for i = 1:length(analogfils)
        cmd = [cmd analogfils{i} ' ' ];
    end
    cmd = ['cat ' cmd ' > ' analogfils_dat];
    status = system(cmd);
    
    if status ==0
        for i = 1:length(analogfils)
            cmd = ['rm ' analogfils{i} ];
            system(cmd)
        end
    end
    
    
elseif  length(analogfils)==1
    cmd = ['mv ' analogfils{1} ' ' analogfils_dat];
    system(cmd)
end



%digitalin file
if length(digfils)>1
    cmd = [];
    for i = 1:length(digfils)
        cmd = [cmd digfils{i} ' ' ];
    end
    cmd = ['cat ' cmd ' > ' digitalfils_dat];
    status = system(cmd);
    
    if status ==0
        for i = 1:length(digfils)
            cmd = ['rm ' digfils{i} ];
            system(cmd)
        end
    end
    
    
elseif  length(digfils)==1
    cmd = ['mv ' digfils{1} ' ' digitalfils_dat];
    system(cmd)
end


if length(auxfils)>1
    cmd = [];
    for i = 1:length(auxfils)
        cmd = [cmd auxfils{i} ' ' ];
    end
    cmd = ['cat ' cmd ' > ' auxfils_dat];
    status = system(cmd);
    
    if status == 0
        for i = 1:length(auxfils)
            cmd = ['rm ' auxfils{i} ];
            system(cmd)
        end
    end
    
elseif  length(auxfils)==1
    cmd = ['mv ' auxfils{1} ' ' auxfils_dat];
    system(cmd)
end





%%
%make an event file  with basename.evt.sti

dirName  = pwd;
sl = regexp(dirName,'/');
basename = dirName(sl(end)+1:end);
analogfils_dat = [basename '_analogin.dat'];
%define experiment start and stop based off of pulses -  pulse_on pulse_off


system(['neuroscope ' analogfils_dat])



%%
%%get pulse times

dirName  = pwd;
sl = regexp(dirName,'/');
basename = dirName(sl(end)+1:end);
analogfils_dat = [basename '_analogin.dat'];

filename = getAllExtFiles(pwd,'sti',0);
events = LoadEvents(filename{1});
MakeEventTime([dirName '/' analogfils_dat],events,'ch',[ 4],'thres1',3000,'thres2',300); %(1:# is channels 1-#, or [2 4] if only 2 and 4)


%% Extract animal position from avi files

%handle tracking


%get LEDs

%function  pos_inf =  GetPosBaslerBlinkingLED(basepath,aviname,basename,digitalin_ch)
basepath = pwd;
if basepath(end) =='/'
    basepath =  basepath(1:end-1);
end
% find all avis
avifils = getAllExtFiles(basepath,'avi',1);
whl = [];
       
for i = 1:length(avifils)
    
    if i==1
[temp,in,threshF,out] = ApproxMedianFilter_custom(avifils{i},['LED_position-' sprintf('%02.0f',i) '.mat']);
    else
        [temp,in,threshF,out] = ApproxMedianFilter_custom(avifils{i},['LED_position-' sprintf('%02.0f',i) '.mat'],in,threshF,out,false);
    end

whl = [whl;temp];
end
%% Extract times of synchronizing LED from avi files


basepath = pwd;
if basepath(end) =='/'
    basepath =  basepath(1:end-1);
end
% find all avis
avifils = getAllExtFiles(basepath,'avi',1);

%get blinking light
LED = [];
for i = 1:length(avifils)
    
    if i==1
[temp,in,threshF,out] = ApproxMedianFilter_custom(avifils{i},['blink_ON-' sprintf('%02.0f',i) '.mat'],[],[],[],false);
    else
        [temp,in,threshF,out] = ApproxMedianFilter_custom(avifils{i},['blink_ON-' sprintf('%02.0f',i) '.mat'],in,threshF,out,false);
    end

LED = [LED;temp];
end

%%



%LED(LED<=0) = nan;
dirName = pwd;
sl = regexp(dirName,'/');
basename = dirName(sl(end)+1:end);

% kp = (dwnLED-upLED)>1;
% upLED= upLED(kp);
% dwnLED= dwnLED(kp);
%  kp = diff([0;upLED])>100;
%  upLED= upLED(kp);
% dwnLED= dwnLED(kp);
digitalin_ch =1;

[ups,dwns]  =  getBaslerPos(dirName,basename,digitalin_ch,30000);
% ups = ups(1:size(whl,1));


%digitalin_ch =1;
%[ups,dwns]  =  getBaslerPos(dirName,basename,digitalin_ch,30000);
%%
% kp = round(100*(dwns-ups)) ==200;
% 
% 
% ups= ups(kp);
% dwns= dwns(kp);


%get LED files

fils =  getAllExtFiles(pwd,'mat',0) ;
kp = cellfun(@any,regexp(fils,'LED'));
pos_fils = fils(kp);

kp = cellfun(@any,regexp(fils,'blink'));
LED_fils = fils(kp);


kp = cellfun(@any,regexp(fils,'TTL_pulse'));
TTL = fils(kp);
v = load(TTL{1});
ups = v.ups;
dwns = v.dwns;


LED = [];
for i = 1:length(LED_fils)
v = load(LED_fils{i});
LED = [LED;v.whl(:,1)];
end


whl = [];
for i = 1:length(pos_fils)
v = load(pos_fils{i});
whl = [whl;v.whl];
end

%%

% make sure the number of TTL pulses to the intan matches that of the
% number of blinking LEDs in the AVIs



upLED = find(diff(smooth(LED(:,1),10) > 2)>0);
dwnLED = find(diff(smooth(LED(:,1),10) > 2)<0);
%kp = (dwnLED-upLED)>10;
%kp = (dwns-ups)  >1;
%ups = ups(kp);
%dwns = dwns(kp);
figure
plot(diff(upLED),'r') % plot from video
hold on
plot(diff(ups),'k') % plot fro Intan

%  if size(ups,1) == size(upLED,1) and the videos the video break is at the same time, then the experiment was run in order!!
%%

[LEDts,b] = sort([upLED]);
pulsets = [ups];


if length(pulsets)~=length(LEDts)
    error('LED pulse does not match TTL pulse')
end


pulsets = pulsets(b);
if ~all(diff(pulsets)>0)
    disp('temporal mismatch between LED up/LEDdown')
end

     ts1 = interp1(LEDts,pulsets,LEDts(1):LEDts(end));
     
           xx = nanmean(whl(LEDts(1):LEDts(end),[1 3 ]),2);
      yy = nanmean(whl(LEDts(1):LEDts(end),[2 4 ]),2);

      [x,y] = FixPosition(xx,yy,LEDts(1):LEDts(end));
     %%
   
%      
   % ts1 = ups'; 
   %  x = nanmean(whl(:,[1 3 ]),2);
   %   y = nanmean(whl(:,[2 4 ]),2);
     whl(whl<=0) = nan;

       
       kp = ~isnan(y);
     
t = ts1;
x1 = x(kp);
y1 = y(kp);
t1 = t(kp);
x = interp1(t1,x1,t);
y = interp1(t1,y1,t);
%%

kp = ~isnan(y);
[len,pos,xp,yp,del] =linearizePositionTrack(x(:),y(:));
len1 = len(kp)';
len = interp1(t1,len1,t)';
idx = [find(diff(isnan([nan;len]))<0) find(diff(isnan([len;nan]))>0)];


[status, interval] = InIntervals(ts1,ts1(idx));


n1 = histoc(interval(interval>0),1:size(idx,1));

len_ep = mat2cell(len(status),n1);
ts_ep = mat2cell(ts1(status)',n1);
kp = cellfun(@(a) range(a,1),len_ep)>10 ;

len_ep = len_ep(kp);
pos_inf.len_ep = len_ep;
pos_inf.ts_ep = ts_ep(kp);
pos_inf.in_eps =  cellfun(@(a) mean(diff(a))>0,len_ep);
pos_inf.out_eps =  cellfun(@(a) mean(diff(a))<0,len_ep);
pos_inf.x = x(:);
pos_inf.y = y(:);
pos_inf.lin_pos = len;
pos_inf.ts = ts1;
%   ed


        save('position_info.mat','pos_inf')
%end

%%
