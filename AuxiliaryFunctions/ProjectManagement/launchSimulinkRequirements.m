%% Launch Simulink Requirements Editor

% Need to check if Simulink Requirements licence even exists
% TODO - Need the product name
% status = license('test','slrequirements');

% Alternatively catch the error message (if one)
try
    slreq.open('ProjectRequirements');
catch ME
    if strcmp(ME.identifier, 'Slvnv:slreq:FailedToOpen')
        disp('Simulink Requirements not installed.')
    end
end