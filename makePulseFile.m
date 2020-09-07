numeventtypes = 2;
pulbaseName = [basename '.evt.ait']; % you need the ROX bc neuroscope is buggy and uses this to parse files.


lengthAll = length(pulseEpochs)*numeventtypes;
events.time = zeros(1,lengthAll);
events.time(1:2:lengthAll) = pulseEpochs(:,1);
events.time(2:2:lengthAll) = pulseEpochs(:,2);


% Populate events.description field
events.description = cell(1,lengthAll);
events.description(1:2:lengthAll) = {'start'};
events.description(2:2:lengthAll) = {'stop'};

% Save .evt file for viewing in neuroscope - will save in your current directory
SaveEvents(fullfile(cd,pulbaseName),events)