function [pulses] = makePulsesStruct(basename,pulseEpochs)

pulses.timestamps  = pulseEpochs;
pulses.peaks = (pulseEpochs(:,2)-pulseEpochs(:,1))/2;
pulses.amplitude = [];
pulses.amplitudeUnits = [];
pulses.eventID = ones(length(pulseEpochs),1);
pulses.eventIDlabels = cell(1,length(pulses.timestamps));
pulses.eventIDlabels(:) = {'OptoStim'};
% pulses.eventIDlabels: cell array with labels for classifying various event types defined in stimID (cell array, Px1).
% pulses.eventIDbinary: boolean specifying if eventID should be read as binary values (default: false).
pulses.center = pulses.peaks;%;
pulses.duration = pulseEpochs(:,2)-pulseEpochs(:,1);
pulses.detectorinfo = 'getPulseEpochs';

save(strcat(basename, '.pulses.events.mat'), 'pulses')
end
