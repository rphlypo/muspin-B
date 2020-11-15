if Exp.Flags.MOUSE
    if Exp.Flags.DUMMY % Dummy means the computer is doing the mouse task
        dummy_bad = 0;
        if dummy_bad
            if cnt > 1
                mx(cnt) = (mx(cnt-1) + 1.*randn(1,1));
                my(cnt) = (my(cnt-1) + 1.*randn(1,1));
            else
                mx(cnt) = randn(1,1) + Exp.PTB.w/2;
                my(cnt) = randn(1,1) + Exp.PTB.h/2;
            end
        else
            if Exp.Current.TrialInBlock == 1
                lag = 10;
            else
                lag = 5;
            end
            if cnt > lag
                mx(cnt) = dotDisp(cnt-lag,1) + Exp.PTB.w/2;
                my(cnt) = dotDisp(cnt-lag,2) + Exp.PTB.h/2;
            else
                mx(cnt) = 0;
                my(cnt) = 0;
            end
        end
        buttons = zeros(1,3);
        
    else % Participant is doing the mouse task
        [mx(cnt), my(cnt), buttons] = GetMouse(win);
    end
    MouseTimes(cnt) = GetSecs;
    mpos(cnt,:) = [mx(cnt), my(cnt)];

    %% Compute distance
    if strcmp(Exp.Type, 'TopDown')
        Inertia(cnt) = norm([mpos(cnt,1)-Exp.PTB.w/2, mpos(cnt,2)-Exp.PTB.h/2] - dotDisp(cnt,:)) ;
        t_ = GetSecs; % temps actuel
        t(cnt) = t_; %vecteur temps
        %                     inertia_ = nanmean(Inertia(t>=t_ - 0));
        inertia_ = nanmedian(Inertia(t>=t_ - Exp.Parameters.InertiaTimeWindowSize)); % Inertia Temporal Window Size: median is computed over this sliding time lapse
        
        if strcmp(Exp.Current.Condition, 'BL') && strcmp(Exp.Current.Phase, 'LEARN') % in BL Learn, the mouse is not used
            Screen('DrawDots', win, [Exp.PTB.w/2, Exp.PTB.h/2], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
            
        else
            if (t_ - t(1) > Exp.Parameters.InertiaTimeWindowSize) % Give a delay for inertia computation at the begining of trial
                switch Exp.Current.Phase
                    case 'TEST'
                        if inertia_ > InertiaReferenceFinal
                            %                                         Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, [.9 .4 .4], [], 2);
                            Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                            dev_cnt(cnt) = 1;
                        else
                            Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                        end
                    case 'LEARN'
                        if Exp.Current.TrialInBlock > 1 && strcmp(Exp.Current.Condition, 'LJ')
                            if inertia_ > InertiaReference
                                Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, [.9 .4 .4], [], 2);
                            else
                                Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, [.4 .9 .4], [], 2);
                            end
                        else
                            Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                        end
                end
                
            else
                Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
            end
        end
    else
        Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
    end

    if Exp.Flags.MOUSECLICKON
        % Check if buttom is pressed!
        if sum(buttons) ~= 0
            BUTTON_TIMEOUT_STARTED = 1;
            [trial_response(1), trial_response(2)] = GetMouse(win);
            trial_response(3) = GetSecs;
            TRIAL_ON = 0;
        end
    end

end