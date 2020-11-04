% Header script
% by Kevin Parisot
% on 12/06/2018
% v1
% v2 (05/09/2018) : headers for bottom pilots 2,3; aftereffect; and
% topdown
function [] = ExpSetyp(ExpType)

% ExpType can be any of 'GazeEEG', 'TopDown', 'BottomUp', 'AfterEffect'

global Exp

switch ExpType
    case 'GazeEEG'
        Exp.Flags.LEARNON = 1;%0 pour debeug test
        Exp.Flags.SIGMOIDESTIMATE = 0;
        Exp.Flags.EYETRACK = 0;% change to use eyetrack
        Exp.Flags.SAVE = 0;% change to save
        Exp.Flags.SAVEONTHEGO = 0;
        Exp.Flags.DUMMY =0;% to debeug
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