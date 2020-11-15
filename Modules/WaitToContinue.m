WAITING = true;   % need to rewrite this, since it is not appropriate to have only small windows to intercept ESC
                            % try KbQueue
while WAITING
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyCode(escapeKey)
        fprintf('Experiment stopped because of escape\n');
        ShowCursor;
        err = endAcquisition(dataFileName, Exp.Trigger.Acquisition.Interrupt);                   
        sca;
        return
    elseif keyCode(spaceKey)%, keyCode(leftKey)), keyCode(rightKey)), keyCode(upKey))
        WAITING = false;
    end
end