function [] = PrepareExpText()

global Exp;

Exp.Picture.Consigne = fullfile('Images', 'Consigne.jpg');
if Exp.Flags.EYETRACK
    Exp.Text.startingMsg='Vous allez passer une experience d''oculometrie.\n\nAvant de commencer l''experience nous allons ajuster l''oculometre.\n\nVous devez pour cela placer votre visage sur le support.\n\n\nAppuyez pour continuer.';
    Exp.Text.driftCorrectionMsg='Fixer le point sans cligner des yeux.';
else
    Exp.Text.startingMsg= 'Vous allez passer l''experience Gaze-EEG.\n\n\n Appuyez sur espace pour commencer.';
end
Exp.Text.trackerSetupMsg='Durant la phase de calibration nous allons ajuster les cameras sur vos yeux.\n\n\nVous devrez suivre du regard le point qui apparaitra.\n\nSuivez ce point sans cligner des yeux et sans essayer d''anticiper sa position. \n\n\n\nUne fois la calibration faite, veuillez ne plus bouger la tete\n\n\nAppuyez pour continuer.';
Exp.Text.learningMsg='Phase d''apprentissage pour vous familiariser avec l''experience.';
Exp.Text.testingMsg='Nous allons maintenant commencer l''experience.\n\n Essayez de bouger le moins possible.';
Exp.Text.endingMsg='Merci de votre participation !';
Exp.Text.readyMsg='Appuyez sur espace quand vous etes pret(e).';
% Exp.Text.taskMsg= tsktxt;
Exp.Text.seqEndMsg='Fin de la sequence';
Exp.Text.blockEndMsg='Fin du block';

if strcmp(Exp.Type, 'GazeEEG')
    %Exp.Text.taskMsg.StimCalib = 'StimCalib';
    Exp.Picture.AmbKp = fullfile('Images', 'PRESS.jpg');%'Maintenez le regard sur le point de fixation qui se trouve au centre.\n\n Votre main doit être posée confortablement sur le clavier, avec :\n\n - Un doigt posé sur la touche "flèche du haut", \n\n - Un doigt posé sur la touche "flèche de droite", \n\n - Un doigt posé sur la touche "flèche de gauche"\n\nAppuyez sur la flèche du clavier correspondant aux mouvements des barres.\n\nMaintenez la flèche autant de temps que vous verrez les barres se deplacer dans cette direction.\n\n Lorsque les barres changent de direction, changez de touche le plus rapidement possible.'; %'Consigne BASELINE';%'Ambigue key press';
    Exp.Picture.nAmbKp = fullfile('Images', 'PRESS.jpg');%'Maintenez le regard sur le point de fixation qui se trouve au centre.\n\n Votre main doit être posée confortablement sur le clavier, avec :\n\n - Un doigt posé sur la touche "flèche du haut", \n\n - Un doigt posé sur la touche "flèche de droite", \n\n - Un doigt posé sur la touche "flèche de gauche"\n\nAppuyez sur la flèche du clavier correspondant aux mouvements des barres.\n\nMaintenez la flèche autant de temps que vous verrez les barres se deplacer dans cette direction.\n\n Lorsque les barres changent de direction, changez de touche le plus rapidement possible.'; %'Consigne BASELINE'%'Non ambigue key press';
    Exp.Picture.AmbnKp = fullfile('Images', 'NoPRESS.jpg');%'Maintenez le regard sur le point de fixation qui se trouve au centre.';%Consigne BASELINE''Ambigue non Key press';
    Exp.Picture.nAmbnKp = fullfile('Images', 'NoPRESS.jpg');%'M
 %   Exp.Text.taskMsg.AmbKp = 'Maintenez le regard sur le point de fixation qui se trouve au centre.\n\n Votre main doit �tre pos�e confortablement sur le clavier, avec :\n\n - Un doigt posé sur la touche "flèche du haut", \n\n - Un doigt posé sur la touche "flèche de droite", \n\n - Un doigt posé sur la touche "flèche de gauche"\n\nAppuyez sur la flèche du clavier correspondant aux mouvements des barres.\n\nMaintenez la flèche autant de temps que vous verrez les barres se deplacer dans cette direction.\n\n Lorsque les barres changent de direction, changez de touche le plus rapidement possible.'; %'Consigne BASELINE';%'Ambigue key press';
 %   Exp.Text.taskMsg.nAmbKp = 'Maintenez le regard sur le point de fixation qui se trouve au centre.\n\n Votre main doit �tre pos�e confortablement sur le clavier, avec :\n\n - Un doigt posé sur la touche "flèche du haut", \n\n - Un doigt posé sur la touche "flèche de droite", \n\n - Un doigt posé sur la touche "flèche de gauche"\n\nAppuyez sur la flèche du clavier correspondant aux mouvements des barres.\n\nMaintenez la flèche autant de temps que vous verrez les barres se deplacer dans cette direction.\n\n Lorsque les barres changent de direction, changez de touche le plus rapidement possible.'; %'Consigne BASELINE'%'Non ambigue key press';
 %   Exp.Text.taskMsg.AmbnKp = 'Maintenez le regard sur le point de fixation qui se trouve au centre.';%Consigne BASELINE''Ambigue non Key press';
 %   Exp.Text.taskMsg.nAmbnKp = 'Maintenez le regard sur le point de fixation qui se trouve au centre.';%'Non ambigue non Key press';
end