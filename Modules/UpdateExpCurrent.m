% Update Current Trial structure

function [] = UpdateExpCurrent()

global Exp;

if strcmp(Exp.Type, 'GazeEEG')
    switch Exp.Current.Condition
        %case 'StimCalib'
        %    Exp.Current.Alphas(1) = rand;
        case 'nAmb_Kp'
            Exp.Current.Alphas(1) = .5;
            GeneratePerceptualTimeLine();
            Exp.Current.Alphas(2) = 1 - Exp.Current.Alphas(1);
        case 'nAmb_nKp'
            Exp.Current.Alphas(1) = .5;
            GeneratePerceptualTimeLine();
            Exp.Current.Alphas(2) = 1 - Exp.Current.Alphas(1);
        case 'Amb_Kp'
            Exp.Current.Alphas(1) = .5;
            Exp.Current.Alphas(2) = 1 - Exp.Current.Alphas(1);
            
            %                    selector = rand;
            %                    if selector > .5
            %                        Exp.Current.Alphas(1) = Exp.Subject.AlphaEq(2);
            %                    else
            %                        Exp.Current.Alphas(1) = Exp.Subject.AlphaEq(1);
            %                    end
        case 'Amb_nKp'
            Exp.Current.Alphas(1) = .5;
            Exp.Current.Alphas(2) = 1 - Exp.Current.Alphas(1);
            %                    selector = rand;
            %                    if selector > .5
            %                        Exp.Current.Alphas(1) = Exp.Subject.AlphaEq(2);
            %                    else
            %                        Exp.Current.Alphas(1) = Exp.Subject.AlphaEq(1);
            %                    end
    end
    
end

% Adjust luminance and contrast depending on alphas picked:
[Exp.Current.Luminance, Exp.Current.Contrast] = fLuminanceContrast(Exp.Current.Alphas, ...
    Exp.Visual.Common.bckcol2, Exp.Visual.Grating(1).mean, Exp.Visual.Grating(1).dutycycle);
[Exp.Current.BetaLum, Exp.Current.OffsetLum] = fEgalisateur(Exp.Current.Luminance, Exp.Current.Contrast, ...
    Exp.Visual.Common.LuminanceRef, Exp.Visual.Common.ContrastRef);
Exp.Current.GratingLum(1) = Exp.Current.BetaLum * Exp.Visual.Grating(1).mean + Exp.Current.OffsetLum;
Exp.Current.GratingLum(2) = Exp.Current.BetaLum * Exp.Visual.Grating(2).mean + Exp.Current.OffsetLum;
Exp.Current.BackGround = Exp.Current.BetaLum * Exp.Visual.Common.bckcol2 + Exp.Current.OffsetLum;

% What parameters are we manipulating given the condition we are in?
Exp.Current.BaseLineOrientation = 0;

% What phase shift? in pixels
a = 0; b = 50;
Exp.Current.PhaseShift = a + (b-a).*rand(1,1);

% What text to be displayed?
if strcmp(Exp.Type, 'GazeEEG')
    %Exp.Current.Text = ['A'];
    switch Exp.Current.Phase
        case 'LEARN'
            switch Exp.Current.Condition
                case 'Amb_Kp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.AmbKp;
                    Exp.Current.Picture = Exp.Picture.AmbKp;
                case 'nAmb_Kp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.nAmbKp;
                    Exp.Current.Picture = Exp.Picture.nAmbKp;
                case 'Amb_nKp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.AmbnKp;
                    Exp.Current.Picture = Exp.Picture.AmbnKp;
                case 'nAmb_nKp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.nAmbnKp;
                    Exp.Current.Picture = Exp.Picture.nAmbnKp;
            end
            Exp.Current.Text = ['Phase d''Entrainement - ' Exp.Current.Condition '\n\n'...
                'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                'Essai : ' num2str(Exp.Current.TrialInBlock) '\n\n'...
                Exp.Current.taskMsg];
            
        case 'TEST'
            switch Exp.Current.Condition
                case 'Amb_Kp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.AmbKp;
                    Exp.Current.Picture = Exp.Picture.AmbKp;
                case 'nAmb_Kp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.nAmbKp;
                    Exp.Current.Picture = Exp.Picture.nAmbKp;
                case 'Amb_nKp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.AmbnKp;
                    Exp.Current.Picture = Exp.Picture.AmbnKp;
                case 'nAmb_nKp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.nAmbnKp;
                    Exp.Current.Picture = Exp.Picture.nAmbnKp;
            end
            Exp.Current.Text = ['Phase d''Experience - ' Exp.Current.Condition '\n\n'...
                'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                'Essai : ' num2str(Exp.Current.TrialInBlock) '\n\n'...
                Exp.Current.taskMsg];
            
        case 'ESTIM'
            switch Exp.Current.Condition
                case 'Amb_Kp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.AmbKp;
                    Exp.Current.Picture = Exp.Picture.AmbKp;
                case 'nAmb_Kp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.nAmbKp;
                    Exp.Current.Picture = Exp.Picture.nAmbKp;
                case 'Amb_nKp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.AmbnKp;
                    Exp.Current.Picture = Exp.Picture.AmbnKp;
                case 'nAmb_nKp'
                    Exp.Current.taskMsg = ' ';%Exp.Text.taskMsg.nAmbnKp;
                    Exp.Current.Picture = Exp.Picture.nAmbnKp;
            end
            Exp.Current.Text = ['Phase d''Estimation de paramètres - ' Exp.Current.Condition '\n\n'...
                'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                'Essai : ' num2str(Exp.Current.TrialInBlock) '\n\n'...
                Exp.Current.taskMsg];
    end
end

end