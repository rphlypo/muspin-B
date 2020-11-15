Exp.Type = 'TopDown';
Exp.Flags.EEG = false;
Exp.Flags.EYETRACK = false;
Exp.Flags.pilot = true;
% correctLearn = true; % ??

%% Initialise the recording of triggers in the data structure
Exp.Data.Triggers = [];

%% setup Exp.Flags, override 
Exp.Flags.LEARNON = 1;
Exp.Flags.SIGMOIDESTIMATE = 0;
Exp.Flags.SAVE = 1;
Exp.Flags.SAVEONTHEGO = 1;
Exp.Flags.DUMMY = 0;
Exp.Flags.KEYPRESSPERCEPT = 1;
Exp.Flags.MOUSE = 1;
Exp.Flags.MOUSECLICKON = 0;
Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'

Exp.Pilot = 0;