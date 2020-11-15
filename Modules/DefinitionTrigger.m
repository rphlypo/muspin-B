function Trigger = DefinitionTrigger();

Trigger = struct;

Trigger.Init = '0';

## Acquisition
Trigger.Acquisition.Start     = '10';
Trigger.Acquisition.End       = '11';
Trigger.Acquisition.Interrupt = '12';

%% Trial
Trigger.Trial.Start         = '20';
Trigger.Trial.Consigne      = '21';
Trigger.Trial.AskForPercept = '22';
Trigger.Trial.End           = '29';

%% Unique Block IDs, mere placeholders to reserve triggers 100--119
Trigger.Block.BaseIndex     = 100;
for k = 1:19
    Trigger.(['Block' num2str(k)]).Start    = num2str(100+k);
end

%% fixation cross and consignes
Trigger.FixationCross.Start     = '30';
Trigger.FixationCross.FrameFlip = '31';
Trigger.FixationCross.End       = '39';
Trigger.Consigne.Start          = '34';

%% stimulus
Trigger.Stimulus.Start.nAmb_nKp = '40';
Trigger.Stimulus.Start.nAmb_Kp  = '41';
Trigger.Stimulus.Start.Amb_nKp  = '42';
Trigger.Stimulus.Start.Amb_Kp   = '43';
Trigger.Stimulus.End            = '49';

%% Keypress
Trigger.KeyPress.Esc    = '89';
% triggers 80--87 are reserved for combinations of left/up/right (MSB)
% these are placeholders not explicitely used in the code
Trigger.KeyPress.Left           = '84'; % 80 + 0x100
Trigger.KeyPress.Coh            = '82'; % 80 + 0x010
Trigger.KeyPress.Right          = '81'; % 80 + 0x001
Trigger.KeyPress.Left_Right     = '85';
Trigger.KeyPress.Left_Coh       = '86';
Trigger.KeyPress.Right_Coh      = '83';
Trigger.KeyPress.Left_Right_Coh = '87';

%% the non-ambiguous plaid status (MSB)
Trigger.Plaid.Left  = '94'; % 90 + 0x100
Trigger.Plaid.Coh   = '92'; % 90 + 0x010
Trigger.Plaid.Right = '91'; % 90 + 0x001

%% Eye-tracking
Trigger.Eyelink.Drift = '120';
Trigger.Eyelink.Calib = '121';