%% CLEAN_UP_PROJECT
% The CLEAN_UP_PROJECT script is designed to run on Project Close to clean
% up (remove) the local customisations made to the MATLAB Interactive
% Development Environment (IDE).

% Clear up workspace for dialog message
clc;

% Close down project
disp('Closing down project.');

% Reset the location where generated code and other temporary files are
% created (slprj) to the default:
Simulink.fileGenControl('reset');
