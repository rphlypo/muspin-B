function ps = isPureState(trigger)

ps = (length(strfind(decode(trigger), '1')) == 1);