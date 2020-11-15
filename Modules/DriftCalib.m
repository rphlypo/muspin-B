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
        DrawBackground;
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