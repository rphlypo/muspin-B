function err = endAcquisition(dataFileName, Trigger)

global Exp;

err = 0;

sendTrigger(Trigger);

if Exp.Flags.EYETRACK
    s = sprintf('END PHASE\n');
    Eyelink('Message', s);

    s = sprintf('END ACQUISITION\n');
    Eyelink('Message',s);

    WaitSecs(0.1);
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    if Exp.Flags.SAVE
        % save el data file
        try
            fprintf('Receiving edf file ''%s'' from Eyelink\n', Exp.EyeLink.edfFile );
            status=Eyelink('ReceiveFile', Exp.Eyelink.edfFile, Exp.paths.dataDir);
            if status > 0
                fprintf('ReceiveFile status %d\n', status);
            end
            if 2==exist(Exp.EyeLink.edfFile, 'file')
                fprintf('Data file ''%s'' can be found in ''%s''\n', Exp.EyeLink.edfFile, Exp.paths.dataDir );
            else
                fprintf('Data file ''%s'' could not be found in ''%s'', please try a manual download from the Eyelink PC', Exp.EyeLink.edfFile, Exp.paths.dataDir )
            end
        catch err
            fprintf('Problem receiving data file ''%s''\n', Exp.EyeLink.edfFile );
            psychrethrow(err);
        end
    end

    WaitSecs(0.1);
    Eyelink('ShutDown');

end

if Exp.Flags.SAVE
    save(fullfile(Exp.paths.dataDir, Exp.paths.fileName), 'Exp');
end