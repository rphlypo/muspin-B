Screen('FillRect',win, Exp.Visual.Common.bckcol)
Screen('Flip', win);
KbReleaseWait();
waitSecs(.5);
sendTrigger(Trigger.Trial.AskForPercept);
Screen('FillRect',win, Exp.Visual.Common.bckcol)
DrawFormattedText(win, ['Utilisez les flèches du clavier pour rapporter votre dernier percept \n'],'center','center',Exp.Visual.Common.texcol);
Screen('Flip', win);
current_state = 0;
while ~any(current_state)
    [keyIsDown, secs, keyCode] = KbCheck;
    KeysOfInterest = keyCode([leftKey, upKey, rightKey]);
    current_state = KeysOfInterest * [100; 10; 1];
end
trigger_ = bin2dec(num2str(current_state)) + 80;
sendTrigger(num2str(trigger_));