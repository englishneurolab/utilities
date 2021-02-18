function norun = getNoRunEpochs(run)

% This function
%
%   USAGE
%
%   Dependencies:
%   
%
%   INPUTS
%   Name-value paired inputs:
%
%
%   OUTPUTS
%
%   EXAMPLES
%
%
%   NOTES
%
%
%   TO-DO
%
%   HISTORY
%   2021/1  Lianne made this into a function 
%
%
    norun           = zeros(1,length(run.epochs)+1)';
    norun(2:end,1)  = run.epochs(:,2);
    norun(1,1)      = 0;
    norun(1:end-1,2) = run.epochs(:,1);
    norun(end,:)    = [];

end
