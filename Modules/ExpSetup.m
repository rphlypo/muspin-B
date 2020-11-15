% Script to setup the experiment

%% Starting EEG
stars = repmat(['*'], 1, 10);
if Exp.Flags.EEG
    %initialize the inpout32 low-level I/O driver >> change for the 64-bit driver
    config_io;
    %optional step: verify that the inpout32 >> inpout64 driver was successfully installed
    global cogent;
    if( cogent.io.status ~= 0 )
        error('inp/h installation failed');
        return;
    end
    fprintf([stars 'If not yet done, you''re now ready to start the EEG recording' stars '\n']);
    KbPressWait();
end

%% Set-up triggers
Exp.Trigger = DefinitionTrigger();  % even if trigger definitions change, this stores the actual definitions
Exp.Data.Triggers = [];  % Initialise the recording of triggers into the data structure [time, trigger]
sendTrigger(Exp.Trigger.Init);

%% Start PTB
% Screen('Preference', 'SkipSyncTests', Exp.Flags.SKIPSYNCTESTS);

%% get a clock and set the seed for random numbers with it
t = clock();
rand('seed', t(end));

%% useful function to create jitter on demand, uniformly distributed over an interval
jitter = @() Exp.Parameters.FixPoint.WaitTime.Min + (Exp.Parameters.FixPoint.WaitTime.Max - Exp.Parameters.FixPoint.WaitTime.Min).*rand;

%% Generate experiment structure
GenerateExperimentStructure();  % checked, ok

%% Screen dimensions +++++++++++++ NEEDS CHECKING +++++++++++++
Exp.PTB.W = .0404;  % meters ?????
Exp.PTB.H = .0302;  % meters ?????
Exp.PTB.D = round(1e4 * sqrt(Exp.PTB.W^2 + Exp.PTB.H^2)) / 1e4; % .06; % meters
Exp.PTB.res = [1280, 1024];  % resolution in pixels

%% generate Grating texture
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
glsl = GratingCreatingUpdating(win);

%% Sigmoid estimator initialization
% Initialize variables and sigmoid function for psychometric estimation
if Exp.Flags.SIGMOIDESTIMATE
    xs = SigmoidEstimatorInit();
end

%% log-normal parameter estimation data initialization
learn_params_from_data = {};

%% Initialise Eyetracking
if Exp.Flags.EYETRACK
    el = ELInit(win);
end

%% run in dummy mode if data is not to be saved
if ~Exp.Flags.SAVE
    PhaseString = 'TEST'; CondString = 'DUMMY'; 
end