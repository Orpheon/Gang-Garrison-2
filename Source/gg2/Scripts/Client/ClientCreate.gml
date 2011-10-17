{
    // Only one client object may exist at a time
    if(instance_number(object_index)>1) {
        nocreate=true;
        instance_destroy();
        exit;
    }
    nocreate=false;
    usePreviousPwd = false;
    
    global.players = ds_list_create();
    global.deserializeBuffer = buffer_create();
    global.isHost = false;

    global.myself = -1;
    gotServerHello = false;  
    returnRoom = Menu;
    downloadingMap = false;
    downloadMapBuffer = -1;
    
    global.serverSocket = tcp_connect(global.serverIP, global.serverPort);
    
    //Uses the lobby name to create a global variable for use with scoreboard
    //deletes the part up to "] ", which is the end of the map listing
    global.joinedServerName = string_delete(global.joinedServerName, 1, string_pos("] ", global.joinedServerName) + 1);
    //takes the part before " [", or the player list, leaving the server name
    //First, see if there's any other brackets in the name (/v/idya [US west]) by counting them, 
    //then keeps checking until [%/%] is left, and takes the size
    var tempServName;
    if(string_count(" [",global.joinedServerName) > 1){
        tempServName = global.joinedServerName;
        while(string_count("[", tempServName) > 1)
            tempServName = string_delete(tempServName, 1, string_pos(" [", tempServName) + 1);
        tempServName = string_delete(tempServName, 1, string_pos(" [", tempServName));
        global.joinedServerName = string_copy(global.joinedServerName, 1, string_length(global.joinedServerName) - string_length(tempServName));
    }
    else global.joinedServerName = string_copy(global.joinedServerName, 1, string_pos(" [", global.joinedServerName) - 1);
        
    buffer_clear(global.sendBuffer);
    ClientPlayerJoin(global.playerName);
    write_buffer(global.serverSocket, global.sendBuffer);
    if(global.haxxyKey != "")
        write_byte(global.serverSocket, I_AM_A_HAXXY_WINNER);
    write_ubyte(global.serverSocket, HELLO);
    write_buffer(global.serverSocket, global.protocolUuid);
    socket_send(global.serverSocket);
}
