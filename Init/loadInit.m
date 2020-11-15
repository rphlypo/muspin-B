function loadInit(initfile)

global Exp;
Exp = struct();

Exp.Init = initfile;  % register the init file into the Exp structure
eval(Exp.Init);  % load the init file