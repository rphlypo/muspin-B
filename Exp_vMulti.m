
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
addpath 'Init'
addpath 'Images'

%% Initialise the Exp structure
global Exp;

%% Load the specific init file for the experiment
loadInit('MuspinB_test'); % create specific ini files using name_YYYY-MM-DD if you want full control over the date/versions

%% Setup parameters for the experiment using a file from ./Init
ExpSetup;  

%% Register subject
RegisterSubject;

%%-----------------------------------------------------------------------%%
%                   STARTING Expe                                         %
%-------------------------------------------------------------------------%
ExpStart;

%%  EXPERIMENTAL LOOP

for phase = 1 : Exp.Parameters.NumberOfPhases  % loop through phases
    Exp.Current.Phase = Exp.Parameters.Phases{phase};
    fprintf('Current Phase : %s\n', Exp.Current.Phase);
    Exp.Current.Conditions = Exp.Structure.(Exp.Current.Phase);  % all conditions of current phase in a cell array
    
    NbBlock = Exp.Parameters.(Exp.Current.Phase).NumberOfBlocks;
    Trials.(Exp.Current.Phase).counts = []; 
    
    for block = 1 : NbBlock  % loop through blocks in the current phase
        Exp.Current.Block = block;
        sendTrigger(num2str(Trigger.Block.BaseIndex + mod(Exp.Current.Block-1, 19)+1));  % send a "unique" block id (modulo 19)
        NbTrials = Exp.Parameters.(Exp.Current.Phase).LengthOfBlocks;
        Trials.(Exp.Current.Phase).counts(end + 1) = 0;
        fprintf('\tCurrent Block : %i\n', Exp.Current.Block);
        
        % Draw the background
        DrawBackground;
        
        %% Draw text
        DrawFormattedText(win, Exp.Parameters.(Exp.Current.Phase).initText,'center','center',Exp.Visual.Common.texcol);
        vbl = Screen('Flip', win);
        WaitSecs(1.5);
                
        BLOCK_ON = 1;
        
        % RONALD
        perceptDuration = [];
        NbTrials = length({Exp.Structure.(Exp.Current.Phase){block,:}});

        for trial = 1 : NbTrials
            sendTrigger(Exp.Trigger.Trial.Start);
            Trials.globalcount = Trials.globalcount + 1;
            Trials.(Exp.Current.Phase).counts(end) = Trials.(Exp.Current.Phase).counts(end) + 1;
            Exp.Current.TrialInBlock = trial;

            %% Set trial parameters
            Exp.Current.Condition = Exp.Current.Conditions{block, trial};
            fprintf('\t\tCurrent Block %3i - Trial %3i (Condition %s)\n', block, trial, Exp.Current.Condition);  % feedback to experimenter
            
            UpdateExpCurrent();
            glsl = GratingCreatingUpdating(win, glsl);
            
            % Draw the background
            DrawBackground;

            %% Intialisations:
            TrialInit;
                     
            %% Drift & calibration procedure
            DrifCalib;
            
            %% consigne
            ima=imread(Exp.Current.Picture);  % myimgfile= Exp.Current.Picture;
            sctext = Screen('MakeTexture', win, ima);
            Screen('DrawTexture', win, sctext);
            DrawFormattedText(win, Exp.Current.Text,'center',100,Exp.Visual.Common.texcol); % changed 200 to 100
            
            Screen('Close',sctext)
            Screen('Flip',win); % now visible on screen
    
            sendTrigger(Exp.Trigger.Consigne.Start);
            
            % WaitSecs(.5);  % >> not useful here ?
            % end consigne
            WaitToContinue;  % wait either space key or escape key
            
            %% Fixation dot presentation --> new version 2020-03-14
            Exp.Current.FixPointJit = jitter();  % generate on-the-fly
            HideCursor;
            % Draw the perceived background
            DrawBackground;

            % Draw normal oval:
            DrawFixationCross;

            %% Animation loop
            % Initialisations:
            TRIAL_ON = 1;
            BUTTON_TIMEOUT_STARTED = 0;
            WAITINGPERCEPTREVERSAL = 0;
            MANIPON = 0;
            MOTION = 1; NEEDNEWPERCEPT = 1;
            if strcmp(Exp.Current.Condition, 'StimCalib')
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
                
                % Finally, its time to draw the gratings!
                DrawGratings;
                
                %% Mouse
                % Draw mouse position
                DrawMousePosition;
                
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
                        DrawBackground;
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