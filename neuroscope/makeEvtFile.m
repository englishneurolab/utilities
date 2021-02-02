function [events] = makeEvtFile(evtEpochs, evtNameStr, evtbaseName, evtHandle)
% evtEpochs are timestamps to be written to an eventfile
%  evtNameStr are the corresponding strings (e.g. 'start','stop','peak')
%  evtbaseName = basename for the eventfile
% evtHandle = 'rip' or 'pul' to identify the eventfile
%  Currently need to write all timestamps in evtEpochs

numeventtypes = numel(evtNameStr);
evtFileName = [evtbaseName '.' evtHandle '.evt'];
% you need the ROX bc neuroscope is buggy and uses this to parse files.


% preallocate
lengthAll = length(evtEpochs)*numeventtypes;
events.time = zeros(1,lengthAll);
events.description = cell(1,lengthAll);

for iNumTypes = 1:numeventtypes
    events.time(iNumTypes:numeventtypes:lengthAll) = evtEpochs(:,iNumTypes)';
    events.description(iNumTypes:numeventtypes:lengthAll) = {evtNameStr{iNumTypes}};
end

% Save .evt file for viewing in neuroscope - will save in your current directory
SaveEvents(fullfile(cd,evtFileName),events)

disp('done')

end