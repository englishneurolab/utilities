function out = createDatfromLoadBinary(basename,data,nChans) % nChans per .dat?

  %
  %   This function is designed to make a new .dat file from "data" derived via bz_LoadBinary
  %   I cannot remember why i made this function (LK). Probably to remove noise and create a new .dat file to run
  %   Kilosort over or something
  %
  %
  %   USAGE
  %
  %   %% Dependencies %%%
  %   Buzcode
  %
  %   INPUTS
  %   'basepath'          -
  %   'data     '         -
  %   'nChans'            -
  %
  %   OUTPUTS
  %   out        -
  %
  %   HISTORY
  %   2021-01 - Lianne documented
  %
  %

  %% Parse!
  if ~exist('basepath','var')
      basepath = pwd;
  end

  basename = bz_BasenameFromBasepath(basepath);

  p = inputParser;
  addParameter(p,'basename',basename,@isstr);

  parse(p,varargin{:});
  basename        = p.Results.basename;



  cd(basepath)


  %%


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
