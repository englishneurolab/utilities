function out = createDatfromLoadBinary(basename,data,nChans) % nChans per .dat?

for iChan=1:nChans
    rawTrace(iChan,:) = data(:,iChan);
end

int16RawTrace = int16(rawTrace);

intRawVec = zeros((size(int16RawTrace,1)*size(int16RawTrace,2)),1);
intRawVec = int16RawTrace(:);

% cd(resultDir)
fileID = fopen([char(basename), '.dat'], 'w');
fwrite(fileID, intRawVec, 'int16')
fclose(fileID)
clear data rawTrace intRawTrace intRawVec

out = 1;
end
