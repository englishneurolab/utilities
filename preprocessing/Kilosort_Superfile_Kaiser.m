%% Kilosort super file
% Run chunks as needed for the recordings
% Be sure to update paths ahead of time in each specific file
% before running change amplifier.dat and amplifier.xml to basename.dat and
% .xml

%%
% % % % % % % % % %
% % KS1 sorting
% % % % % % % % % %

%% Poly3_Chronic
edit KS1_Config_Poly3_Chronic % change paths for things depending on session location

KS1_Run_Poly3_Chronic


%% P-1_chronic

edit KS1_Config_P1_Chronic.m % change paths for things depending on session location

KS1_Run_P1_Chronic


%% H3 Acute

edit KS1_Config_H3_Acute.m % change paths for things depending on session location

KS1_Run_H3_Acute


%% H3 Chronic

edit KS1_Config_H3_Chronic.m % change paths for things depending on session location

KS1_Run_H3_Chronic


%% IDAX 4X32




%%
% % % % % % % % % %
% % KS2 sorting
% % % % % % % % % %
%%  H3_Chronic_RSC 

edit KS2_Config_H3_Chronic.m
edit KS2_Run_H3_Chronic.m

% Run
KS2_Run_H3_Chronic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
