function keys = decode(trigger)

% returns a string of three characters either 1 or 0 indicating respectively 
% whether the left, up, and right key is pressed
keys = dec2bin(trigger - 80);