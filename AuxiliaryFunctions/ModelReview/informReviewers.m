%% Inform Reviewers About Models
% The purpose of this utility function is to poll the status of all models
% in the project for their review state. If the review state (for either a
% Peer Review, or Programme Review) is set to "To Review" then the user
% will be given a warning alerting them to this fact.


%% Reviewer Lists
% The reviewer lists are cell arrays of the username of each MATLAB user.
% This is the log on name they use to log on to their PC. There are two
% categories of reviewer :
%
% # Peer Reviewer
% # Project Reviewer
%
% A peer reviewer is someone that will review the model on a local basis to
% ensure it is fit for further development. A project reviewer is a review
% who will review the model to ensure it is fit for the programme. A person
% can be an entry in both lists.

%% Acquire Reviewers Table
[ReviewersTable] = assembleReviewers();


%% Check that current user is on lists
% Before checking if the user has files to review, first check if user is a
% registered reviewer.

CurrUser = getenv('USERNAME');
NumReviewers = height(ReviewersTable);
UserFound = false;

for ReviewerIdx = 1 : NumReviewers
    % Search through the review list to see if the current user is in the
    % review list.
    if strcmp(ReviewersTable.Reviewer(ReviewerIdx), CurrUser)
        % User is in the review list
        ReviewerCategory = ReviewersTable.Category(ReviewerIdx);
        UserFound = true;
    end
end

if UserFound == false
    % CASE: The current user is not listed in the  ReviewersTable
    % ACTION: "abort" continued execution of this script
    disp(['User: "', CurrUser, '" not in ReviewersTable']);
    clear ReviewerCategory
    return;
end

%% Get project object
% A SIMULINK Project Object is initialised.

proj = slproject.getCurrentProject;

filesList = proj.Files;
%% Scan for any models marked review
% For every file in the Project, check the status of it.

NumFiles = length(filesList);
NumFilesToReview = 0;
ListFiles = {''};

% Loop over every file to check the label
for File_Index = 1 : NumFiles
    CurFile = filesList(File_Index);
    CurFileLabel = CurFile.Labels;
    
    % Loop over each Label Object entry
    NumLabels = length(CurFileLabel);
    for Label_Index = 1 : NumLabels
        CurLabelCat = CurFileLabel(Label_Index).CategoryName;
        
        % Define paramaters for counting number of models to review based
        % on the user type
        switch ReviewerCategory
            case 'PROG'
                ReqdLabelCat = 'ProgrammeReviewStatus';
            case 'PEER'
                 ReqdLabelCat = 'PeerReviewStatus';
        end
        
        % Found the correct label object
        if strcmpi(CurLabelCat, ReqdLabelCat) == 1
            
            % Check if the label option is the correct category
            if strcmpi(CurFileLabel(Label_Index).Name, 'To Review')
                NumFilesToReview = NumFilesToReview + 1;
                ListFiles{NumFilesToReview} = CurFile.Path;
            end
        end
    end
end


    
%% Push prompt to reviewer
% By the stage the current user has been identified as a reviewer, and the
% number of files that require review have been counted. This information
% is to be published to a pop-up message.

if NumFilesToReview ~= 0
    numModelsStr = ['You have ', num2str(NumFilesToReview),' models to review!'];
    msgbox({numModelsStr ListFiles{:}}, 'Models require review','warn');
elseif NumFilesToReview == 0
    % CASE: User has no files to review
    % ACTION: Push a notification
    disp('No files to review');
end

%% Clean Up
% Clean up workspace

clearvars