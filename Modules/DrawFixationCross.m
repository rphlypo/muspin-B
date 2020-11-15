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