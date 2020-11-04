%
function [vel_cm_s, time, dt] = getVelocity(analogin, params);

pos = analogin.pos;
time = analogin.ts;

% opts.downsampleFactor = 300;
% pos = downsample(pos, opts.downsampleFactor);
% pos = movmean(pos,10); ;%nb hardcoded
% time = downsample(time,opts.downsampleFactor);

pos_scaled = pos-min(pos);
pos_in_cm =  pos_scaled*(params.circDisk)/max(pos_scaled);

% additive positions (roll-out-the-wheel)
allidx = find(abs(diff(pos_in_cm))>10); % nb thr = hardcoded
for idx = 1:length(allidx)
    
    if allidx(idx) < allidx(end-1)
        pos_in_cm(allidx(idx)+1:allidx(idx+1)) = pos_in_cm(allidx(idx)+1:allidx(idx+1)) + pos_in_cm(allidx(idx));
    else
        pos_in_cm(allidx(idx)+1:end) = pos_in_cm(allidx(idx)+1:end)+ pos_in_cm(allidx(idx));
    end
end


figure,subplot(3,1,1) ,plot(time,pos_in_cm)
xlim([0 4500])
vel_cm = diff(pos_in_cm);
title('cumulative pos')
subplot(3,1,2),plot(time(2:end), vel_cm)
xlim([0 4500])
title('vel_cm')


dt =time(2)-time(1);%1/30000; %of

vel_cm_s = vel_cm/dt;
vel_cm_s = movmean(vel_cm_s,1000000);

subplot(3,1,3),plot(time(2:end),vel_cm_s)
xlim([0 4500])
title('vel_cm_s')

end



%params.radiusDisk   = 26;
% params.circDisk     = 2*pi*params.radiusDisk;