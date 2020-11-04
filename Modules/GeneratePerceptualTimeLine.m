%% Generate percept timeline
% By Kevin Parisot
% v1 (06/01/2020) - Generate a vector of percepts and a vector of durations

function [] = GeneratePerceptualTimeLine()

global Exp;

Durations = lognrnd(Exp.Parameters.LognRnd(1), Exp.Parameters.LognRnd(2));
Percepts = 100;
cnt = 1;
while cumsum(Durations) <= Exp.Parameters.(Exp.Current.Phase).TrialTimeOut
    Durations = [Durations, lognrnd(Exp.Parameters.LognRnd(1), Exp.Parameters.LognRnd(2))];
    switch Percepts(cnt)
        case 1
            if rand > .5
                Percepts = [Percepts, 10];
            else
                Percepts = [Percepts, 100];
            end
        case 10
            if rand > .5
                Percepts = [Percepts, 1];
            else
                Percepts = [Percepts, 100];
            end
        case 100
            if rand > .5
                Percepts = [Percepts, 1];
            else
                Percepts = [Percepts, 10];
            end
    end
    cnt = cnt + 1;
end
Exp.Current.PerceptTimeLine = [Percepts', Durations'];
%% Prepare a frame by frame vector:
Exp.Current.AlphasFrameByFrame = nan(ceil(Exp.Parameters.(Exp.Current.Phase).TrialTimeOut * (1/Exp.PTB.ifi)), 2);%nan(ceil(Exp.Parameters.TrialTimeOut * (1/Exp.PTB.ifi)), 2);
DurationsFrame = ceil(Durations .* (1/Exp.PTB.ifi));
CumSumDurationsFrame = [1 cumsum(DurationsFrame)]; %passe seconde en frame
% CumSumDurationsFrame(end) = ceil(Exp.Parameters.TrialTimeOut * (1/Exp.PTB.ifi));
%dur_=0;
for i = 1 : size(DurationsFrame, 2)
    stidx = CumSumDurationsFrame(i); %dur_+1;
%    dur_ = ceil(Durations(i)* (1/Exp.PTB.ifi));
    enidx = CumSumDurationsFrame(i+1);  %stidx+dur_;
    switch Percepts(i)
        case 1
            Exp.Current.AlphasFrameByFrame(stidx:enidx,:) = bsxfun(@times, ones(enidx-stidx+1,2), Exp.Parameters.AlphaPercepts(1,2:3));
        case 10
            Exp.Current.AlphasFrameByFrame(stidx:enidx,:) = bsxfun(@times, ones(enidx-stidx+1,2), Exp.Parameters.AlphaPercepts(2,2:3));
        case 100
            Exp.Current.AlphasFrameByFrame(stidx:enidx,:) = bsxfun(@times, ones(enidx-stidx+1,2), Exp.Parameters.AlphaPercepts(3,2:3));
    end
end
end


% %Modifications
% 
% Exp.Parameters.TrialTimeOut = 40; % a retirer apres debeug
% x = 4;% temps d'un essai a retirer apres debeug, définit par x de logn_ll après
% 
% %function [Exp] = GeneratePerceptualTimeLine(Exp)
% Durations = x;
% Percept1 = [.9;.9]' ;% on commence par le coherent
% cnt = 1;
% nb_percepts = floor(Exp.Parameters.TrialTimeOut/x);% nb de percepts dans cet essai nAmb
% Exp.Current.AlphasFrameByFrame = ones(nb_percepts-1,2);
% Exp.Current.AlphasFrameByFrame = [Percept1, Exp.Current.AlphasFrameByFrame];% tout les percepts de l'essai
% 

