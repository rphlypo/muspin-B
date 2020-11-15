% GenerateExperimentVisuals
function GenerateExperimentVisuals()

global Exp;

% Grating texture size:
Exp.Visual.Common.gratSize = angle2pix(Exp.PTB.W, Exp.PTB.res(1), Exp.PTB.D, Exp.Visual.Common.gratSizeDeg); %400; % in pixels

% Aperture size:
Exp.Visual.Common.apSizeDeg = pix2angle(Exp.PTB.W, Exp.PTB.res(1), Exp.PTB.D, Exp.Visual.Common.apSize); % radius in degrees

% Gaze oval zone size:
Exp.Visual.Common.ovSize = angle2pix(Exp.PTB.W, Exp.PTB.res(1), Exp.PTB.D, Exp.Visual.Common.ovSizeDeg); %40; %50;% radius in pixels
Exp.Visual.Common.ovcol = [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol]; % RGB

% Mouse response zone parameters:
Exp.Visual.Common.MouseRespOvalSize = Exp.Visual.Common.gratSize + angle2pix(Exp.PTB.W, Exp.PTB.res(1), Exp.PTB.D, Exp.Visual.Common.MouseRespOvalOffsetDeg); %40; 
Exp.Visual.Common.MouseRespOvalCol = ones(1, 3) * (Exp.Visual.Common.bckcol - 0); % exp? florian