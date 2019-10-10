function [FirstPrefix, FirstPrefixDescription, CombinedArray] = AssembleModelPrefixes()
%ASSEMBLEMODELPREFIXES Generate arrays that contain valid prefixes for
%models
%   In this function, an external file containing the valid prefixes are
%   imported.
%% Assemble Prefixes
% Import data from external file

FileID = fopen('SubSystemPrefixes.txt');
PrefixData = fscanf(FileID, '%s');
fclose(FileID);

% Calculate number of 'comma's'
CommaIdxs = strfind(PrefixData, ',');
NumCommas = length(CommaIdxs);

% Check that all prefixes contain a definition, i.e. there will be
% multiples of 2 number of commas.
if rem(NumCommas,2) ~= 0
    % ERROR
    disp('ERROR : Source file contains an odd number of commas.');
end

%% Pre-Allocate Memory
% Pre-Allocate Arrays for Prefix and Rationale
NumEntries = NumCommas/2;
FirstPrefix = cell(NumEntries,1);
FirstPrefixDescription = cell(NumEntries,1);

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
    TextData = PrefixData(StartIdx: EndIdx);
    
    if rem(ArrayIdx,2) == 0
        % This is rationale
        FirstPrefixDescription{row} = TextData;
    elseif rem(ArrayIdx,2) == 1
        % This is prefix
        FirstPrefix{row} = TextData;
    end
end

%% Create a combined array
% Merge the two arrays
numPrefixes = length (FirstPrefix);
CombinedArray = cell(1, numPrefixes);

for PrefixIdx = 1 : numPrefixes
    CombinedArray{PrefixIdx} = [FirstPrefix{PrefixIdx} FirstPrefixDescription{PrefixIdx}];
end
end

