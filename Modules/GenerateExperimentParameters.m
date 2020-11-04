% Generate experiment parameters
function [check] = GenerateExperimentParameters()

global Exp;
check = 0;
Exp.Parameters.Phases = {'LEARN', 'ESTIM', 'TEST'};
Exp.Parameters.NumberOfPhases = length(Exp.Parameters.Phases);

if strcmp(Exp.Type, 'GazeEEG')
    % Conditions
    Exp.Parameters.TEST.Conditions = {'Amb_Kp', 'nAmb_Kp', 'Amb_nKp', 'nAmb_nKp'};
    Exp.Parameters.LEARN.Conditions = {'Amb_Kp', 'nAmb_Kp', 'Amb_nKp', 'nAmb_nKp'};
    Exp.Parameters.ESTIM.Conditions = {'Amb_Kp'};

    Exp.Parameters.TEST.LengthOfBlocks = length(Exp.Parameters.TEST.Conditions);%4
    Exp.Parameters.TEST.NumberOfBlocks = 1; %14;% avec fixation etc, 1 bloc =env 3 min. 20 block = 1h, donc 20-4 (bloc apprentissage) = 16
    Exp.Parameters.LEARN.LengthOfBlocks = length(Exp.Parameters.LEARN.Conditions);%4
    Exp.Parameters.LEARN.NumberOfBlocks = 1;% 4 amb KP de 10 sec /essai + 1 toutes conditions de 10sec/essai
    Exp.Parameters.ESTIM.LengthOfBlocks = 4;
    Exp.Parameters.ESTIM.NumberOfBlocks = 1;% 4 amb KP de 10 sec /essai + 1 toutes conditions de 10sec/essai
    
    for i=1:length(Exp.Parameters.Phases)
        Exp.Parameters.(Exp.Parameters.Phases{i}).MaxPureStates = 11;
        Exp.Parameters.(Exp.Parameters.Phases{i}).MinPureStates = 0;
    end
    
    % Timeout of trials in seconds:
    Exp.Parameters.LEARN.TrialTimeOut = 10;
    Exp.Parameters.TEST.TrialTimeOut = 40;%40
    Exp.Parameters.ESTIM.TrialTimeOut = 40;%40
    
    %% global experiment parameters
    % Reversal needed to end trial:
    Exp.Parameters.ReversalThres = 5;%40
    % Gaussian sampling parameters for alpha selection:
    Exp.Parameters.AlphaSampling = [.5, .05];
    Exp.Parameters.LognRnd = [1, .75];
    Exp.Parameters.AlphaPercepts = ...
        [1, .9, .1; ...
        10, .1, .9; ...
        100, .9, .9];
    Exp.Parameters.FixPoint.WaitTime.Min = .9;
    Exp.Parameters.FixPoint.WaitTime.Max = 1.3;
    Exp.Parameters.FixPoint.Jitter = @() Exp.Parameters.FixPoint.WaitTime.Min + ...
        (Exp.Parameters.FixPoint.WaitTime.Max - Exp.Parameters.FixPoint.WaitTime.Min).*rand;
end