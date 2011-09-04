{
    with(Client)
        instance_destroy();

    global.players = ds_list_create();

    global.socketAcceptor = udp_bind(global.hostingPort)

    global.serverSocket = global.socketAcceptor// Need to throughly clean this afterwards. global.serverSocket isn't needed anymore.

    global.lobbySocket = tcp_listen(global.hostingPort)
    
    global.currentMapIndex = 0;
    global.currentMapArea = 1;

    serverbalance=0;
    balancecounter=0;
    randomize();
    global.randomSeed=random_get_seed();
    frame = 0;
    updatePlayer = 1;
    impendingMapChange = -1; // timer variable used by GameServerBeginStep, when it hits 0, the server executes a map change to global.nextMap
    syncTimer = 0; //called in GameServerBeginsStep on CP/intel cap to update everyone with timer/caps/cp status

    // Player 0 is reserved for the Server.
    serverPlayer = instance_create(0,0,Player);
    serverPlayer.name = global.playerName;
    ds_list_add(global.players, serverPlayer);

    newSocket = udp_bind(0)// Get a random port and assign it to the server player, it gets destroyed afterwards.

    serverPlayer.ip = "127.0.0.1"
    serverPlayer.port = socket_local_port(newSocket)
    
    socket_destroy(newSocket)

    // This is only for the server; so that it knows where to send stuff too.
    global.serverIP = "127.0.0.1"
    global.serverPort = global.hostingPort

    global.playerID = 0;
    global.myself = serverPlayer;
    global.myself.authorized = true;
    playerControl = instance_create(0,0,PlayerControl);

    global.currentMap = ds_list_find_value(global.map_rotation, global.currentMapIndex);
    if(file_exists("Maps/" + global.currentMap + ".png")) { // if this is an external map
        // get the md5 and url for the map
        global.currentMapURL = CustomMapGetMapURL(global.currentMap);
        global.currentMapMD5 = CustomMapGetMapMD5(global.currentMap);
        room_goto_fix(CustomMapRoom);
    } else { // internal map, so at the very least, MD5 must be blank
        global.currentMapURL = "";
        global.currentMapMD5 = "";
        if(gotoInternalMapRoom(global.currentMap) != 0) {
            show_message("Error:#Map " + global.currentMap + " is not in maps folder, and it is not a valid internal map.#Exiting.");
            game_end();
        }
    }

    global.joinedServerName = global.serverName; // so no errors of unknown variable occur when you create a server
    global.mapchanging=0;
}
