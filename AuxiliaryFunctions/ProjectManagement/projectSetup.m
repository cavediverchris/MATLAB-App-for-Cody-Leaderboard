%% Project Set Up
% This script sets up the environment for the current Simulink Project.
% This script needs to be added to the Shortcuts to Run at Start to ensure
% all the initialisation is conducted at project start.

%% Clear the workspace and command window
% The workspace is cleared of all current variables and all windows are
% closed.
clc
clear all
close all

%% Acquire SIMULINK Project Information
% Set up the SIMULINK Project object based upon the release.

projObj = simulinkproject;

%% Set Project Paths
% Project paths are set based on information in the project_paths script as
% well as setting the default folder for code generation etc.

% Print message to screen.
disp(['Initialising Project : ',projObj.Name])

if verLessThan('matlab','R2018B')
    % CASE: R2018B template project includes parameters to automatically
    % set both the code-gen and cache folders.
    % ACTION: only in earlier releases is manual specification of these
    % paths required.
    
    % Create the location of slprj to be the "work" folder of the current project:
    myCacheFolder = fullfile(projObj.RootFolder, 'SimulationRunTimeFiles');
    if ~exist(myCacheFolder, 'dir')
        mkdir(myCacheFolder)
    end
    
    % Create the location for any files generated during build for code
    % generation.
    myCodeGenFolder = fullfile(projObj.RootFolder, 'CompiledCode');
    if ~exist(myCodeGenFolder, 'dir')
        mkdir(myCodeGenFolder)
    end
    
    % Set both the code generation and work folder paths.
    Simulink.fileGenControl('set', 'CacheFolder', myCacheFolder, ...
        'CodeGenFolder', myCodeGenFolder);
    
    clear myCacheFolder myCodeGenFolder;
elseif ~verLessThan('matlab','R2019B')
    % CASE: Within the project it is possible to define cache and code
    % gen folders. 
    % ACTION: Check if these have been defined
    
    
    % Check for Simulink Cache Folder
    if strcmp(projObj.Information.SimulinkCacheFolder, projObj.RootFolder)
        % CASE: The Simulink Cache folder is the same as the root, this
        % means that the project does not define the Simulink Cache Folder
        % ACTION: specify the Simulink Cache folder
        
        % Create the location of slprj to be the "work" folder of the current project:
        myCacheFolder = fullfile(projObj.RootFolder, 'SimulationRunTimeFiles');
        if ~exist(myCacheFolder, 'dir')
            mkdir(myCacheFolder)
        end
        
        Simulink.fileGenControl('set', 'CacheFolder', myCacheFolder);
    end
    
    % Check for Simulink Code Generation Folder
    if strcmp(projObj.Information.SimulinkCodeGenFolder, projObj.RootFolder)
        % CASE: The Simulink Code Gen folder is the same as the root, this
        % means that the project does not define the Simulink Cache Folder
        % ACTION: specify the Simulink Code Gen folder
        
        % Create the location of slprj to be the "work" folder of the current project:
        myCodeGenFolder = fullfile(projObj.RootFolder, 'CompiledCode');
        if ~exist(myCodeGenFolder, 'dir')
            mkdir(myCodeGenFolder)
        end
        
        Simulink.fileGenControl('set', 'CodeGenFolder', myCodeGenFolder);
    end
end
%% Refresh SIMULINK Browser
% This is used to make sure that custom libraries are re-loaded from the
% project workspace

if verLessThan('matlab','R2015a')
    % Print message to screen.
    disp('Refreshing Simulink Library Browser');
    LibBrow = LibraryBrowser.StandaloneBrowser;

    LibBrow.refreshLibraryBrowser
end

%% Back Up - Project Folder
% This schedules an aut-export of the Simulink project every day, it simply
% checks whether a folder with the project name / date exists in the export
% location

% Print message to screen.
disp('Back Up Process');

% Set this flag to false to disable archiving
BackUpFlag = true;

% Define the location for export. This is based upon taking the highest
% level possible on the same drive as the project location.
CurrentFolder = projObj.RootFolder;
slashIdx = strfind(CurrentFolder, '\');
exportLocation = CurrentFolder(1:slashIdx(1));
exportLocation = [exportLocation 'SLProjBackUps\'];

% Check that exportLocation is a valid path
if exist(exportLocation, 'dir') == 0
    % CASE: exportLocation does not exist as a path
    % ACTION: create folder at exportLocation
    try
        mkdir(exportLocation);
    catch ME
        % TODOD
        if strcmp(ME.identifier, 'MATLAB:MKDIR:OSError')
            disp(['Cannot create folder at path: ', exportLocation]);
        end
    end
end

backupFile = strcat(exportLocation, projObj.Name, '_backup_', date,'.zip');

% Check if the backup file exists for today, if not, create it.
if BackUpFlag == false
    % Print message to screen.
    disp('... Secondary back-up disabled.')
elseif exist(backupFile , 'file') == 0 & (BackUpFlag == true)
    % Print message to screen.
    disp(strcat(['... No archive file found, exporting project to ', backupFile]))
    
    %dbstop if caught error
    export(projObj, backupFile);
    %dbclear all
    
    % Print message to screen.
    disp('... Back up completed.')
elseif exist(backupFile , 'file') == 2
    % Print message to screen.
    disp ('... Archive file found for current project - skipping export')
end

%% Update Template Folder
% In this section the path that contains templates for use by other projects is defined.
ProjectTemplatePath = 'C:\Users\chris\MATLAB\';

myTemplate = Simulink.exportToTemplate(projObj, 'SimulinkProjectTemplate', ...
                 'Group', 'Simulink', ...
                 'Author', getenv('username'), ...
                 'Description', 'This is my template to use a Simulink Project', ...
                 'Title', 'Template Simulink Project', ...
                 'ThumbnailFile', [projObj.RootFolder, '\AuxiliaryFunctions\ProjectManagement\TemplateThumbnailImage.png']);

% Move the newly created template to the communal templates folder
movefile(myTemplate, ProjectTemplatePath, 'f');

%% Clean Up
% clear up the workspace
clear all;
