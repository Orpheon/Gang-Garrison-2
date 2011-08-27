if(serverbalance != 0)
    balancecounter+=1;

// Register with Lobby Server every 30 seconds
if(global.useLobbyServer and (frame mod 900)==0)
{
    sendLobbyRegistration();
}
frame += 1;

buffer_clear(global.sendBuffer);

// Service all players
var i;
for(i=0; i<ds_list_size(global.players); i+=1)
{
    var player;
    player = ds_list_find_value(global.players, i);
    
    if(player.kick)
    {
        removePlayer(player);
        ServerPlayerLeave(i);
        i-=1;
    }
    else
    {
        if(player.authorized == false)
        {
            player.passwordCount += 1;
            if(player.passwordCount == 30*30)
            {
                write_ubyte(player.socket, KICK);
                write_ubyte(player.socket, KICK_PASSWORDCOUNT);
                player.kick = 1
            }
        }
    }
}

processClientCommands();

if(syncTimer == 1 || ((frame mod 3600)==0) || global.setupTimer == 180)
{
    serializeState(CAPS_UPDATE, global.sendBuffer);
    syncTimer = 0;
}

if((frame mod 7) == 0)
    serializeState(QUICK_UPDATE, global.sendBuffer);
else
    serializeState(INPUTSTATE, global.sendBuffer);

if(impendingMapChange > 0)
    impendingMapChange -= 1; // countdown until a map change

if(global.winners != -1 and !global.mapchanging)
{
    if(global.winners == TEAM_RED and global.currentMapArea < global.totalMapAreas)
    {
        global.nextMap = global.currentMap;
        global.currentMapArea += 1;
    }
    else
    { 
        global.currentMapIndex += 1;
        global.currentMapArea = 1;
        if(global.currentMapIndex == ds_list_size(global.map_rotation)) 
            global.currentMapIndex = 0;
        global.nextMap = ds_list_find_value(global.map_rotation, global.currentMapIndex);
    }
    global.mapchanging = 1;
    impendingMapChange = 300; // in 300 frames (ten seconds), we'll do a map change
    
    write_ubyte(global.eventBuffer, MAP_END);
    write_ubyte(global.eventBuffer, string_length(global.nextMap));
    write_string(global.eventBuffer, global.nextMap);
    write_ubyte(global.eventBuffer, global.winners);
    write_ubyte(global.eventBuffer, global.currentMapArea);
    
    if(!instance_exists(ScoreTableController))
        instance_create(0,0,ScoreTableController);
    instance_create(0,0,WinBanner);
}

// if map change timer hits 0, do a map change
if(impendingMapChange == 0)
{
    global.mapchanging = 0;
    global.currentMap = global.nextMap;
    if(file_exists("Maps/" + global.currentMap + ".png"))
    { // if this is an external map, get the md5 and url for the map
        global.currentMapURL = CustomMapGetMapURL(global.currentMap);
        global.currentMapMD5 = CustomMapGetMapMD5(global.currentMap);
        room_goto_fix(CustomMapRoom);
    }
    else
    { // internal map, so at the very least, MD5 must be blank
        global.currentMapURL = "";
        global.currentMapMD5 = "";
        if(gotoInternalMapRoom(global.currentMap) != 0)
        {
            show_message("Error:#Map " + global.currentMap + " is not in maps folder, and it is not a valid internal map.#Exiting.");
            game_end();
        }
    }
    ServerChangeMap(global.currentMap, global.currentMapURL, global.currentMapMD5, global.eventBuffer);
    impendingMapChange = -1;
    
    with(Player)
    {
        if(global.currentMapArea == 1)
        {
            stats[KILLS] = 0;
            stats[DEATHS] = 0;
            stats[CAPS] = 0;
            stats[ASSISTS] = 0;
            stats[DESTRUCTION] = 0;
            stats[STABS] = 0;
            stats[HEALING] = 0;
            stats[DEFENSES] = 0;
            stats[INVULNS] = 0;
            stats[BONUS] = 0;
            stats[DOMINATIONS] = 0;
            stats[REVENGE] = 0;
            stats[POINTS] = 0;
            roundStats[KILLS] = 0;
            roundStats[DEATHS] = 0;
            roundStats[CAPS] = 0;
            roundStats[ASSISTS] = 0;
            roundStats[DESTRUCTION] = 0;
            roundStats[STABS] = 0;
            roundStats[HEALING] = 0;
            roundStats[DEFENSES] = 0;
            roundStats[INVULNS] = 0;
            roundStats[BONUS] = 0;
            roundStats[DOMINATIONS] = 0;
            roundStats[REVENGE] = 0;
            roundStats[POINTS] = 0;
            team = TEAM_SPECTATOR;
        }
        timesChangedCapLimit = 0;
        alarm[5]=1;
    }
}


global.frameCount += 1
if global.frameCount > 31999
{
    global.frameCount = 0
}

global.eventBufferLengthArray[global.frameCount] = buffer_size(global.eventBuffer)+5*sign(buffer_size(global.eventBuffer))// 5 = byte for PACKET_ID + short for global.frameCount + short for buffer length array.
                                                                                                                          //Of course only add if there's something in the eventBuffer (hence the *sign())

var i;
for(i=1; i<ds_list_size(global.players); i+=1)
{
    var player;
    player = ds_list_find_value(global.players, i);
    
    if buffer_size(global.eventBuffer) > 0
    {
//        show_message("Server:#Player="+string(i)+"; ACKbufferSize="+string(buffer_size(player.ACKbuffer))+"; frame="+string(global.frameCount)+"; eventBufferSize="+string(buffer_size(global.eventBuffer)))
        write_ubyte(player.ACKbuffer, ACK_REQUEST)
        write_ushort(player.ACKbuffer, global.frameCount)
        write_ushort(player.ACKbuffer, global.eventBufferLengthArray[global.frameCount]-5)
        write_buffer(player.ACKbuffer, global.eventBuffer)
    }
    
    write_buffer(global.socketAcceptor, player.ACKbuffer)
    write_buffer(global.socketAcceptor, global.sendBuffer)
    write_ubyte(global.socketAcceptor, PACKET_END)
    udp_send(global.socketAcceptor, player.ip, player.port)
}
buffer_clear(global.eventBuffer);
buffer_clear(global.socketAcceptor)
