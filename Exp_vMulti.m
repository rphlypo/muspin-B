
% MULTI   EXPERIMENT script
% by Kevin Parisot
% on 12/06/2018
% v7 : multi-experiment script with header to select which expeirment to
% run
% v8 (09/07/2018): includes pilot 2 for bottom-up
% v9 (11/07/2018): includes motion after-effect
% v10 (23/07/2018): adding RDK
% v11 (11/10/2018): corrected bug in pilot 2 algorithm to estimate equi
% probable alphas
% v12 (09/11/2018): pilot 3 bottomup structure added
% v13 (12/02/2019): pilot 3 change of RDK function and addition of PREPILOT
% for pilot 3
% v14 (22/03/2019): convert all inputs into visual degrees and make pilot 3
% prepilot structure and paradigm
% v15 (04/04/2019): move calibration and drift procedures to after RDK
% generation; removed alpha mixing of RDK dots; remove systematic
% calibration
% v16 (13/06/2019): pilot 3.3 with restricted conditions
% v17 (09/12/2019): adding the 'final' experiment with EEG triggers

clear
close all
sca;


%% for octave only
pkg load statistics;

%% add paths
addpath 'Auxilary'
addpath 'Modules'
addpath 'Functions'
addpath 'Analysis'

%% Flags as option selectors
global Exp;
ExpInit('GazeEEG', false, false); % choose 'GazeEEG', no Gaze, no EEG
ExpSetup; % script to set-up EEG and Gaze
ExpStart;

%-------------------------------------------------------------------------%
%                   STARTING Expe                                         %
%-------------------------------------------------------------------------%

% if Exp.Flags.EEG
%     fprintf('\n --- Experimenter starts EEG recording ...');
%     MsgEEG = 'Veuillez patienter, l''experimentateur commence l''enregistrement EEG';
%     Screen('FillRect', win, Exp.Visual.Common.bckcol);
%     DrawFormattedText(win, MsgEEG ,'center' , 'center', Exp.Visual.Common.texcol);
%     Screen('Flip', win );
%     fprintf(' press any key when ready ---\n');
% end

sendTrigger(Exp.Trigger.Acquisition.Start);
fprintf(['\n ' stars ' Experimental loop will begin ' stars '\n']);

%%  EXPERIMENTAL LOOP
Exp.Current = struct();
Durations = [];
Trials = struct();
Trials.globalcount = 0;

for phase = 1 : Exp.Parameters.NumberOfPhases
    Exp.Current.Phase = Exp.Parameters.Phases{phase};
    fprintf('Current Phase : %s\n', Exp.Current.Phase);
    Exp.Current.Conditions = Exp.Structure.(Exp.Current.Phase);  % all conditions of current phase in a cell array
    
    NbBlock = Exp.Parameters.(Exp.Current.Phase).NumberOfBlocks;
    Trials.(Exp.Current.Phase).counts = []; 
    
    for block = 1 : NbBlock
        Exp.Current.Block = block;
        NbTrials = Exp.Parameters.(Exp.Current.Phase).LengthOfBlocks;
        Trials.(Exp.Current.Phase).counts(end + 1) = 0;
        fprintf('\tCurrent Block : %i\n', Exp.Current.Block);
        
        % Draw the background
        Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
        
        %% Draw text
        if strcmp(Exp.Current.Phase, 'LEARN')
            DrawFormattedText(win, ['Phase d''entrainement \n'],'center','center',Exp.Visual.Common.texcol);
            %DrawFormattedText(win, ['Phase : ' Exp.Current.Phase '\n'],'center','center',Exp.Visual.Common.texcol);
        elseif strcmp(Exp.Current.Phase, 'TEST')
            DrawFormattedText(win, ['Phase d''experience \n'],'center','center',Exp.Visual.Common.texcol);
        elseif strcmp(Exp.Current.Phase, 'ESTIM')
            DrawFormattedText(win, ['Phase d''apprentissage des paramètres \n'],'center','center',Exp.Visual.Common.texcol);
        end
        vbl = Screen('Flip', win);
        sendTrigger(Exp.Trigger.Trial.Start);
        WaitSecs(1.5);
                
        BLOCK_ON = 1;
        
        % RONALD
        perceptDuration = [];
        
        while BLOCK_ON
            Trials.globalcount = Trials.globalcount + 1;
            Trials.(Exp.Current.Phase).counts(end) = Trials.(Exp.Current.Phase).counts(end) + 1;
            Exp.Current.TrialInBlock = Trials.(Exp.Current.Phase).counts(end);

            %% Set trial parameters
            try
                Exp.Current.Condition = Exp.Current.Conditions{block, Exp.Current.TrialInBlock};
            catch
                BLOCK_ON = 0;
            end
            
            fprintf('\t\tCurrent Trial %3i (Condition %s)\n', Exp.Current.TrialInBlock, Exp.Current.Condition);
            
            UpdateExpCurrent();
            GratingCreatingUpdating(win, [1, glsl]);  %%% R. Phlypo: glsl was not originally returned here 2010-03-10
            
            % Draw the background
            Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);

            %% Intialisations:
            Looptimes = nan(ceil(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut/Exp.PTB.ifi),1);
            mx = nan(ceil(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut/Exp.PTB.ifi),1);
            my = nan(ceil(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut/Exp.PTB.ifi),1);
            dotDisp = nan(ceil(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut/Exp.PTB.ifi),2);
            MouseTimes = nan(ceil(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut/Exp.PTB.ifi),1);
            mpos = nan(ceil(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut/Exp.PTB.ifi),2);
            Inertia = nan(ceil(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut/Exp.PTB.ifi),1);
            dev_cnt = zeros(ceil(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut/Exp.PTB.ifi),1);
            buttons = zeros(1,3); kpErr = 0;
            trial_response = nan(1,3);
            cycle = 0;
            Perception = nan(100,4); keyHasBeenPressed = 0; keyIsDown = 0;
            p=0; oldkeyCode=[];
            if Exp.Flags.DUMMY
                p_cnt = uint8(0);
            end
            LoopAlphas = nan(ceil((Exp.Parameters.(Exp.Current.Phase).TrialTimeOut + 2)/Exp.PTB.ifi),2); % 2 sec en plus pour le jitter
            % end Initialisations
                     
            %% Drift & calibration procedure
            if Exp.Flags.EYETRACK
                if Exp.Current.TrialInBlock == 1
                    % Calibration
                    fprintf('Calibration\n');
                    
                    s = sprintf('BEGIN CALIBRATION BY PERIOD\n');
                    Eyelink('Message', s);
                    sendTrigger(Exp.Trigger.Eyelink.Calib);
                    EyelinkDoTrackerSetup(el, 'c');
                    %%%% EyelinkDoDriftCorrection(el);
                    Eyelink('StartRecording');
                    statusError=Eyelink('CheckRecording');
                    
                    if (statusError~=0)
                        Screen('closeall');
                        status=Eyelink('isconnected');
                        if status        % if not connected
                            Eyelink('closefile');
                            WaitSecs(1.0); % give tracker time to execute all commands
                            Eyelink('shutdown');
                        end
                        ShowCursor;
                        return;
                    end
                else
                    fprintf('Drift, appuyez sur espace\n');
                    % Drift
                    Eyelink('StopRecording');
                    
                    % Draw the perceived background
                    Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                    %DrawFormattedText(win, Exp.Text.driftCorrectionMsg,'center','center',Exp.Visual.Common.texcol);
                    vbl = Screen('Flip', win);
                    % WaitSecs(2);
                    
                    s = sprintf('BEGIN DRIFT BY PERIOD\n');
                    Eyelink('Message', s);
                    sendTrigger(Exp.Trigger.Eyelink.Drift);
                    EyelinkDoDriftCorrect(el);
                    fprintf('Drift\n');
                    Eyelink('StartRecording');
                end
            end
            
            %% consigne
            myimgfile= Exp.Current.Picture;
            ima=imread(myimgfile);
            
            sctext = Screen('MakeTexture', win, ima);
            Screen('DrawTexture', win, sctext);
            DrawFormattedText(win, Exp.Current.Text,'center',100,Exp.Visual.Common.texcol); % changed 200 to 100
            
            Screen('Close',sctext)
            Screen('Flip',win); % now visible on screen
    
            sendTrigger(Exp.Trigger.Consigne.Start);
            
            WaitSecs(.5);
            % end consigne

            WAITING = .5;   % need to rewrite this, since it is not appropriate to have only small windows to intercept ESC
                            % try KbQueue
            while WAITING
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyCode(escapeKey)
                    fprintf('Experiment stopped because of escape\n');
                    if Exp.Flags.EYETRACK
                        s = sprintf('INTERRUPTED DURING EXPERIMENTAL PHASE');
                        Eyelink('Message',s);
                    end
                    ShowCursor;
                    
                    err = endAcquisition(dataFileName, Exp.Trigger.Acquisition.Interrupt);
                    
                    sca;
                    return
                elseif keyCode(spaceKey)%, keyCode(leftKey)), keyCode(rightKey)), keyCode(upKey))
                    WAITING = 0;
                end
            end
            
            %% Fixation dot presentation --> new version 2020-03-14
            Exp.Current.FixPointJit = Exp.Parameters.FixPoint.Jitter();  % generate on-the-fly
            HideCursor;
            % Draw the perceived background
            Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
            % Draw normal oval:
            Screen('FillOval', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol 255], Exp.Stimulus.ovRect);
            Screen('DrawDots', win, [Exp.PTB.w/2 Exp.PTB.h/2], Exp.Visual.Common.dotSize, Exp.Visual.Common.dotcol, [], 2);
            starttime = GetSecs;
            vbl = Screen('Flip', win);
            if Exp.Flags.EYETRACK
                s = sprintf('FLIP FIX START\n');
                Eyelink('Message',s);
            end
            sendTrigger(Exp.Trigger.FixationCross.Start);
            WaitSecs(Exp.Current.FixPointJit - (GetSecs - starttime));  % hold fixation point on screen for jitter time
            if Exp.Flags.EYETRACK
                s = sprintf('FLIP FIX END\n');
                Eyelink('Message',s);
            end
            sendTrigger(Exp.Trigger.FixationCross.End);

            %% Animation loop
            % Initialisations:
            TRIAL_ON = 1;
            BUTTON_TIMEOUT_STARTED = 0;
            WAITINGPERCEPTREVERSAL = 0;
            MANIPON = 0;
            MOTION = 1; NEEDNEWPERCEPT = 1;
            if strcmp(Exp.Type, 'GazeEEG') && strcmp(Exp.Current.Condition, 'StimCalib')
                count_down = ceil(Exp.Parameters.StimCalibTrialTimeOut * (1/Exp.PTB.ifi));
            else
                count_down = ceil(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut * (1/Exp.PTB.ifi));
            end
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimStart = GetSecs;
            sendTrigger(Exp.Trigger.Stimulus.Start.(Exp.Current.Condition));
            
            % Here we set the initial position of the mouse to be in the centre of the
            % screen
            SetMouse(Exp.PTB.w/2, Exp.PTB.h/2, win);
            %             ShowCursor;
            
            %% Stimulus presentation loop
            % RONALD
            PureStates = []; % local variable for trial
            PerceptualState = [];
            cnt = 1;
            old_state = Inf;
            cnt_pure = 0;
            %             cnt2 = 1;
            trial_start_time = GetSecs;
            currentTrialTimeOut = Inf;
            currentPlaidState = '';
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimStart = GetSecs;
            
            while TRIAL_ON
                loopst = GetSecs;
                
                % Set angles of gratings for this loop:
                Loop_Angle = [Exp.Current.BaseLineOrientation + Exp.Visual.Grating(1).rotAngles, ...
                    Exp.Current.BaseLineOrientation + Exp.Visual.Grating(2).rotAngles];
                
                % Set transparency values for this loop:
                
                switch Exp.Current.Condition(1)
                    case 'A'
                        Loop_Alpha = Exp.Current.Alphas;
                    case 'n'
                        Loop_Alpha = Exp.Current.AlphasFrameByFrame(cnt,:);
                        PlaidState = Exp.Current.StateFrameByFrame{cnt};
                        if ~strcmpi(PlaidState, currentPlaidState)
                            currentPlaidState = PlaidState;
                            sendTrigger(eval(['Exp.Trigger.Plaid.', currentPlaidState]));
                        end
                end
                LoopAlphas(cnt,:) = Loop_Alpha;
                %                 cnt2 = cnt2 + 1;
                % Adjust luminance and contrast depending on alphas picked:
                [Loop_Luminance, Loop_Contrast] = fLuminanceContrast(Loop_Alpha, ...
                    Exp.Visual.Common.bckcol2, Exp.Visual.Grating(1).mean, Exp.Visual.Grating(1).dutycycle);
                [Loop_BetaLum, Loop_OffsetLum] = fEgalisateur(Loop_Luminance, Loop_Contrast, ...
                    Exp.Visual.Common.LuminanceRef, Exp.Visual.Common.ContrastRef);
                Loop_GratingLum(1) = Loop_BetaLum * Exp.Visual.Grating(1).mean + Loop_OffsetLum;
                Loop_GratingLum(2) = Loop_BetaLum * Exp.Visual.Grating(2).mean + Loop_OffsetLum;
                Loop_BackGround = Loop_BetaLum * Exp.Visual.Common.bckcol2 + Loop_OffsetLum;
                
                % Compute displacement of gratings based on current time:
                TimeForMotion = mod(GetSecs - Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimStart, ...
                    (Exp.Visual.Common.apSize) / Exp.PTB.SpeedInPix(1));
                %                     (Exp.Visual.Common.apSizeDeg) / Exp.Visual.Grating(1).speed)
                
                if MOTION
                    gratingDisp = [TimeForMotion .* Exp.PTB.SpeedInPix(1), ...
                        TimeForMotion .* Exp.PTB.SpeedInPix(1) + Exp.Current.PhaseShift];
                    %                     [round(TimeForMotion .* Exp.PTB.SpeedInPix(1)), ...
                    %                         round(TimeForMotion .* Exp.PTB.SpeedInPix(1)) + Exp.Current.PhaseShift]
                else
                    gratingDisp = [round(TimeToStop .* Exp.PTB.SpeedInPix(1)), ...
                        round(TimeToStop .*Exp.PTB.SpeedInPix(1)) + Exp.Current.PhaseShift];
                end
                dotDisp(cnt,:) = fGenLissajouT(GetSecs, Exp.Visual.Lissajou.amp, ...
                    Exp.Visual.Lissajou.fv, Exp.Visual.Lissajou.fh, Exp.Visual.Lissajou.phase);
                
                % Grating 1:
                g1_cst(1) = Exp.PTB.w/2-(Exp.Visual.Grating(1).dutycycle*1/Exp.Visual.Grating(1).freq/2) - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * cosd(Loop_Angle(1));
                g1_cst(2) = Exp.PTB.w/2+(Exp.Visual.Grating(1).dutycycle*1/Exp.Visual.Grating(1).freq/2) - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * cosd(Loop_Angle(1));
                g1_cst(3) = 0 - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * sind(Loop_Angle(1));
                g1_cst(4) = Exp.PTB.h - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * sind(Loop_Angle(1));
                dstRects_g1(1,:) = [g1_cst(1) + (-5).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-5).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-5).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-5).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(2,:) = [g1_cst(1) + (-4).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-4).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-4).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-4).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(3,:) = [g1_cst(1) + (-3).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-3).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-3).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-3).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(4,:) = [g1_cst(1) + (-2).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-2).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-2).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-2).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(5,:) = [g1_cst(1) + (-1).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-1).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-1).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-1).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(6,:) = [g1_cst(1) + 0.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 0.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 0.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 0.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(7,:) = [g1_cst(1) + 1.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 1.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 1.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 1.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(8,:) = [g1_cst(1) + 2.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 2.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 2.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 2.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(9,:) = [g1_cst(1) + 3.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 3.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 3.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 3.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(10,:) = [g1_cst(1) + 4.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 4.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 4.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 4.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                
                % Grating 2:
                g2_cst(1) = Exp.PTB.w/2-(Exp.Visual.Grating(2).dutycycle*1/Exp.Visual.Grating(2).freq/2) - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * cosd(Loop_Angle(2));
                g2_cst(2) = Exp.PTB.w/2+(Exp.Visual.Grating(2).dutycycle*1/Exp.Visual.Grating(2).freq/2) - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * cosd(Loop_Angle(2));
                g2_cst(3) = 0 - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * sind(Loop_Angle(2));
                g2_cst(4) = Exp.PTB.h - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * sind(Loop_Angle(2));
                
                dstRects_g2(1,:) = [g2_cst(1) + (-5).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-5).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-5).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-5).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(2,:) = [g2_cst(1) + (-4).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-4).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-4).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-4).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(3,:) = [g2_cst(1) + (-3).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-3).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-3).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-3).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(4,:) = [g2_cst(1) + (-2).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-2).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-2).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-2).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(5,:) = [g2_cst(1) + (-1).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-1).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-1).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-1).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(6,:) = [g2_cst(1) + 0.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 0.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 0.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 0.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(7,:) = [g2_cst(1) + 1.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 1.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 1.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 1.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(8,:) = [g2_cst(1) + 2.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 2.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 2.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 2.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(9,:) = [g2_cst(1) + 3.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 3.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 3.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 3.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(10,:) = [g2_cst(1) + 4.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 4.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 4.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 4.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                
                
                % Draw the perceived background
                Screen('Blendfunction', win, GL_ONE, GL_ZERO);
                if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition,'Dynamic')
                    Screen('FillRect', win, Loop_BackGround .* ones(1,3), Exp.PTB.winRect);
                else
                    Screen('FillRect', win, Exp.Current.BackGround .* ones(1,3), Exp.PTB.winRect);
                end
                Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 1 1 1]);
                
                % Draw first grating
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(1,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(2,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(3,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(4,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(5,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(6,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(7,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(8,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(9,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(10,:), Loop_Angle(1), [], Loop_Alpha(1));
                
                % Draw second grating
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(1,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(2,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(3,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(4,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(5,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(6,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(7,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(8,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(9,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(10,:), Loop_Angle(2), [], Loop_Alpha(2));
                
                % Draw aperture
                Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawTexture', win, Exp.Stimulus.aperturetex, [], Exp.PTB.winRect);
                
                % Draw normal oval:
                Screen('FillOval', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol 255], Exp.Stimulus.ovRect);
                if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3 && not(strcmp(Exp.Current.Condition, 'NoRDK'))
                    Screen('Blendfunction', win, GL_ONE, GL_ZERO);
                    Screen('DrawDots', win, [Exp.Current.Particles.pixpos.x(cnt,Exp.Current.Particles.goodDots(cnt,:)); Exp.Current.Particles.pixpos.y(cnt,Exp.Current.Particles.goodDots(cnt,:))], ...
                        Exp.Visual.Common.dotSize, ...
                        [Exp.Visual.Common.dotcol(1), Exp.Visual.Common.dotcol(2), Exp.Visual.Common.dotcol(3)],...
                        [], 2);
                    Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                elseif strcmp(Exp.Current.Condition, 'NoRDK')
                    Screen('DrawDots', win, [Exp.PTB.w/2 + dotDisp(cnt,1), Exp.PTB.h/2 + dotDisp(cnt,2)], Exp.Visual.Common.dotSize, Exp.Visual.Common.dotcol, [], 2);
                else
                    Screen('DrawDots', win, [Exp.PTB.w/2 + dotDisp(cnt,1), Exp.PTB.h/2 + dotDisp(cnt,2)], Exp.Visual.Common.dotSize, Exp.Visual.Common.dotcol, [], 2);
                end
                
                % Draw response oval
                Screen('FrameOval', win, Exp.Visual.Common.MouseRespOvalCol, Exp.Stimulus.dst2Rect, 40);
                
                %% Mouse
                % Draw mouse position
                if Exp.Flags.MOUSE
                    if Exp.Flags.DUMMY % Dummy means the computer is doing the mouse task
                        dummy_bad = 0;
                        if dummy_bad
                            if cnt > 1
                                mx(cnt) = (mx(cnt-1) + 1.*randn(1,1));
                                my(cnt) = (my(cnt-1) + 1.*randn(1,1));
                            else
                                mx(cnt) = randn(1,1) + Exp.PTB.w/2;
                                my(cnt) = randn(1,1) + Exp.PTB.h/2;
                            end
                        else
                            if Exp.Current.TrialInBlock == 1
                                lag = 10;
                            else
                                lag = 5;
                            end
                            if cnt > lag
                                mx(cnt) = dotDisp(cnt-lag,1) + Exp.PTB.w/2;
                                my(cnt) = dotDisp(cnt-lag,2) + Exp.PTB.h/2;
                            else
                                mx(cnt) = 0;
                                my(cnt) = 0;
                            end
                        end
                        buttons = zeros(1,3);
                        
                    else % Participant is doing the mouse task
                        [mx(cnt), my(cnt), buttons] = GetMouse(win);
                    end
                    MouseTimes(cnt) = GetSecs;
                    mpos(cnt,:) = [mx(cnt), my(cnt)];
                    
                    %% Compute distance
                    if strcmp(Exp.Type, 'TopDown')
                        Inertia(cnt) = norm([mpos(cnt,1)-Exp.PTB.w/2, mpos(cnt,2)-Exp.PTB.h/2] - dotDisp(cnt,:)) ;
                        t_ = GetSecs; % temps actuel
                        t(cnt) = t_; %vecteur temps
                        %                     inertia_ = nanmean(Inertia(t>=t_ - 0));
                        inertia_ = nanmedian(Inertia(t>=t_ - Exp.Parameters.InertiaTimeWindowSize)); % Inertia Temporal Window Size: median is computed over this sliding time lapse
                        
                        if strcmp(Exp.Current.Condition, 'BL') && strcmp(Exp.Current.Phase, 'LEARN') % in BL Learn, the mouse is not used
                            Screen('DrawDots', win, [Exp.PTB.w/2, Exp.PTB.h/2], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                            
                        else
                            if (t_ - t(1) > Exp.Parameters.InertiaTimeWindowSize) % Give a delay for inertia computation at the begining of trial
                                switch Exp.Current.Phase
                                    case 'TEST'
                                        if inertia_ > InertiaReferenceFinal
                                            %                                         Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, [.9 .4 .4], [], 2);
                                            Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                                            dev_cnt(cnt) = 1;
                                        else
                                            Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                                        end
                                    case 'LEARN'
                                        if Exp.Current.TrialInBlock > 1 && strcmp(Exp.Current.Condition, 'LJ')
                                            if inertia_ > InertiaReference
                                                Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, [.9 .4 .4], [], 2);
                                            else
                                                Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, [.4 .9 .4], [], 2);
                                            end
                                        else
                                            Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                                        end
                                end
                                
                            else
                                Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                            end
                        end
                    else
                        Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                    end
                    
                    if Exp.Flags.MOUSECLICKON
                        % Check if buttom is pressed!
                        if sum(buttons) ~= 0
                            BUTTON_TIMEOUT_STARTED = 1;
                            [trial_response(1), trial_response(2)] = GetMouse(win);
                            trial_response(3) = GetSecs;
                            TRIAL_ON = 0;
                        end
                    end
                    
                end
                
                %% Finish drawing
                Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawingFinished', win);
                
                %% Keyboard
                if Exp.Flags.KEYPRESSPERCEPT
                    [keyIsDown, secs, keyCode] = KbCheck;
                    if keyCode(escapeKey)
                        fprintf('Experiment stopped because of escape\n');
                        if Exp.Flags.EYETRACK
                            s = sprintf('INTERRUPTED DURING EXPERIMENTAL PHASE');
                            Eyelink('Message',s);
                        end
                        sendTrigger(Exp.Trigger.Acquisition.Interrupt);
                        ShowCursor;
                        sca;
                        return
                    end
                    if keyIsDown && keyCode(spaceKey) && not(MOTION) && strcmp(Exp.Type, 'AfterEffect')
                        fprintf('Trial finished\n')
                        TRIAL_ON = 0;
                        Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).SpaceTime = GetSecs;
                    end
                    
                    % Check the keyboard for escape:
                    if Exp.Flags.DUMMY && not(strcmp(Exp.Current.Condition, 'LJ'))
                        if mod(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut, ...
                                round(GetSecs-Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimStart))
                            if p_cnt > 0
                                p_cnt = p_cnt - 1;
                                switch p_dum
                                    case 1
                                        keyIsDown = 1; secs = GetSecs; keyCode(leftKey) = 1;
                                    case 2
                                        keyIsDown = 1; secs = GetSecs; keyCode(rightKey) = 1;
                                    case 3
                                        keyIsDown = 1; secs = GetSecs; keyCode(upKey) = 1;
                                end
                                
                            else
                                p_cnt = 40;
                                p_dum = randi(3,1);
                                keyCode = zeros(1,256); keyIsDown = 0;
                            end
                        end
                    end
                    
                    %%% test --> validated by Ronald 2020/02/19 %%%
                    KeysOfInterest = keyCode([leftKey, upKey, rightKey]);
                    current_state = KeysOfInterest * [100; 10; 1];  % binary code left=100, up=010, right=001
                    if current_state ~= old_state
                        trigger_ = bin2dec(num2str(current_state)) + 80;  % decimal trigger left=81, up=82, right=84
                        sendTrigger(num2str(trigger_));
                        old_state = current_state;
                        
                        PerceptualState = [PerceptualState; current_state GetSecs];
                        
                        % feedback keypress to experimentalist
                        if strcmpi(Exp.Type, 'GazeEEG') && size(PerceptualState, 1) > 1
                            fprintf('%10.2fs : keys %03i.\n', diff(PerceptualState(end-1:end, 2)), PerceptualState(end-1, 1));
                            if diff(PerceptualState(end-1:end, 2)) > 1.5
                                fprintf('\tWarning ! Subject stayed longer than 1.5 seconds in a state!\n');
                            end
                        end
                        
                        if isPureState(trigger_)
                            PureStates = [PureStates; current_state GetSecs];
                            cnt_pure = size(PureStates, 1) - 1;
                            if cnt_pure == Exp.Parameters.(Exp.Current.Phase).MaxPureStates
                                currentTrialTimeOut = (GetSecs - trial_start_time) + rand + 0.5; % jitter
                            end
                        end
                        
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    if not(isequal(oldkeyCode, keyCode)) %, keyHasBeenPressed == false)
                        current_time = GetSecs;
                        if p
                            Perception(p,4) = current_time;
                        end
                        p = p + 1;
                        Perception(p,2:3) = current_time;
                        if keyCode(escapeKey)
                            fprintf('Experiment stopped because of escape\n');
                            if Exp.Flags.EYETRACK
                                s = sprintf('INTERRUPTED DURING EXPERIMENTAL PHASE');
                                Eyelink('Message',s);
                            end
                            ShowCursor;
                            
                            err = endAcquisition(dataFileName, Exp.Trigger.Acquisition.Interrupt);
                            
                            sca;
                            return
                        end
                        WAITINGPERCEPTREVERSAL = 0;
                        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition,'Dynamic')
                            Exp.Current.NextExoPerceptReversal(end) = [];
                        end
                        
                        if strcmp(Exp.Type, 'AfterEffect')
                            Perception(p, 1) = keyCode([leftKey, rightKey, upKey, downKey]) * [1; 10; 100; 1000];
                        else
                            % RONALD
                            % keyCode([ ]) yields a logical array
                            % example if rightKey is pressed but no other key
                            % keyCode([leftKey, rightKey, upKey]) = [0 1 0]
                            % inner product with [1; 10; 100] gives desired result
                            Perception(p, 1) = keyCode([leftKey, rightKey, upKey]) * [1; 10; 100];
                        end
                        
                    end
                    oldkeyCode = keyCode;
                    
                else
                    if keyIsDown && keyCode(escapeKey)
                        fprintf('Experiment stopped because of escape\n');
                        if Exp.Flags.EYETRACK
                            s = sprintf('INTERRUPTED DURING EXPERIMENTAL PHASE');
                            Eyelink('Message',s);
                        end
                        sendTrigger(Exp.Trigger.KeyPress.Esc);
                        ShowCursor;
                        
                        err = endAcquisition(dataFileName, Exp.Trigger.Acquisition.Interrupt);
                                             
                        sca;
                        return
                    end
                end
                
                %% Time out
                if strcmp(Exp.Type, 'GazeEEG') && strcmp(Exp.Current.Condition, 'StimCalib')
                    % Check if keypress is pressed for short trials
                    if p >= 2
                        BUTTON_TIMEOUT_STARTED = 1;
                        TRIAL_ON = 0;
                        if Exp.Flags.EYETRACK
                            s = sprintf('FLIP STIM END\n');
                            Eyelink('Message',s);
                        end
                        sendTrigger(Exp.Trigger.Stimulus.End);
                    end
                end
                if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition, 'Short')
                    % Check if keypress is pressed for short trials
                    if p >= 2
                        BUTTON_TIMEOUT_STARTED = 1;
                        TRIAL_ON = 0;
                    end
                end
                if strcmp(Exp.Type, 'AfterEffect') && strcmp(Exp.Current.Phase, 'LEARN') && not(Exp.Pilot==2)
                    % Check if keypress is pressed for short trials
                    if p > Exp.Parameters.ReversalThres+1
                        BUTTON_TIMEOUT_STARTED = 1;
                        TRIAL_ON = 0;
                    end
                end
                
                % Count down one frame for trial time out
                count_down = count_down - 1;
                
                % Check if time is out
                if strcmp(Exp.Type, 'AfterEffect') && or(strcmp(Exp.Current.Phase, 'TEST'),Exp.Pilot==2)
                    if count_down < 0 && WAITINGTOFREEZE
                        count_down = ceil(Exp.Parameters.ExtraTimeOut * (1/Exp.PTB.ifi));
                        % freeze all motor functions
                        MOTION = 0; WAITINGTOFREEZE = 0;
                        TimeToStop = mod(GetSecs - Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimStart, ...
                            (Exp.Visual.Common.apSize) / Exp.PTB.SpeedInPix(1)); %GetSecs;
                    end
                end
                
                if strcmp(Exp.Type, 'GazeEEG') %juliette
                    condition1a = (Exp.Parameters.(Exp.Current.Phase).MinPureStates <= cnt_pure && strcmpi(Exp.Current.Condition(end-2:end), '-kp'));
                    condition1b = strcmpi(Exp.Current.Condition(end-2:end), 'nkp');
                    if strcmp(Exp.Current.Phase, 'LEARN')
                        condition2 = (GetSecs - trial_start_time >= Exp.Parameters.(Exp.Current.Phase).TrialTimeOut);
                    else
                        condition2 = (GetSecs - trial_start_time >= min(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut, currentTrialTimeOut));
                    end

                    if  (condition1a || condition1b) && condition2 
                        if keyHasBeenPressed
                            Perception(p,4) = GetSecs;
                        end
                        fprintf('Trial finished\n')
                        TRIAL_ON = 0;
                        if BUTTON_TIMEOUT_STARTED == 0
                            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).TimeOut = 1;
                        else
                            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).TimeOut = 0;
                        end
                        
                        if Exp.Flags.EYETRACK
                            s = sprintf('FLIP STIM END\n');
                            Eyelink('Message',s);
                        end
                        sendTrigger(Exp.Trigger.Stimulus.End);
                    
                        if strcmp(Exp.Current.Phase, 'TEST'),
                            theta = 0.25;
                        elseif strcmp(Exp.Current.Phase, 'ESTIM')
                            theta = 0;
                        elseif strcmp(Exp.Current.Phase, 'LEARN')
                            theta = inf;
                        end

                        if rand < theta  % from time to time ask for a confirmation of the last percept       
                            confirmPercept;
                        end
                    end  
                end%juliette
                
                %% DONE: Let's flip
                % Flip 'waitframes' monitor refresh intervals after last redraw.
                vbl = Screen('Flip', win, vbl + (waitframes - 0.5) * Exp.PTB.ifi);
                if Exp.Flags.EYETRACK
                    s = sprintf('FLIP FRAME %s\n',num2str(cnt));
                    Eyelink('Message',s);
                end
                % no triggers for EEG, since wait times of 5msec introduced
                % by sendTrigger
                %                 if Exp.Flags.EEG % Flip frame trigger
                % %                    putvalue(DIO,32); % Data Acquisition Toolbox
                %                     sendTrigger(Trigger_FrameFlipStim);
                %                 end
                
                % Next loop iteration...
                Looptimes(cnt) = GetSecs - loopst;
                cnt = cnt + 1;
                
            end
            
            % add the end of the trial to the array, this is however not a percept (put NaN)
            PerceptualState = [PerceptualState; NaN GetSecs];
            
            if strcmp(Exp.Type, 'TopDown')
                % RONALD
                % gathering information about the duration of second percept
                % until one-to-last percept and the number of percepts
                % - the first row is a dummy row with the starting time of the trial
                % - the second row is the first percept
                % - the last row is an ongoing percept
                % not counting the first and last percept implies taking 3rd to one-to-last row
                % - number of percepts: length(PureStates) - 3
                % - time: PureStates(end, 2) -PureStates(3, 2)
                perceptDuration(Exp.Current.TrialInBlock, :) = [PureStates(end, 2) - PureStates(3, 2), length(PureStates) - 3];
                
                Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                DrawFormattedText(win, sprintf('Your mean reversal speed for this trial is %.2f', perceptDuration(Exp.Current.TrialInBlock, 2) / perceptDuration(Exp.Current.TrialInBlock, 1)), ...
                    'center','center',Exp.Visual.Common.texcol);
                vbl = Screen('Flip', win);
                WaitSecs(1);
            end
            if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && not(strcmp(Exp.Current.Condition, 'Short'))
                Durations_temp = Perception;
                Durations_temp(end,end) = GetSecs;
                Durations = [Durations; Durations_temp(:,4) - Durations_temp(:,3)];
                paramhat = lognfit(Durations(not(isnan(Durations))));
            end
            
            %% Save data
            Perception(p+1:end,:) = [];
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimFinish = GetSecs;
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Response = trial_response;
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).MouseData = [mx(not(isnan(mx))), my(not(isnan(my))), MouseTimes(not(isnan(MouseTimes)))];
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).LoopTimes = Looptimes(not(isnan(Looptimes)));
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Perception = Perception;
            
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).LoopAlphas = [LoopAlphas(not(isnan(LoopAlphas(:,1))),1), LoopAlphas(not(isnan(LoopAlphas(:,2))),2)];
            
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).PureStates = PureStates;
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).PerceptualState = PerceptualState;
            
            if ~strcmp(Exp.Current.Phase, 'LEARN') && strcmp(Exp.Current.Condition, 'Amb-Kp')
                if size(PureStates, 1) > 2,
                    percept_timing_ = diff(PureStates(:, 2), 1);
                    learn_params_from_data{end+1} = percept_timing_(2:end)';
                end
            end
            
            if length(learn_params_from_data) >= 4  % lear new parameters from data
                x = cell2mat(learn_params_from_data(end-3:end));
                [mu, sigma] = logn_ll(x);
                Exp.Parameters.LognRnd = [mu, sigma];
            end
            
            %% LJ Learning process
            if strcmp(Exp.Type, 'TopDown')
                if  strcmp(Exp.Current.Condition, 'LJ') && strcmp(Exp.Current.Phase, 'LEARN')
                    Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Inertia = Inertia(not(isnan(Inertia)));
                    
                    if Exp.Current.TrialInBlock == 1
                        trial_success = 0;
                        temp = sort(Inertia(not(isnan(Inertia))));
                        InertiaReference = temp(round(Exp.Parameters.LearnLJthres * length(Inertia)));
                        Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).InertiaReference = InertiaReference;
                        
                    else
                        criterion = nanmedian(Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Inertia(round(.5/Exp.PTB.ifi) : end)); % approximately ignore first 500ms
                        if criterion > InertiaReference
                            Exp.Current.FeedbackText = 'Echec\n\n';
                            trial_success = 0;
                        else
                            Exp.Current.FeedbackText = 'Succes\n\n';
                            trial_success = trial_success + 1;
                        end
                        
                        % Draw the background
                        Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                        DrawFormattedText(win, Exp.Current.FeedbackText,'center','center',Exp.Visual.Common.texcol);
                        vbl = Screen('Flip', win);
                        if Exp.Flags.EYETRACK
                            s = sprintf('FLIP TRIAL JUDGEMENT MSG\n');
                            Eyelink('Message',s);
                        end
                        WaitSecs(1);
                    end
                    
                    if (trial_success < Exp.Parameters.LearnLJsuccess) && (Exp.Current.TrialInBlock == NbTrials)
                        NbTrials = NbTrials + 1;
                    end
                    
                end
                if strcmp(Exp.Current.Phase, 'TEST') && sum(dev_cnt)/length(dev_cnt) > Exp.Parameters.TestLJthres
                    Exp.Current.FeedbackText = 'Attention\n Deviation de la performance du suivi du point sur cette derniere sequence!\n\n';
                    Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                    DrawFormattedText(win, Exp.Current.FeedbackText,'center','center',Exp.Visual.Common.texcol);
                    vbl = Screen('Flip', win);
                    if Exp.Flags.EYETRACK
                        s = sprintf('FLIP TRIAL JUDGEMENT MSG\n');
                        Eyelink('Message',s);
                    end
                    WaitSecs(1);
                end
            end
            
            %% Finish block?
            if Exp.Current.TrialInBlock == NbTrials
                if strcmp(Exp.Type, 'TopDown')
                    if  strcmp(Exp.Current.Condition, 'LJ') && strcmp(Exp.Current.Phase, 'LEARN') % Let's take the final training inertia as a new reference
                        temp = sort(Inertia(not(isnan(Inertia))));
                        InertiaReferenceFinal = temp(round((1 - Exp.Parameters.LearnLJthres) * length(Inertia)));
                        Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).InertiaReference = InertiaReferenceFinal;
                    end
                end
                
                BLOCK_ON = 0;
            end
            
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).TrialInfo = Exp.Current;
        end
        
        if strcmp(Exp.Type, 'TopDown')
            % RONALD
            % report mean percept reversal speed for the block
            WaitSecs(.5)
            meanRevSpeed = sum(perceptDuration(:, 2)) / sum(perceptDuration(:, 1));
            Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
            DrawFormattedText(win, sprintf('Your mean reversal speed for this block is %.2f', meanRevSpeed), ...
                'center','center',Exp.Visual.Common.texcol);
            vbl = Screen('Flip', win);
            WaitSecs(1)
        end
        
        if Exp.Flags.SAVEONTHEGO && Exp.Flags.SAVE
            save(fullfile(Exp.paths.dataDir, Exp.paths.fileName), 'Exp');
        end
        
    end
end

%% Experiment is finishing: let's save and close things
% Last flip to take end timestamp and for stimulus offset:
vbl = Screen('Flip', win);
if Exp.Flags.EYETRACK
    s = sprintf('FLIP FRAME LAST TIMESTAMP\n');
    Eyelink('Message',s);
end
if Exp.Flags.EEG % last timestamp trigger
    
end
DrawFormattedText(win, 'Fin\n', 'center', 'center', 0.75)
vbl = Screen('Flip',win);
if Exp.Flags.EYETRACK
    s = sprintf('FLIP FRAME END\n');
    Eyelink('Message',s);
end
sendTrigger(Exp.Trigger.Trial.End);
WaitSecs(1);


err = endAcquisition(dataFileName, Exp.Trigger.Acquisition.End);

% Close onscreen window, release all ressources:
sca;
ShowCursor;