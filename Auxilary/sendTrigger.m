function flag = sendTrigger(x)

global Exp;
% define 0 for the parallel port
setZero = uint16(str2double('0'));
% data register of the parallel port
address = hex2dec('378');

%%%%%% TODO %%%%%%
% write trigger in the Exp structure

disp(address)
flag = [0, 0];

if Exp.Flags.EYETRACK
    try 
        Eyelink('Message',['INPUT ' x]);
    catch
        flag(1) = 1;
    end
end

if Exp.Flags.EEG
    try
        outp(address, uint16(str2double(x)));
        WaitSecs(.005);
        outp(address, setZero);
    catch
        flag(2) = 1;
    end
end