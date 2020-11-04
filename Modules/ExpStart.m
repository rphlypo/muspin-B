%% Start experiment
DrawFormattedText(win, Exp.Text.startingMsg, 'center', 'center', Exp.Visual.Common.texcol);
vbl = Screen('Flip', win);
KbStrokeWait;

%Image consigne
Im = Exp.Picture.Consigne;
imag=imread(Im);
sctext = Screen('MakeTexture', win, imag);
Screen('DrawTexture', win, sctext);
Screen('Flip',win); % now visible on screen
KbStrokeWait;


%% Initialisation
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Query duration of monitor refresh interval (inter-frame interval):
Exp.PTB.ifi = Screen('GetFlipInterval', win);

waitframes = 1;
waitduration = waitframes * Exp.PTB.ifi;

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
Screen('FillRect',win, Exp.Visual.Common.bckcol, [0 0 Exp.PTB.w Exp.PTB.h]);
vbl = Screen('Flip', win);
Screen('Windows')

% End of cycle temporal threshold. To ensure gratings repeat themselves
% smoothly without a noticable glitch:
thre = 1 / (abs(max(Exp.Visual.Grating(1).speed)) * min([Exp.Visual.Grating(1).freq, Exp.Visual.Grating(2).freq]));

HideCursor;
Screen('Windows')