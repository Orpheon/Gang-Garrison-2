var player;

// Banning
ip = socket_remote_ip(socket)
show_message(ip)
show_message(ds_list_find_value(global.banlist, 0))
for (a=0; a<ds_list_size(global.banlist)-1; a+=1)
{
    if string(ip) == ds_list_find_value(global.banlist, a)
    {
        // Kick player
        socket_destroy(socket)
        print("A banned player has tried to join.")
    }
}

if(socket_has_error(socket)) {
    // Connection closed unexpectedly, remove client
    instance_destroy();
    exit;
}

if(tcp_receive(socket, expectedBytes)) {
    switch(state) {
    case STATE_EXPECT_HELLO:
        if(read_ubyte(socket) == PLAYER_JOIN) {
            state = STATE_EXPECT_NAME;
            expectedBytes = read_ubyte(socket);
        } else {
            socket_destroy_abortive(socket);
            instance_destroy();
        }
        break;
        
    case STATE_EXPECT_NAME:
        var noOfPlayers;
        noOfPlayers = ds_list_size(global.players);
        if(global.dedicatedMode)
            noOfPlayers -= 1;
        
        noOfPlayers -= instance_number(BotPlayer)
            
        if(noOfPlayers >= global.playerLimit) {
            write_ubyte(socket, SERVER_FULL);
            socket_destroy(socket);
            instance_destroy();
        } else {
            ServerJoinUpdate(socket);
            
            player = instance_create(0,0,Player);
            player.socket = socket;
            
            player.name = read_string(socket, expectedBytes);
            
            // sanitize player name
            player.name = string_copy(player.name, 0, MAX_PLAYERNAME_LENGTH);
            player.name = string_replace_all(player.name, "#", " ");
            
            ds_list_add(global.players, player);
            
            ServerPlayerJoin(player.name, global.sendBuffer);
            
            instance_destroy();
        }
        break;
    }
}
