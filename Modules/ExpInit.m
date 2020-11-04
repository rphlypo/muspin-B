function [] = ExpInit(ExpType, GazeOn, EEGOn)

global Exp;
if nargin < 3, EEGOn = false; end
if nargin < 2, GazeOn = false; end

Exp = struct();
Exp.Type = ExpType;
% correctLearn = true; % ??

%% Initialise the recording of triggers in the data structure
Exp.Data.Triggers = [];

%% setup Exp.Flags
switch ExpType
    case 'GazeEEG'
        Exp.Flags.LEARNON = 1;%0 pour debug test
        Exp.Flags.SIGMOIDESTIMATE = 0;
        Exp.Flags.EYETRACK = GazeOn;% change to use eyetrack
        Exp.Flags.SAVE = 1;% change to save
        Exp.Flags.SAVEONTHEGO = 0;
        Exp.Flags.DUMMY =0;% for debugging purposes
        Exp.Flags.KEYPRESSPERCEPT = 1;% 0 for NKP cond or include in the code ?
        Exp.Flags.MOUSE = 0;
        Exp.Flags.MOUSECLICKON = 0;
        Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'
        Exp.Flags.VERSION = 0; % si ya un pbl faire new version pour eviter ecrase autre people
        Exp.Flags.EEG = EEGOn;% change to use eeg

        Exp.Pilot = 1;

    case 'GazeEEG-test'
        Exp.Flags.LEARNON = 1;%0 pour debug test
        Exp.Flags.SIGMOIDESTIMATE = 0;
        Exp.Flags.EYETRACK = 0;% change to use eyetrack
        Exp.Flags.SAVE = 1;% change to save
        Exp.Flags.SAVEONTHEGO = 0;
        Exp.Flags.DUMMY =0;% for debugging purposes
        Exp.Flags.KEYPRESSPERCEPT = 1;% 0 for NKP cond or include in the code ?
        Exp.Flags.MOUSE = 0;
        Exp.Flags.MOUSECLICKON = 0;
        Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'
        Exp.Flags.VERSION = 0; % si ya un pbl faire new version pour eviter ecrase autre people
        Exp.Flags.EEG = 0;% change to use eeg

        Exp.Pilot = 1;

    case 'TopDown'
        Exp.Flags.LEARNON = 1;
        Exp.Flags.SIGMOIDESTIMATE = 0;
        Exp.Flags.EYETRACK = 0;
        Exp.Flags.SAVE = 1;
        Exp.Flags.SAVEONTHEGO = 1;
        Exp.Flags.DUMMY = 0;
        Exp.Flags.KEYPRESSPERCEPT = 1;
        Exp.Flags.MOUSE = 1;
        Exp.Flags.MOUSECLICKON = 0;
        Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'
        Exp.Flags.EEG = 0;

        Exp.Pilot = 0;
    
    case 'BottomUp'
        Exp.Pilot = 3;

    case 'AfterEffect'
        Exp.Pilot = 2;

    otherwise
        error(sprintf('Unknown Exp.Type "%s"', Exp.Type));
end

if Exp.Flags.EYETRACK
    Eyelink('ShutDown'); % Shutdown Eyelink to properly restart later
end