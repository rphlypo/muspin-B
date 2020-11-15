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