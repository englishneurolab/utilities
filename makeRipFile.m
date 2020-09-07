 numeventtypes = 3;
ripbaseName = [basename '.evt.rip']; % you need the ROX bc neuroscope is buggy and uses this to parse files.
lengthAll = numel(ripples.peaks)*numeventtypes;
        events.time = zeros(1,lengthAll);
        events.time(1:3:lengthAll) = ripples.timestamps(:,1);
        events.time(2:3:lengthAll) = ripples.peaks;
        events.time(3:3:lengthAll) = ripples.timestamps(:,2);
       
        % Populate events.description field
        events.description = cell(1,lengthAll);
        events.description(1:3:lengthAll) = {'start'};
        events.description(2:3:lengthAll) = {'peak'};
        events.description(3:3:lengthAll) = {'stop'};
       
        % Save .evt file for viewing in neuroscope - will save in your current directory
        SaveEvents(fullfile(cd,ripbaseName),events)