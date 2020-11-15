%% Get subject ID
subjID = getSubjectID(fullfile('..', 'data'));

%% Register the subject's guiding eye
if Exp.Flags.EYETRACK
    Exp.EyeLink.gui_eye = input('Give the guiding eye : 0 for left, 1 for right : ');
end