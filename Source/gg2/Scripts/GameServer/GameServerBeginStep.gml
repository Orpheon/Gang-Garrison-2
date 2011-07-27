if(serverbalance != 0)
    balancecounter+=1;

if global.bot_mode == 2
{
    global.bot_num_wished = instance_number(Player)+1
}

// Register with Lobby Server every 30 seconds
if(global.useLobbyServer and (frame mod 900)==0)
    sendLobbyRegistration();
frame += 1;

buffer_clear(global.sendBuffer);

if global.bot_num_wished < 0
{
    global.bot_num_wished = 0
}

while global.bot_num < global.bot_num_wished
{
    CreateBot()
}
while global.bot_num > global.bot_num_wished
{
    DestroyBot()
}

acceptJoiningPlayer();
with(JoiningPlayer)
    serviceJoiningPlayer();
    
// Service all players
var i;
for(i=0; i<ds_list_size(global.players); i+=1)
{
    var player;
    player = ds_list_find_value(global.players, i);
    
    if player.object_index == BotPlayer
    {
        with player
        {
            event_user(14)
        }
        
        if player.build == 1 //Building a sentry
        {
            if(player.object != -1)
            {
                if(player.class == CLASS_ENGINEER
                and collision_circle(player.object.x, player.object.y, 50, Sentry, false, true) < 0
                and player.object.nutsNBolts == 100 and (collision_point(player.object.x,player.object.y,SpawnRoom,0,0) < 0)
                and player.sentry == -1 and !player.object.onCabinet)
                {
                    buildSentry(player);
                    write_ubyte(global.sendBuffer, BUILD_SENTRY);
                    write_ubyte(global.sendBuffer, i);
                }
            }

        }
        else if player.build == -1 //Destroying a sentry.
        {
            if(player.sentry != -1) {
                with(player.sentry) {
                    instance_destroy();
                }
            }
            player.sentry = -1;
        }
        
        continue
    }
        
    if(socket_has_error(player.socket))
    {
        if ds_list_find_index(global.chatters, player) >= 0
        {
            // Remove the player from the chat:
            ds_list_delete(global.chatters, ds_list_find_index(global.chatters, player))
            if player.team = TEAM_RED
            {
                write_ubyte(global.chatBufferRed, OHU_CHAT_LEAVE)
                write_ubyte(global.chatBufferRed, i)
            }
            else if player.team == TEAM_BLUE
            {
                write_ubyte(global.chatBufferBlue, OHU_CHAT_LEAVE)
                write_ubyte(global.chatBufferBlue, i)
            }
            else if player.team == TEAM_SPECTATOR
            {
                write_ubyte(global.chatBufferBlue, OHU_CHAT_LEAVE)
                write_ubyte(global.chatBufferBlue, i)
            }
        }
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
                socket_destroy(player.socket);
                player.socket = -1;
            }
        }
        processClientCommands(player, i);        
    }
}

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
    if !global.mapChangeCommanded
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
    }
    global.mapchanging = 1;
    impendingMapChange = 300; // in 300 frames (ten seconds), we'll do a map change
    
    write_ubyte(global.sendBuffer, MAP_END);
    write_ubyte(global.sendBuffer, string_length(global.nextMap));
    write_string(global.sendBuffer, global.nextMap);
    write_ubyte(global.sendBuffer, global.winners);
    write_ubyte(global.sendBuffer, global.currentMapArea);
    
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
    ServerChangeMap(global.currentMap, global.currentMapURL, global.currentMapMD5, global.sendBuffer);
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
    
    for (i=0; i<ds_list_size(global.players)-1; i+=1)
    {
        player = ds_list_find_value(global.players, i)
        
        if player.object_index == BotPlayer
        {
            removePlayer(player)
            ServerPlayerLeave(i)
            i -= 1 //This is what was causing me all those errors. Graaah.
        }
    }
    global.bot_num = 0
}

global.mapChangeCommanded = 0

var i;
for(i=1; i<ds_list_size(global.players); i+=1)
{
    var player;
    player = ds_list_find_value(global.players, i);
    if player.object_index == BotPlayer
    {
        continue;
    }
    write_buffer(player.socket, global.eventBuffer);
    write_buffer(player.socket, global.sendBuffer);
    if ds_list_find_index(global.chatters, player) >= 0
    {
        if player.team == TEAM_RED
        {
            write_buffer(player.socket, global.chatBufferRed)
        }
        else if player.team == TEAM_BLUE
        {
            write_buffer(player.socket, global.chatBufferBlue)
        }
        else if player.team = TEAM_SPECTATOR
        {
            write_buffer(player.socket, global.chatBufferSpectator)
        }
    }
    socket_send(player.socket);
}



buffer_clear(global.eventBuffer);
buffer_clear(global.chatBufferBlue);
buffer_clear(global.chatBufferRed);
buffer_clear(global.chatBufferSpectator);
