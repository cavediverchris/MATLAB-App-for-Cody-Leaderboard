%% New SubSystem
% This script is designed to automate the process of creating a sub system.
% This script will create a new folder with the following files within in:
%
% # the new model
% # a test harness for the new model using model referencing
% # a requirements traceability file
%

%% Clean Up Workspace
close all;
clear all;
clc;

%% Assemble Prefixes
% Import data from external file
[FirstPrefix, FirstPrefixDescription, CombinedArray] = AssembleModelPrefixes;


%% Create Custom Dialog Box for input

[NewModelName] = CreateDialog(CombinedArray, FirstPrefix);

%% Create folder for new model
% The folder to contain the suitable files and fodlers can now be created

ParentFolder = '\Models\';
folderName = NewModelName;

try
    Proj = slproject.getCurrentProject;
    RootFolder = Proj.RootFolder;
catch ME
    if (strcmp(ME.identifier, 'SimulinkProject:api:NoProjectCurrentlyLoaded'))
        % CASE: A Simulink Project is not loaded
        % ACTION: The function is being used outside of SL Project, set a
        % rootfolder path
        RootFolder = pwd;       
    end
end


mkdir([RootFolder, ParentFolder , folderName, '\']);

% Add to path
addpath(genpath([RootFolder,ParentFolder , folderName]));

% Define Test Harness and Model Names
th_name = [folderName, '_TestHarness'];
model_name = [folderName, '_Model'];

%% Create model
% In this cell, we create the new model

open_system(new_system(model_name));

% Add an inport
add_block('simulink/Sources/In1', [gcs, '/Inport']);
set_param([gcs, '/Inport'], 'position', [100 100 130 130]);

% Add a unity gain block
add_block('simulink/Math Operations/Gain', [gcs, '/UnityGain']);
set_param([gcs, '/UnityGain'], 'position', [200 100 230 130]);

% Add an outport
add_block('simulink/Sinks/Out1', [gcs, '/Outport']);
set_param([gcs, '/Outport'], 'position', [300 100 330 130]);

% save current model
save_system(gcs)


% Connect the inport to the gain block
add_line(gcs, 'Inport/1', 'UnityGain/1');

% Connect the gain block to the outport
add_line(gcs, 'UnityGain/1', 'Outport/1');

% Set the configuration to use the configuration reference defined in teh
% data dictionary
% TODO
% attachConfigSet(gcs, FixedStepConfiguration);
% setActiveConfigSet(gcs, FixedStepConfiguration);


% save current model
save_system(gcs)
close_system(model_name);
%movefile [pwd, '\', model_name] [RootFolder, ParentFolder , folderName, '\']

%% Create test harness

SLTestInstalled = license('test', 'Simulink Test');

if SLTestInstalled
    % CASE: Simulink Test is installed, 
    % ACTION:create a test harness using the Simulink Test command
    sltest.harness.create(model_name, ...
                    'Name', ['Test harness for ', model_name], ...
                    'Description', ['Test harness for ', model_name], ...
                    'Source', 'Test Sequence', ...
                    'SeperateAssessment', 'false', ...
                    'SynchronizationMode', 'SyncOnOpenAndClose', ...
                    'CreateWithoutCompile', 'false', ...
                    'VerificationMode', 'Normal', ...
                    'RebuildOnOpen', 'true', ...
                    'SaveExternally', 'true');
                    
else
    % CASE: Simulink Test is not installed
    % ACTION: create a test harness manually
    
    open_system(new_system(th_name));

    % Add an constant block
    add_block('simulink/Sources/Constant', [gcs, '/Constant']);
    set_param([gcs, '/Constant'], 'position', [100 100 130 130]);
    
    % Add a model reference
    add_block('simulink/Ports & Subsystems/Model', [gcs, '/ReferencedModel'])
    set_param([gcs, '/ReferencedModel'], 'position', [200 75 430 150]);
    
    % Add an display
    add_block('simulink/Sinks/Display', [gcs, '/Display']);
    set_param([gcs, '/Display'], 'position', [500 100 550 130]);
    
    save_system(gcs)
    % Set the model reference to point at the previously created model
    set_param([gcs, '/ReferencedModel'], 'ModelName', fullfile(model_name));

    % Connect the constant to the model reference
    add_line(gcs, 'Constant/1', 'ReferencedModel/1');
    
    % Connect the Output of the model reference to the display
    add_line(gcs, 'ReferencedModel/1', 'Display/1');
    
    % Set the configuration to use the configuration reference defined in teh
    % data dictionary
    % TODO
    % attachConfigSet(gcs, FixedStepConfiguration);
    % setActiveConfigSet(gcs, FixedStepConfiguration);
    
    save_system(gcs)
    close_system(th_name);
end

%% Add Requirements Module

newReqSet = slreq.new([RootFolder,ParentFolder , folderName, '\', folderName, '_Reqts']);

% Opens the requirements editor
% myReqSetObj = slreq.open(newReqSet);

% Load the requirements set
% myReqSetObj = slreq.load(newReqSet);

% Set the description of the linkset
% TODO

%% Move Models
% Main steps of functionality:
%
% # The directory is changed to ensure that only the intended files are
% renamed.
% # Copied files are renamed
% # Model referencing updated
% # Add to Project
% # directory returned to original
%
Path = [RootFolder, ParentFolder, folderName];

% use movefile to perform a rename
movefile([model_name,'.slx'], [Path, '\', model_name, '.slx']);
movefile([th_name,'.slx'], [Path, '\', th_name, '.slx']);

% Change model reference properties of model in test harness to the model
% in the newly moved location (ignore the .slx at the end of th_name)
load_system(th_name);
set_param(strcat(th_name, '/ReferencedModel'), 'ModelName', fullfile(model_name))
save_system(th_name);

%% Add to project
folderContents = ls([Path, '\']);
[numFiles, ~] = size(folderContents);

% loop over each entry in folderContents, first two entries are just
% markers for higher levels
for fileIdx = 3:numFiles
  addFile(Proj, [Path, '\', folderContents(fileIdx,:)]);
  disp(['Added file: ', folderContents(fileIdx,:), ' to project.']);
end

%% Add to path
% In this cell the folder is also added to the project path

addPath(Proj,[Path, '\']);
