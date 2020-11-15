function flag = sendTrigger(x)

global Exp;
% define 0 for the parallel port
setZero = uint16(str2double('0'));
% data register of the parallel port
address = hex2dec('378');


disp(address)
flag = [0, 0];

% write trigger in the Exp structure
Exp.Data.Triggers(end+1, :) = [GetSecs, str2num(x)];

if Exp.Flags.EYETRACK
    try 
        Eyelink('Message',['INPUT ' x]);
    catch
        flag(1) = 1;
    end
end

if Exp.Flags.EEG || Exp.Flags.EYETRACK
    try
        outp(address, uint16(str2double(x)));
        WaitSecs(.005);
        outp(address, setZero);
    catch
        flag(2) = 1;
    end
end