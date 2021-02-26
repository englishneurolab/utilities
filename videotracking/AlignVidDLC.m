function Vtracking = AlignVidDLC(basepath,varargin)
%
% This function is used make fram capture timestamps for Deep Lab Cut
% output that aligns with the Intan .dat timestamps
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Dependencies
%    - Rename the DLC video file to [basename '_VideoTracking.csv']
%    - Video is assumed to be sampleing at 100Hz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input
%    'basepath' - Basepath for the recording file with the DLC output
%               (Default = cd)
%    'syncChan' - Analogin channel that has the sync light pulses
%    'fType'    - File type from your recording (Default = 'analogin')
%               - Options -
%                 - 'digitalin'
%                 - 'analogin'
%    'numIPIs'  - Number of interpulse intervals (IPIs) to align to to make
%               sure you are correctly aligning to the right position
%               (Default = 3)
%    'errWin'   - How much deviation in the interframe interval (IFI) size
%               relative to the IPI sizes do you want to account for? (ex.
%               if selected IFI is 43 indices and you want an error of 5
%               the function will align the IPIs to possible IFIs of (41,
%               42, 43, 44, 45) (Default = 5)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output
%    [basename '_Vtracking.mat']
%        Vtracking
%            .xpos       = X position in pixels, this is taken from the DLC .csv
%            .ypos       = Y position in pixels, this is taken from the DLC .csv
%                          (more important for non-linear track experiments)
%            .frameTimes = time in seconds for each frame
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Todos
%    - Make a smoothing function or optimize DLC to not make large jumps in
%      position
%    - add input for number of IFIs to look over 
%    - clean up some variable names (ex. 'a')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% History
% - (21/2/24) Code written by Kaiser Arndt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Questions for code club
%    - Do you want to have sanity checks in this code?
%        - Make it an input?
%
%% Parse inputs

p = inputParser;
addParameter(p,'syncChan',[7],@isnumeric);
addParameter(p,'fType','analogin',@isstr);
addParameter(p,'numIPIs',3,@isnumeric);
addParameter(p,'errWin',5,@isnumeric);

parse(p,varargin{:});
syncChan   = p.Results.syncChan;
fType      = p.Results.fType;
numIPIs    = p.Results.numIPIs;
errWin     = p.Results.errWin;

%% load in and unpack 

basename = bz_BasenameFromBasepath(basepath);

DLC = readtable([basename '_VideoTracking.csv']); % load in DLC csv

%convert tables into cell arrays
DLC = DLC{:,:};

%Pull out the synclight rows in to numbers
Frames_1 = str2double(DLC(3:end,10));

fName = [basename '_' fType '.dat']

if strcmp(fType, 'analogin')
    % load in synclight analogin channel downsampled to 100hz, convert to volts
    SyncChan_1 = double(LoadBinary([basename '_analogin.dat'], 'frequency', 30000, 'nChannels', 8, 'channels', syncChan, ...
        'downsample', 300)) * 0.000050354;
elseif strcmp(fType, 'digitalin')
    temp = double(LoadBinary([basename '_digitalin.dat'], 'frequency', 30000, 'nChannels', 1)) * 0.000050354;
    SyncChan_1 = (bitand(temp, 2^syncChan)> 0);% ch has a value of 0-15 here
end

%% Find interpulse interval minus 1 (minus one works)

pul = [];
for i = 1:length(SyncChan_1);
    if SyncChan_1(i) < -0.05;
        if i == 1
            continue
        elseif SyncChan_1(i-1) > -0.01;
            pul = [pul; i-1];
            continue
        end
    end
end

stp = [];
for i = 1:length(SyncChan_1);
    if SyncChan_1(i) < -0.05;
        if i == length(SyncChan_1)
            continue
        elseif SyncChan_1(i+1) > -0.01;
            stp = [stp; i+1];
            continue
        end
    end
end

if length(pul) > length(stp) % in the off chance the recording stops during a sync pulse... it's happened
    pul(end) = [];
end

pul(:,2) = stp;

%% sanity check plot (Make this a conditional input)
% figure
% plot(SyncChan_1)
% hold on
% plot(pul(:,1),SyncChan_1(pul(:,1)),'or')
% plot(pul(:,2),SyncChan_1(pul(:,2)),'ob')

%% find time between pulses
for i = 1:length(pul)
    if i == length(pul)
        break
    else
        pul(i,3) = pul(i+1,1)-pul(i,2); % subtract end of first pulse from the start of next pulse = IPI duration
    end
end

pul(:,4) = pul(:,3)/100; %convert to seconds

%% find inter frame interval

SLFs_1 = Frames_1 > 0.9; % find the frames that definitively sync light on

a = find(SLFs_1); % Store logical values

for i = 1:length(a)
    if i == length(a)
        break
    else
        a(i,2) = a(i+1,1)-a(i); % finds duration of frames the sync light is off
    end
end

a(:,3) = a(:,2)/100; % duration in seconds that the sync light if off

% pulls the indices that the sync light is off for more than one frame in
% the video
FrameInt_1 = a(:,2)>1; 
FrameInt_1 = a(FrameInt_1,2); % creates inter frame interval (IFI)

%% look at the over all number of IPIs that are close to the sync light


% using the first IFI size pull all values from the IPI size that are plus
% and minus 2 frames from the IFI size - this accounts for variance in
% sampling/ signal alignment

errWin = (errWin - 1)/2;

alignIPIs = find(ismember(pul(:,3),[FrameInt_1(1)-errWin : FrameInt_1(1)+errWin]),inf);

% pull out the IPI sizes into a new variable with the following 3 IPI sizes
for i = 1:length(alignIPIs)
w(:,i) = pul(alignIPIs(i):alignIPIs(i)+numIPIs,3);
end

% check if the IFI sizes plus and minus 2 frames is within each row
x = [];
for i = 1:4 % this is hard coded to match the error window for alignment
x(i,:) = double(ismember(w(i,:), [FrameInt_1(i)-errWin : FrameInt_1(i)+errWin]));
end

% find index in x that has all 4 IPIs then use that index for alignIPIs
% which then use that value as the index in pul, then align to the start
% index of that pulse

% indexing all the way back from aligned IPI/IFI to the index of the start
% of the aligned sync light pulse in the analogin
alignDwnSmpIdx = pul(alignIPIs(find(ismember(sum(x,1),4))),1) + a(find(ismember(a(:,2), FrameInt_1),1),1); % this is the index to align to from the downsampled analogin


%% Sanity check alignment make optional input

% now convert IFIs to match analogin indexing starting with the
% alignDwnSmpIdx

% add alignment index to IFI windows and subtract the index of the first
% detected frame with the sync light on to fully align

% alignIFIStrStp = alignDwnSmpIdx - a(1,1) + [a(find(ismember(a(:,2), FrameInt_1))) a(find(ismember(a(:,2), FrameInt_1))+1)]

% figure
% plot(SyncChan_1)
% hold on
% plot(pul(:,1),SyncChan_1(pul(:,1)),'or')
% plot(pul(:,2),SyncChan_1(pul(:,2)),'ob')
% plot(alignDwnSmpIdx,0,'ok')
% for i = 1:length(alignIFIStrStp)
% line([alignIFIStrStp(i,1) alignIFIStrStp(i,2)], [0 0],'linewidth', 1)
% end
% 
% plot(pul(:,1),pul(:,1),'ok')
% hold on
% plot(alignIFIStrStp(:,1),alignIFIStrStp(:,1),'or')




%% now align to 30,000 for first frame of the video
align30kIDX = alignDwnSmpIdx * 300


%% Make times and save


Vtracking.xpos = str2double(DLC(3:end,2));
Vtracking.ypos = str2double(DLC(3:end,3));
Vtracking.frameTimes = align30kIdx/ 30000;% divide by natural SR to make times

save([basename '_Vtracking.mat'], 'Vtracking')


















