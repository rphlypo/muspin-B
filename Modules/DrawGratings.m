% Set angles of gratings for this loop:
Loop_Angle = [Exp.Current.BaseLineOrientation + Exp.Visual.Grating(1).rotAngles, ...
    Exp.Current.BaseLineOrientation + Exp.Visual.Grating(2).rotAngles];

% Set transparency values for this loop:

switch Exp.Current.Condition(1)
    case 'A'
        Loop_Alpha = Exp.Current.Alphas;
    case 'n'
        Loop_Alpha = Exp.Current.AlphasFrameByFrame(cnt,:);
        PlaidState = Exp.Current.StateFrameByFrame{cnt};
        if ~strcmpi(PlaidState, currentPlaidState)
            currentPlaidState = PlaidState;
            sendTrigger(eval(['Exp.Trigger.Plaid.', currentPlaidState]));
        end
end
LoopAlphas(cnt,:) = Loop_Alpha;
%                 cnt2 = cnt2 + 1;
% Adjust luminance and contrast depending on alphas picked:
[Loop_Luminance, Loop_Contrast] = fLuminanceContrast(Loop_Alpha, ...
    Exp.Visual.Common.bckcol2, Exp.Visual.Grating(1).mean, Exp.Visual.Grating(1).dutycycle);
[Loop_BetaLum, Loop_OffsetLum] = fEgalisateur(Loop_Luminance, Loop_Contrast, ...
    Exp.Visual.Common.LuminanceRef, Exp.Visual.Common.ContrastRef);
Loop_GratingLum(1) = Loop_BetaLum * Exp.Visual.Grating(1).mean + Loop_OffsetLum;
Loop_GratingLum(2) = Loop_BetaLum * Exp.Visual.Grating(2).mean + Loop_OffsetLum;
Loop_BackGround = Loop_BetaLum * Exp.Visual.Common.bckcol2 + Loop_OffsetLum;

% Compute displacement of gratings based on current time:
TimeForMotion = mod(GetSecs - Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimStart, ...
    (Exp.Visual.Common.apSize) / Exp.PTB.SpeedInPix(1));
%                     (Exp.Visual.Common.apSizeDeg) / Exp.Visual.Grating(1).speed)

if MOTION
    gratingDisp = [TimeForMotion .* Exp.PTB.SpeedInPix(1), ...
        TimeForMotion .* Exp.PTB.SpeedInPix(1) + Exp.Current.PhaseShift];
    %                     [round(TimeForMotion .* Exp.PTB.SpeedInPix(1)), ...
    %                         round(TimeForMotion .* Exp.PTB.SpeedInPix(1)) + Exp.Current.PhaseShift]
else
    gratingDisp = [round(TimeToStop .* Exp.PTB.SpeedInPix(1)), ...
        round(TimeToStop .*Exp.PTB.SpeedInPix(1)) + Exp.Current.PhaseShift];
end
dotDisp(cnt,:) = fGenLissajouT(GetSecs, Exp.Visual.Lissajou.amp, ...
    Exp.Visual.Lissajou.fv, Exp.Visual.Lissajou.fh, Exp.Visual.Lissajou.phase);

% Grating 1:
g1_cst(1) = Exp.PTB.w/2-(Exp.Visual.Grating(1).dutycycle*1/Exp.Visual.Grating(1).freq/2) - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * cosd(Loop_Angle(1));
g1_cst(2) = Exp.PTB.w/2+(Exp.Visual.Grating(1).dutycycle*1/Exp.Visual.Grating(1).freq/2) - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * cosd(Loop_Angle(1));
g1_cst(3) = 0 - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * sind(Loop_Angle(1));
g1_cst(4) = Exp.PTB.h - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * sind(Loop_Angle(1));
dstRects_g1(1,:) = [g1_cst(1) + (-5).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-5).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-5).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-5).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
dstRects_g1(2,:) = [g1_cst(1) + (-4).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-4).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-4).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-4).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
dstRects_g1(3,:) = [g1_cst(1) + (-3).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-3).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-3).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-3).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
dstRects_g1(4,:) = [g1_cst(1) + (-2).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-2).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-2).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-2).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
dstRects_g1(5,:) = [g1_cst(1) + (-1).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-1).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-1).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-1).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
dstRects_g1(6,:) = [g1_cst(1) + 0.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 0.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 0.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 0.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
dstRects_g1(7,:) = [g1_cst(1) + 1.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 1.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 1.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 1.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
dstRects_g1(8,:) = [g1_cst(1) + 2.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 2.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 2.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 2.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
dstRects_g1(9,:) = [g1_cst(1) + 3.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 3.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 3.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 3.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
dstRects_g1(10,:) = [g1_cst(1) + 4.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 4.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 4.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 4.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];

% Grating 2:
g2_cst(1) = Exp.PTB.w/2-(Exp.Visual.Grating(2).dutycycle*1/Exp.Visual.Grating(2).freq/2) - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * cosd(Loop_Angle(2));
g2_cst(2) = Exp.PTB.w/2+(Exp.Visual.Grating(2).dutycycle*1/Exp.Visual.Grating(2).freq/2) - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * cosd(Loop_Angle(2));
g2_cst(3) = 0 - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * sind(Loop_Angle(2));
g2_cst(4) = Exp.PTB.h - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * sind(Loop_Angle(2));

dstRects_g2(1,:) = [g2_cst(1) + (-5).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-5).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-5).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-5).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
dstRects_g2(2,:) = [g2_cst(1) + (-4).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-4).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-4).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-4).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
dstRects_g2(3,:) = [g2_cst(1) + (-3).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-3).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-3).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-3).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
dstRects_g2(4,:) = [g2_cst(1) + (-2).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-2).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-2).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-2).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
dstRects_g2(5,:) = [g2_cst(1) + (-1).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-1).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-1).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-1).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
dstRects_g2(6,:) = [g2_cst(1) + 0.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 0.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 0.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 0.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
dstRects_g2(7,:) = [g2_cst(1) + 1.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 1.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 1.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 1.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
dstRects_g2(8,:) = [g2_cst(1) + 2.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 2.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 2.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 2.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
dstRects_g2(9,:) = [g2_cst(1) + 3.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 3.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 3.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 3.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
dstRects_g2(10,:) = [g2_cst(1) + 4.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 4.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 4.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 4.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];


% Draw the perceived background
Screen('Blendfunction', win, GL_ONE, GL_ZERO);
if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition,'Dynamic')
    Screen('FillRect', win, Loop_BackGround .* ones(1,3), Exp.PTB.winRect);
else
    Screen('FillRect', win, Exp.Current.BackGround .* ones(1,3), Exp.PTB.winRect);
end
Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 1 1 1]);

% Draw first grating
Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(1,:), Loop_Angle(1), [], Loop_Alpha(1));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(2,:), Loop_Angle(1), [], Loop_Alpha(1));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(3,:), Loop_Angle(1), [], Loop_Alpha(1));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(4,:), Loop_Angle(1), [], Loop_Alpha(1));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(5,:), Loop_Angle(1), [], Loop_Alpha(1));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(6,:), Loop_Angle(1), [], Loop_Alpha(1));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(7,:), Loop_Angle(1), [], Loop_Alpha(1));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(8,:), Loop_Angle(1), [], Loop_Alpha(1));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(9,:), Loop_Angle(1), [], Loop_Alpha(1));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(10,:), Loop_Angle(1), [], Loop_Alpha(1));

% Draw second grating
Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(1,:), Loop_Angle(2), [], Loop_Alpha(2));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(2,:), Loop_Angle(2), [], Loop_Alpha(2));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(3,:), Loop_Angle(2), [], Loop_Alpha(2));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(4,:), Loop_Angle(2), [], Loop_Alpha(2));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(5,:), Loop_Angle(2), [], Loop_Alpha(2));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(6,:), Loop_Angle(2), [], Loop_Alpha(2));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(7,:), Loop_Angle(2), [], Loop_Alpha(2));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(8,:), Loop_Angle(2), [], Loop_Alpha(2));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(9,:), Loop_Angle(2), [], Loop_Alpha(2));
Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(10,:), Loop_Angle(2), [], Loop_Alpha(2));

% Draw aperture
Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawTexture', win, Exp.Stimulus.aperturetex, [], Exp.PTB.winRect);

% Draw normal oval:
Screen('FillOval', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol 255], Exp.Stimulus.ovRect);
if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3 && not(strcmp(Exp.Current.Condition, 'NoRDK'))
    Screen('Blendfunction', win, GL_ONE, GL_ZERO);
    Screen('DrawDots', win, [Exp.Current.Particles.pixpos.x(cnt,Exp.Current.Particles.goodDots(cnt,:)); Exp.Current.Particles.pixpos.y(cnt,Exp.Current.Particles.goodDots(cnt,:))], ...
        Exp.Visual.Common.dotSize, ...
        [Exp.Visual.Common.dotcol(1), Exp.Visual.Common.dotcol(2), Exp.Visual.Common.dotcol(3)],...
        [], 2);
    Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
elseif strcmp(Exp.Current.Condition, 'NoRDK')
    Screen('DrawDots', win, [Exp.PTB.w/2 + dotDisp(cnt,1), Exp.PTB.h/2 + dotDisp(cnt,2)], Exp.Visual.Common.dotSize, Exp.Visual.Common.dotcol, [], 2);
else
    Screen('DrawDots', win, [Exp.PTB.w/2 + dotDisp(cnt,1), Exp.PTB.h/2 + dotDisp(cnt,2)], Exp.Visual.Common.dotSize, Exp.Visual.Common.dotcol, [], 2);
end

% Draw response oval
Screen('FrameOval', win, Exp.Visual.Common.MouseRespOvalCol, Exp.Stimulus.dst2Rect, 40);