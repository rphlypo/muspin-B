function [proposed_id] = getSubjectID(datapath)

global Exp;

if ~exist(datapath, 'dir') % it's not an existing folder
    mkdir(datapath)
end

%% Inform whether this is an inclusion in pilot or main study
correct = false;
while ~correct
    try
        n = input('Inclusion in [P]ilot study or main [S]tudy : ', 's');
        if ~(strcmpi(n, 'p') || strcmpi(n, 's'))
            error('Incorrect value')
        else
            n = upper(n)
            correct = true;
        end
    catch
        fprintf('Please type P or S\n')
    end
end

%% Get list of already registered participants
participants = {};
try
    fid = fopen(fullfile(datapath, 'participants.tsv'));
    while ~feof(fid)
        currentLine = fgetl(fid);
        if currentLine ~= -1
            participants{end+1} = currentLine;
        end
    end
catch
    fid = fopen(fullfile(datapath, 'participants.tsv'), 'w');
end
fclose(fid);

%% get a unique ID that is not already in the available subject ID list
validID = false;
while ~validID
    proposed_id = sprintf('%s%07d', n, randi(9999999));  % 7 digit number
    if isempty(participants) || ~ismember(proposed_id, participants)
        validID = true;
        fid = fopen(fullfile(datapath, 'participants.tsv'), 'a+');
        fprintf(fid, '\n%s', proposed_id);
        fclose(fid);
    end
end
fprintf('Subject id: %s %s %s\n', repmat('*', 1, 10), proposed_id, repmat('*', 1, 10));

%% Create data directory and generate filename
mkdir(datapath, proposed_id);
fprintf('Data directory %s succesfully created\n', fullfile(datapath, proposed_id))

Exp.paths.dataDir = fullfile(datapath, proposed_id);
Exp.paths.fileName = [proposed_id '_'  Exp.Type '_Exp.mat'];