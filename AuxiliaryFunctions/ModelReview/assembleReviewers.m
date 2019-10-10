function [ReviewersTable] = AssembleReviewers()
%ASSEMBLEREVIEWERS Summary of this function goes here
%   Detailed explanation goes here
%% Load source data file
% Import data from external file

FileID = fopen('ReviewerList.txt');
FileData = fscanf(FileID, '%s');
fclose(FileID);

%% Calculate reviewer list sizes
% The number of entries required to populate arrays with Peer Reviewer
% Names and Programme Reviewer Names is deduced.

% Calculate number of 'comma's'
CommaIdxs = strfind(FileData, ',');
NumCommas = length(CommaIdxs);

% Check that all user names contain a review group, i.e. there will be
% multiples of 2 number of commas.
if rem(NumCommas,2) ~= 0
    % ERROR
    disp('ERROR : Source file contains an odd number of commas.');
end

NumEntries = NumCommas/2;



%% Populate arrays
% Pre-Allocate Arrays for Peer Reviewers and Programme Reviewers
Reviewer = cell(NumEntries,1);
Category = cell(NumEntries,1);

% Populate arrays
for ArrayIdx = 1: NumCommas
    % Determine the entry number
    if rem(ArrayIdx,2) == 0
        % This will be the second pair for the entry
    	row = ArrayIdx/2;
    else
        % This will be the first pair for the entry
        row = (ArrayIdx + 1) /2;
    end
    
    % Calculate Start & End points
    if ArrayIdx == 1
        StartIdx = 1;
        EndIdx = CommaIdxs(ArrayIdx) - 1;
    else
        StartIdx = CommaIdxs(ArrayIdx-1) + 1;
        EndIdx = CommaIdxs(ArrayIdx) - 1;
    end
    
    
    % Extract Text
    TextData = FileData(StartIdx: EndIdx);
    
    if rem(ArrayIdx,2) == 0
        % This is review group
        Category{row} = TextData;
    elseif rem(ArrayIdx,2) == 1
        % This is the name group
        Reviewer{row} = TextData;
    end
end

%% Create Table Of Reviewers Against Category

% First convert all entries of CategoryList into upper case - this helps to
% remove any interpretation errors.
Category = upper(Category);

% Then ensure that CategoryList only contains unique values
CategoryOpts = unique(Category);

% Convert Category List into a categorical so that the categories are
% discrete values.
CategoryOpts = categorical(CategoryOpts);

NewCategoryList = categorical.empty(length(Category),0);

for CategoryOptsIdx = 1:length(CategoryOpts)
    % Loop over each unique value of CategoryOpts
    CurrCategoryOpt = CategoryOpts(CategoryOptsIdx);
    
    for CategoryListIdx = 1:length(Category)
        if Category(CategoryListIdx) == CurrCategoryOpt
            NewCategoryList(CategoryListIdx) = CurrCategoryOpt;
        end
    end
end

Category = NewCategoryList';

ReviewersTable = table(Reviewer, Category);
end

