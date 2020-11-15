Exp.Type = ExpType;
Exp.Flags.EEG = false;
Exp.Flags.EYETRACK = false;
Exp.Flags.pilot = true;
% correctLearn = true; % ??

%% Initialise the recording of triggers in the data structure
Exp.Data.Triggers = [];

%% setup Exp.Flags, override 
switch ExpType
    case 'GazeEEG'
        Exp.Flags.LEARNON = 1;%0 pour debug test
        Exp.Flags.SIGMOIDESTIMATE = 0;
        Exp.Flags.SAVE = 1;% change to save
        Exp.Flags.SAVEONTHEGO = 0;
        Exp.Flags.DUMMY = 0;% for debugging purposes
        Exp.Flags.KEYPRESSPERCEPT = 1;% 0 for NKP cond or include in the code ?
        Exp.Flags.MOUSE = 0;
        Exp.Flags.MOUSECLICKON = 0;
        Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'
        Exp.Flags.VERSION = 0; % si ya un pbl faire new version pour eviter ecrase autre people

        Exp.Pilot = Exp.Flags.pilot;

    case 'GazeEEG-test'
        Exp.Flags.LEARNON = 1;%0 pour debug test
        Exp.Flags.SIGMOIDESTIMATE = 0;
        Exp.Flags.SAVE = 1;% change to save
        Exp.Flags.SAVEONTHEGO = 0;
        Exp.Flags.DUMMY =0;% for debugging purposes
        Exp.Flags.KEYPRESSPERCEPT = 1;% 0 for NKP cond or include in the code ?
        Exp.Flags.MOUSE = 0;
        Exp.Flags.MOUSECLICKON = 0;
        Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'
        Exp.Flags.VERSION = 0; % si ya un pbl faire new version pour eviter ecrase autre people

        Exp.Pilot = 1;

    case 'TopDown'
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
    
    case 'BottomUp'
        Exp.Pilot = 3;

    case 'AfterEffect'
        Exp.Pilot = 2;

    otherwise
        error(sprintf('Unknown Exp.Type "%s"', Exp.Type));
end