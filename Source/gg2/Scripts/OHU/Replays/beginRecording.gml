
var tempBuffer;
tempBuffer = buffer_create();

write_ubyte(tempBuffer, HELLO);
write_ubyte(tempBuffer, string_length(global.serverName));
write_string(tempBuffer, global.serverName);
write_ubyte(tempBuffer, string_length(global.currentMap));
write_string(tempBuffer, global.currentMap);
write_ubyte(tempBuffer, string_length(global.currentMapMD5));
write_string(tempBuffer, global.currentMapMD5);

ServerJoinUpdate(tempBuffer);
write_ubyte(tempBuffer, PLAYER_JOIN);
write_ubyte(tempBuffer, 0);// Length of name

write_ubyte(global.replayBuffer, buffer_size(tempBuffer));
write_buffer(global.replayBuffer, tempBuffer);
        
global.justEnabledRecording = 0
