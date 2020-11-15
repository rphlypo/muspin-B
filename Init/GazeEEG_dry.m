Exp.Type = 'GazeEEG';
Exp.Flags.EEG = false;
Exp.Flags.EYETRACK = false;
Exp.Flags.pilot = true;
% correctLearn = true; % ??

Exp.Flags.SKIPSYNCTESTS = true;

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