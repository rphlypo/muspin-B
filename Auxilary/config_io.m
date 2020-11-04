function config_io

global address
global cogent;

%create IO32 interface object
clear io32;
cogent.io.ioObj = io32;

%install the inpout32.dll driver
%status = 0 if installation successful
cogent.io.status = io32(cogent.io.ioObj);
if(cogent.io.status ~= 0)
    disp('inpout32 installation failed!')
else
    disp('inpout32 (re)installation successful.')
end

if( cogent.io.status ~= 0 )
    error('inp/h installation failed');
    return;
end
% data register of the parallel port
address = hex2dec('378');

outp(address, 0);

    

