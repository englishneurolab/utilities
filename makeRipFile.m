 numeventtypes = 3;
 basename = bz_BasenameFromBasepath(cd);
 load([basename '.ripples.events.mat'])
ripbaseName = [basename '.evt.rip']; % you need the ROX bc neuroscope is buggy and uses this to parse files.
%%
lengthAll = numel(ripples.peaks)*numeventtypes;
        events.time = zeros(1,lengthAll);
        events.time(1:3:lengthAll) = ripples.timestamps(:,1);
        events.time(2:3:lengthAll) = ripples.peaks;
        events.time(3:3:lengthAll) = ripples.timestamps(:,2);
       
        % Populate events.description field
        events.description = cell(1,lengthAll);
        events.description(1:3:lengthAll) = {['start' num2str(ripples.detectorinfo.detectionchannel)]};
        events.description(2:3:lengthAll) = {['peak' num2str(ripples.detectorinfo.detectionchannel)]};
        events.description(3:3:lengthAll) = {['stop' num2str(ripples.detectorinfo.detectionchannel)]};
       
        % Save .evt file for viewing in neuroscope - will save in your current directory
        SaveEvents(fullfile(cd,ripbaseName),events)