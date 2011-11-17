// argument0 = message
write_ubyte(global.serverSocket, CHAT_MESSAGE_PRIVATE);
write_ubyte(global.serverSocket, string_length(argument0));
write_string(global.serverSocket, argument0);
