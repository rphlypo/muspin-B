%% the experimental paradigm
Exp.Type = 'GazeEEG';

% ------------------------ %
% setting experiment flags %
% ------------------------ %
Exp.Flags.EEG = true;
Exp.Flags.EYETRACK = true;
Exp.Flags.pilot = false;
Exp.Flags.SKIPSYNCTESTS = false;
Exp.Flags.LEARNON = true;%0 pour debug test
Exp.Flags.SIGMOIDESTIMATE = false;
Exp.Flags.SAVE = true;% change to save
Exp.Flags.SAVEONTHEGO = true;
Exp.Flags.DUMMY = false;% for debugging purposes
Exp.Flags.KEYPRESSPERCEPT = true;% 0 for NKP cond or include in the code ?
Exp.Flags.MOUSE = false;
Exp.Flags.MOUSECLICKON = false;
Exp.Flags.VERSION = 1; % si ya un pbl faire new version pour eviter ecrase autre people
Exp.Pilot = Exp.Flags.pilot;

% --------------------------------------- %
% setting typical experimental parameters %
% --------------------------------------- %
Exp.Parameters.Phases = {'LEARN', 'ESTIM', 'TEST'};

Exp.Parameters.LEARN.Conditions = {'Amb_Kp', 'nAmb_Kp', 'Amb_nKp', 'nAmb_nKp'};
Exp.Parameters.ESTIM.Conditions = {'Amb_Kp'};
Exp.Parameters.TEST.Conditions = {'Amb_Kp', 'nAmb_Kp', 'Amb_nKp', 'nAmb_nKp'};

Exp.Parameters.LEARN.Shuffling = 'Blocks'; % 'None', 'Blocks' or 'Trials'
Exp.Parameters.ESTIM.Shuffling = 'Trials'; % 'None', 'Blocks' or 'Trials'
Exp.Parameters.TEST.Shuffling = 'Blocks'; % 'None', 'Blocks' or 'Trials'

Exp.Parameters.LEARN.NumberOfBlocks = 1;% 4 amb KP de 10 sec /essai + 1 toutes conditions de 10sec/essai
Exp.Parameters.LEARN.LengthOfBlocks = length(Exp.Parameters.LEARN.Conditions);%4
Exp.Parameters.ESTIM.NumberOfBlocks = 1;% 4 amb KP de 10 sec /essai + 1 toutes conditions de 10sec/essai
Exp.Parameters.ESTIM.LengthOfBlocks = 4;
Exp.Parameters.TEST.NumberOfBlocks = 14; %14;% avec fixation etc, 1 bloc =env 3 min. 20 block = 1h, donc 20-4 (bloc apprentissage) = 16
Exp.Parameters.TEST.LengthOfBlocks = length(Exp.Parameters.TEST.Conditions);%4

Exp.Parameters.LEARN.initText = ['Phase d''entrainement \n'];
Exp.Parameters.ESTIM.initText = ['Phase d''apprentissage des paramètres \n'];
Exp.Parameters.TEST.initText = ['Phase d''experience \n'];

for i=1:length(Exp.Parameters.Phases)
    Exp.Parameters.(Exp.Parameters.Phases{i}).MaxPureStates = 11;
    Exp.Parameters.(Exp.Parameters.Phases{i}).MinPureStates = 0;
end

% Timeout of trials in seconds:
Exp.Parameters.LEARN.TrialTimeOut = 10;
Exp.Parameters.TEST.TrialTimeOut = 40;  % 40
Exp.Parameters.ESTIM.TrialTimeOut = 40;  % 40

%% global experiment parameters
% Minimum number of reversals needed to end trial:
Exp.Parameters.ReversalThres = 5;  % 40
% Gaussian sampling parameters for alpha selection:
Exp.Parameters.AlphaSampling = [.5, .05];
Exp.Parameters.LognRnd = [1, .75];
Exp.Parameters.AlphaPercepts = ...
    [  1, .9, .1; ...
      10, .1, .9; ...
     100, .9, .9];
% jitter
Exp.Parameters.FixPoint.WaitTime.Min = .9;
Exp.Parameters.FixPoint.WaitTime.Max = 1.3;

% -------------------------------- %
% Visualisation related parameters %
% -------------------------------- %

% Background:
Exp.Visual.Common.bckcol = .35; % large background
Exp.Visual.Common.texcol = .65; % text color
Exp.Visual.Common.bckcol2 = .35 + .15; % background behind gratings
% Grating texture size:
Exp.Visual.Common.gratSizeDeg = 12; % in visual degrees
% Number of Gratings
Exp.Visual.Common.nbGratings = 2;
% Aperture size:
Exp.Visual.Common.apSize = 200; %angle2pix(Exp.PTB.W, Exp.PTB.res(1), Exp.PTB.D, Exp.Visual.Common.apSizeDeg); %Exp.Visual.Common.gratSize/2; % radius in pixel
% Gaze oval zone size:
Exp.Visual.Common.ovSizeDeg = 1.25; % in degrees
% Fixation dot size:
Exp.Visual.Common.dotSize = 2; % radius in pixels
Exp.Visual.Common.dotcol = ones(1, 3) * .7; % RGB
% Mouse response zone parameters:
Exp.Visual.Common.MouseRespOvalOffsetDeg = 2; % in degrees

% Egalisateur et controle de luminance et contraste 
% (calcul?s pour alphas = [.5 .5], bg=.5, g=.35 et r=.35):
Exp.Visual.Common.LuminanceRef = 0.4521; % ? changer au niveau du bckcol
Exp.Visual.Common.ContrastRef = 0.0426;

%% Grating1:
% contrast within gratings:
Exp.Visual.Grating(1).mean = .35;
Exp.Visual.Grating(1).standev = .15; % mean; B/W difference
% Speed of motion: (options: .5, 1, 2)
Exp.Visual.Grating(1).speed(1) = 1.5 ; % visual degrees per second
% Angle from verticle axis:
Exp.Visual.Grating(1).rotAngles(1) = 30;
% Transparency parameter:
Exp.Visual.Grating(1).globalAlpha(1) = .5;

% Frequency (or period?) of sin e grating:
Exp.Visual.Grating(1).freq = .01; % per pixel?
% Phase of underlying sine grating in degrees:
Exp.Visual.Grating(1).phase = 0;
% Dutycycle, relative size of white part of grating period:
Exp.Visual.Grating(1).dutycycle = .35;

% Useless parameters:
% Spatial constant of the exponential "hull" (contrast within the grating?)
Exp.Visual.Grating(1).spatialconstant = 1;
% Contrast of grating:
Exp.Visual.Grating(1).contrast = 1;
% Aspect ratio width vs. height:
Exp.Visual.Grating(1).aspectratio = 0;

%% Grating2:
% contrast within gratings:
Exp.Visual.Grating(2).mean = Exp.Visual.Grating(1).mean;
Exp.Visual.Grating(2).standev = Exp.Visual.Grating(1).standev;
% Speed of motion:
Exp.Visual.Grating(2).speed = -Exp.Visual.Grating(1).speed; % visual degrees per second
% Angle from verticle axis:
% rotAngles(2) = -rotAngles(1);
Exp.Visual.Grating(2).rotAngles = -Exp.Visual.Grating(1).rotAngles;
% Transparency parameter:
Exp.Visual.Grating(2).globalAlpha = Exp.Visual.Grating(1).globalAlpha;
% Frequency (or period?) of sine grating:
Exp.Visual.Grating(2).freq = Exp.Visual.Grating(1).freq;
% Phase of underlying sine grating in degrees:
Exp.Visual.Grating(2).phase = 0;
% Dutycycle, relative size of white part of grating period:
Exp.Visual.Grating(2).dutycycle = Exp.Visual.Grating(1).dutycycle;

% Useless parameters:
% Spatial constant of the exponential "hull" (contrast within the grating?)
Exp.Visual.Grating(2).spatialconstant = 1;
% Contrast of grating:
Exp.Visual.Grating(2).contrast = 1;
% Aspect ratio width vs. height:
Exp.Visual.Grating(2).aspectratio = 0;

% --------------- %
% text and images %
% --------------- %
% if Exp.Flags.EYETRACK
Exp.Text.startingMsg='Vous allez passer une experience d''oculometrie.\n\nAvant de commencer l''experience nous allons ajuster l''oculometre.\n\nVous devez pour cela placer votre visage sur le support.\n\n\nAppuyez pour continuer.';
Exp.Text.driftCorrectionMsg='Fixer le point sans cligner des yeux.';
% else, Exp.Text.startingMsg= 'Vous allez passer l''experience Gaze-EEG.\n\n\n Appuyez sur espace pour commencer.'; end
Exp.Text.trackerSetupMsg='Durant la phase de calibration nous allons ajuster les cameras sur vos yeux.\n\n\nVous devrez suivre du regard le point qui apparaitra.\n\nSuivez ce point sans cligner des yeux et sans essayer d''anticiper sa position. \n\n\n\nUne fois la calibration faite, veuillez ne plus bouger la tete\n\n\nAppuyez pour continuer.';
Exp.Text.learningMsg='Phase d''apprentissage pour vous familiariser avec l''experience.';
Exp.Text.testingMsg='Nous allons maintenant commencer l''experience.\n\n Essayez de bouger le moins possible.';
Exp.Text.endingMsg='Merci de votre participation !';
Exp.Text.readyMsg='Appuyez sur espace quand vous etes pret(e).';
Exp.Text.seqEndMsg='Fin de la sequence';
Exp.Text.blockEndMsg='Fin du block';

Exp.Picture.Consigne = fullfile('Images', 'Consigne.jpg');
Exp.Picture.AmbKp = fullfile('Images', 'PRESS.jpg');%'Maintenez le regard sur le point de fixation qui se trouve au centre.\n\n Votre main doit être posée confortablement sur le clavier, avec :\n\n - Un doigt posé sur la touche "flèche du haut", \n\n - Un doigt posé sur la touche "flèche de droite", \n\n - Un doigt posé sur la touche "flèche de gauche"\n\nAppuyez sur la flèche du clavier correspondant aux mouvements des barres.\n\nMaintenez la flèche autant de temps que vous verrez les barres se deplacer dans cette direction.\n\n Lorsque les barres changent de direction, changez de touche le plus rapidement possible.'; %'Consigne BASELINE';%'Ambigue key press';
Exp.Picture.nAmbKp = fullfile('Images', 'PRESS.jpg');%'Maintenez le regard sur le point de fixation qui se trouve au centre.\n\n Votre main doit être posée confortablement sur le clavier, avec :\n\n - Un doigt posé sur la touche "flèche du haut", \n\n - Un doigt posé sur la touche "flèche de droite", \n\n - Un doigt posé sur la touche "flèche de gauche"\n\nAppuyez sur la flèche du clavier correspondant aux mouvements des barres.\n\nMaintenez la flèche autant de temps que vous verrez les barres se deplacer dans cette direction.\n\n Lorsque les barres changent de direction, changez de touche le plus rapidement possible.'; %'Consigne BASELINE'%'Non ambigue key press';
Exp.Picture.AmbnKp = fullfile('Images', 'NoPRESS.jpg');%'Maintenez le regard sur le point de fixation qui se trouve au centre.';%Consigne BASELINE''Ambigue non Key press';
Exp.Picture.nAmbnKp = fullfile('Images', 'NoPRESS.jpg');%'M
