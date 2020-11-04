% Script to setup the experiment

%% Start PTB
Screen('Preference', 'SkipSyncTests', 1); % 0 for the final experiment, 1 for debugging

t = clock();
rand('seed', t(end));

%% Get subject ID
if Exp.Flags.SAVE
    getSubjectID(fullfile('..', 'data'));
else
    PhaseString = 'TEST'; CondString = 'DUMMY'; 
end

if Exp.Flags.EYETRACK
    Exp.EyeLink.gui_eye = input('Give the guiding eye : 0 for left, 1 for right : ');
end

%% Starting EEG
stars = repmat(['*'], 1, 10);
if Exp.Flags.EEG
    %initialize the inpout32 low-level I/O driver
    config_io;
    %optional step: verify that the inpout32 driver was successfully installed
    global cogent;
    if( cogent.io.status ~= 0 )
        error('inp/h installation failed');
        return;
    end
    fprintf([stars 'If not done yet, start EEG recording now' stars '\n']);
    KbPressWait();
end

% Triggers
Exp.Trigger = DefinitionTrigger();  % even if trigger definitions change, this stores the actual definitions
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

% Keypress parameters:
escapeKey   = KbName('ESCAPE');
leftKey     = KbName('LeftArrow');
rightKey    = KbName('RightArrow');
upKey       = KbName('UpArrow');
spaceKey    = KbName('space');
KeyList     = [escapeKey, leftKey, rightKey, upKey, spaceKey];

if Exp.Flags.DUMMY
    keyCode = zeros(1,256);
end

%% Grating creating
[glsl] = GratingCreatingUpdating(win, 0);

%% Sigmoid estimator initialization
% Initialize variables and sigmoid function for psychometric estimation
if Exp.Flags.SIGMOIDESTIMATE
    SigmoidEstimatorInit();
end

%% log-normal parameter estimation data initialization
learn_params_from_data = {};

%% Initialise Eyetracking
if Exp.Flags.EYETRACK
    el = ELInit(win);
end

%% Experiment text
PrepareExpText();