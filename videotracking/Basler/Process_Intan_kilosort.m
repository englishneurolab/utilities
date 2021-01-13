
function Process_Intan_kilosort(fbasename,varargin)

% Process_Intan(fbasename,mergename)
% Process the Intan data folders starting with 'fbasename', rename each
% recording 'fbasename-01,2,3' in chronological order and lauch
% process_multi_start

if isempty(varargin)
    [~,mergename,~] = fileparts(pwd);
else
    mergename = varargin{1};
end
fprintf('Processing %s...\n',mergename);

%%%%%%%%%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%
% convert file format
%%%%%%%%%%%%%%%%%%%%%

recList = Process_IntanData_multi_start(fbasename,mergename);

    %maybe already ran clean up, check for files in right format
if isempty(recList)
    datf = getAllExtFiles(pwd,'dat',1);
    kp = cellfun(@any,regexp(datf,[mergename '-[0-9]+.dat']));
   recList =  datf(kp);
    for ii=1:length(recList)
    recList{ii} = recList{ii}(1:end-4);
    end

end

%if ~ isempty(recList)
%    UpdateXml_MergeName([mergename '-01'],mergename);
%end


end
