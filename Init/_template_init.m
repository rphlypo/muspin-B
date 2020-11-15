Exp.Type = ;  % choose from 'GazeEEG', 'TopDown'
Exp.Flags.EEG = ;  % boolean
Exp.Flags.EYETRACK = ;  % boolean
Exp.Flags.pilot = ;  % boolean

Exp.Flags.SKIPSYNCTESTS = ;  % boolean, make sure to set 'false' for final run
Exp.Flags.LEARNON = ;  % 0 pour debug test, 1 to get the learning phase
Exp.Flags.SIGMOIDESTIMATE = ;  % boolean
Exp.Flags.SAVE = ;  % boolean
Exp.Flags.SAVEONTHEGO = ;  % boolean
Exp.Flags.DUMMY = ;  % boolean; true for debugging purposes
Exp.Flags.KEYPRESSPERCEPT = ;  % boolean, false NKP cond or include in the code ?
Exp.Flags.MOUSE = ;  % boolean
Exp.Flags.MOUSECLICKON = ;  % boolean
Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'
Exp.Flags.VERSION = 0;   % string, int, or float, si ya un pbl faire new version pour eviter ecrase autre people

Exp.Pilot = Exp.Flags.pilot;