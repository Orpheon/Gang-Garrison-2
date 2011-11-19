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
    
    var acceptor;
    if global.isPlayingReplay
    {
        acceptor = tcp_listen(global.serverPort);
    }

    global.serverSocket = tcp_connect(global.serverIP, global.serverPort);
    
    if global.isPlayingReplay// Create loopback connection for the replay
    {
        do
        {
            global.replaySocket = socket_accept(acceptor);
            io_handle();
        }
        until(global.replaySocket >= 0)
        
        socket_destroy(acceptor)// Not needed anymore
    }
    
    write_ubyte(global.serverSocket, HELLO);
    write_buffer(global.serverSocket, global.protocolUuid);
    socket_send(global.serverSocket);
}
