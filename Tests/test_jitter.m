% tests

clear
close all
sca;

%% for octave only
% pkg load statistics;

%% add paths
addpath '../Auxilary'
addpath '../Modules'
addpath '../Functions'
addpath '../Analysis'

%% Flags as option selectors
global Exp;
Exp = struct();
Header();
if Exp.Flags.EYETRACK
    Eyelink('ShutDown');
end
correctLearn = true;
Exp.Data.Triggers = [];

%% Start PTB
Screen('Preference', 'SkipSyncTests', 1); % 0 for the final experiment, 1 for debugging

t = clock();
rand('seed', t(end));

%% Flag pre-requisites
if not(Exp.Flags.SAVE)
    PhaseString = 'TEST'; CondString = 'DUMMY';
elseif Exp.Flags.SAVE
    getSubjectID(fullfile('..', 'data'));
end
if Exp.Flags.EYETRACK
    Exp.EyeLink.gui_eye = input('Give the guiding eye : 0 for left, 1 for right : ');
end
if Exp.Flags.EEG
    %initialize the inpout32 low-level I/O driver
    config_io;
    %optional step: verify that the inpout32 driver was successfully installed
    global cogent;
    if( cogent.io.status ~= 0 )
        error('inp/h installation failed');
        return;
    end
end

stars = repmat(['*'], 1, 10);
fprintf([stars 'If not done yet, start EEG recording now' stars '\n']);
KbPressWait();

% Triggers
Exp.Trigger = DefinitionTrigger;  % even if trigger definitions change, this stores the actual definitions
sendTrigger(Exp.Trigger.Init);

%% Generate experiment parameters
GenerateExperimentParameters();

%% Generate experiment structure
GenerateExperimentStructure();

%% Generate Grating texture

% Screen
Exp.PTB.W = .0404;
Exp.PTB.H = .0302; % meters
Exp.PTB.D = round(1e4 * sqrt(Exp.PTB.W^2 + Exp.PTB.H^2)) / 1e4; % .06; % meters
Exp.PTB.res = [1280, 1024];

GenerateExperimentVisuals();

%% PTB initialisation
win = InitialisePTB();

Exp.Current.FixPointJit = Exp.Parameters.FixPoint.Jitter()  % generate on-the-fly

Exp.Stimulus.ovRect = [Exp.PTB.w/2-Exp.Visual.Common.ovSize, Exp.PTB.h/2-Exp.Visual.Common.ovSize, Exp.PTB.w/2+Exp.Visual.Common.ovSize, Exp.PTB.h/2+Exp.Visual.Common.ovSize];

HideCursor;
starttime = GetSecs();
% Draw the perceived background
Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
% Draw normal oval:
Screen('FillOval', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol 255], Exp.Stimulus.ovRect);
Screen('DrawDots', win, [Exp.PTB.w/2 Exp.PTB.h/2], Exp.Visual.Common.dotSize, Exp.Visual.Common.dotcol, [], 2);
vbl = Screen('Flip', win);
if Exp.Flags.EYETRACK
    s = sprintf('FLIP FIX START\n');
    Eyelink('Message',s);
end
sendTrigger(Exp.Trigger.FixationCross.Start);
fliptime = GetSecs() - starttime;
WaitSecs(Exp.Current.FixPointJit - fliptime);  % hold fixation point on screen
stoptime = GetSecs();
if Exp.Flags.EYETRACK
    s = sprintf('FLIP FIX END\n');
    Eyelink('Message',s);
end
sendTrigger(Exp.Trigger.FixationCross.End);
stoptime2 = GetSecs();

sca;

fprintf('Time elapsed: %f\nTarget time: %f\n', stoptime - starttime, Exp.Current.FixPointJit);
fprintf('Time for trigger function %f\n', stoptime2 - stoptime);
