var noOfPlayers, serverDescription;
noOfPlayers = ds_list_size(global.players);
if(global.dedicatedMode)
    noOfPlayers -= 1;

serverDescription = "[" + global.currentMap +"] " + global.serverName + " [" + string(noOfPlayers) + "/" + string(global.playerLimit) + "]";
if(global.serverPassword != "")
    serverDescription = "!private!" + serverDescription;

// Magic numbers
write_ubyte(global.socketAcceptor, 4);
write_ubyte(global.socketAcceptor, 8);
write_ubyte(global.socketAcceptor, 15);
write_ubyte(global.socketAcceptor, 16);
write_ubyte(global.socketAcceptor, 23);
write_ubyte(global.socketAcceptor, 42);

// Indicate that a UUID follows
write_ubyte(global.socketAcceptor, 128);

// Send version UUID (big endian)
for(i=0; i<16; i+=1)
    write_ubyte(global.socketAcceptor, global.protocolUuid[i]);
    
write_ushort(global.socketAcceptor, global.hostingPort);
write_ubyte(global.socketAcceptor, string_length(serverDescription));
write_string(global.socketAcceptor, serverDescription);
udp_send(global.socketAcceptor, LOBBY_SERVER_HOST, LOBBY_SERVER_PORT);
