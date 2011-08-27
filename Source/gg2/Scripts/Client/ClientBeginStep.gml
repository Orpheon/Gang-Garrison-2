// receive and interpret the server's message(s)
var i, playerObject, playerID, player, otherPlayerID, otherPlayer, sameVersion, buffer;

roomchange = 0
{
    if(socket_has_error(global.serverSocket)) {
        show_message("You have been disconnected from the server.");
        with(all) if id != AudioControl.id instance_destroy();
        room_goto_fix(Menu);
        exit; 
    }
    receivedInfo = udp_receive(global.serverSocket)

    if buffer_size(global.backupBuffer) > 0// You received stuff last frame you'd like to get rid of
    {
        buffer_clear(global.serverSocket)// Ignore the last message if there was one, everything important will come again.
    }

    write_buffer(global.socketBuffer, global.backupBuffer)
    write_buffer(global.socketBuffer, global.serverSocket)

    buffer_clear(global.backupBuffer)
    buffer_clear(global.serverSocket)

    while buffer_bytes_left(global.socketBuffer) > 0 and buffer_size(global.socketBuffer) > 0{

        if roomchange
        {
            // Write what's left of the state somewhere
            // And look at it next frame
            while buffer_bytes_left(global.socketBuffer) > 0
            {
                write_byte(global.backupBuffer, read_byte(global.socketBuffer))
            }
            break;
        }

        switch(read_ubyte(global.socketBuffer)) {

            case HELLO:

                sameVersion = true;
                connectionTimer = 1;

//                show_message("ClientBeginStep: Hello")

                if(read_short(global.socketBuffer) != 128) {
                    sameVersion = false;
                } else {
                    for(i=0; i<16; i+=1) {
                        if(read_ubyte(global.socketBuffer) != global.protocolUuid[i]) {
                            sameVersion = false;
                        }
                    }
                }

                if(not sameVersion) {
                    show_message("Incompatible server protocol version.");
                    with(all) if id != AudioControl.id instance_destroy();
                    room_goto_fix(Menu);
                    exit;
                } else {
                    global.playerID = read_ubyte(global.socketBuffer)-1;// -1 because the new player is already included in global.players
                    global.randomSeed = read_double(global.socketBuffer);
                    global.currentMapArea = read_ubyte(global.socketBuffer);
                    global.serverPort = socket_remote_port(global.serverSocket)
                }
                break;


            case PACKET_END:

                buffer_clear(global.socketBuffer)
                break;
                
                
            case ACK_REQUEST:

                newID = read_ushort(global.socketBuffer)
                lengthOfPacket = read_ushort(global.socketBuffer)
//                show_message("ClientBeginStep: PACKET_ID = "+string(newID)+"; Length = "+string(lengthOfPacket))

                if newID > global.lastPacketID or (newID < 100 and global.lastPacketID > 31900)
                {
//                    show_message("ClientBeginStep: PACKET_ID = "+string(newID)+" > "+string(global.lastPacketID)+"; length="+string(lengthOfPacket))
                    global.lastPacketID = newID
                }
                else// Old Packet; discard.
                {
//                    show_message("Discarding; "+string(lengthOfPacket))
                    var position;
                    position = buffer_size(global.socketBuffer)-buffer_bytes_left(global.socketBuffer)
                    buffer_set_readpos(global.socketBuffer, position+lengthOfPacket)
                }
                
                write_ubyte(global.serverSocket, ACK)
                write_ushort(global.serverSocket, newID)
                udp_send(global.serverSocket, global.serverIP, global.serverPort)

                break;
        
            case FULL_UPDATE:
//                show_message("ClientBeginStep: FULL_UPDATE")
                deserializeState(FULL_UPDATE);
                break;
        
            case QUICK_UPDATE:
//                show_message("ClientBeginStep: QUICK_UPDATE")
                deserializeState(QUICK_UPDATE);
                global.serverFrame += 1;
                break;
             
            case CAPS_UPDATE:
//                show_message("ClientBeginStep: CAPS_UPDATE")
                deserializeState(CAPS_UPDATE);
                break;
                  
            case INPUTSTATE:
//                show_message("ClientBeginStep: INPUTSTATE")
                deserializeState(INPUTSTATE);
                global.serverFrame += 1;
                break;
        
            case PLAYER_JOIN:
                player = instance_create(0,0,Player);
                player.name = receivestring(global.socketBuffer);
                
                ds_list_add(global.players, player);
                if(ds_list_size(global.players)-1 == global.playerID) {
//                    show_message("Added player to global.myself")
                    global.myself = player;
//                    show_message("global.myself.team = "+string(global.myself.team))
                    playerControl = instance_create(0,0,PlayerControl);
                }
//                show_message("ClientBeginStep: PLAYER_JOIN: "+string(ds_list_size(global.players)))
                break;
            
            case PLAYER_LEAVE:
                // Delete player from the game, adjust own ID accordingly
                playerID = read_ubyte(global.socketBuffer);
                player = ds_list_find_value(global.players, playerID);
                removePlayer(player);
                if(playerID < global.playerID) {
                    global.playerID -= 1;
                }
                break;
                                   
            case PLAYER_DEATH:
                var causeOfDeath, assistantPlayerID, assistantPlayer;
                playerID = read_ubyte(global.socketBuffer);
                otherPlayerID = read_ubyte(global.socketBuffer);
                assistantPlayerID = read_ubyte(global.socketBuffer);
                causeOfDeath = read_ubyte(global.socketBuffer);
                  
                player = ds_list_find_value(global.players, playerID);
            
                otherPlayer = noone;
                if(otherPlayerID != 255)
                    otherPlayer = ds_list_find_value(global.players, otherPlayerID);
            
                assistantPlayer = noone;
                if(assistantPlayerID != 255)
                    assistantPlayer = ds_list_find_value(global.players, assistantPlayerID);
            
                doEventPlayerDeath(player, otherPlayer, assistantPlayer, causeOfDeath);
                break;
             
            case BALANCE:
                balanceplayer=read_ubyte(global.socketBuffer);
                      if balanceplayer == 255 {
                        if !instance_exists(Balancer) instance_create(x,y,Balancer);
                        with(Balancer) notice=0;
                      } else {
                        player = ds_list_find_value(global.players, balanceplayer);
                        if(player.object != -1) {
                    with(player.object) {
                        instance_destroy();
                    }
                    player.object = -1;
                  }
                  if(player.team==TEAM_RED) {
                            player.team = TEAM_BLUE;
                        } else {
                            player.team = TEAM_RED;
                        }
                        if !instance_exists(Balancer) instance_create(x,y,Balancer);
                        Balancer.name=player.name;
                        with (Balancer) notice=1;
                      }
                      break;
                  
            case PLAYER_CHANGETEAM:
//                show_message("ClientBeginStep: PLAYER_CHANGETEAM")
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                if(player.object != -1) {
                    with(player.object) {
                        instance_destroy();
                    }
                    player.object = -1;
                }
                player.team = read_ubyte(global.socketBuffer);
                break;
             
            case PLAYER_CHANGECLASS:
//                show_message("ClientBeginStep: PLAYER_CHANGECLASS")
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                if(player.object != -1) {
                    with(player.object) {
                        instance_destroy();
                    }
                    player.object = -1;
                }
                player.class = read_ubyte(global.socketBuffer);
                break;             
        
            case PLAYER_CHANGENAME:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                player.name = receivestring(global.socketBuffer);
                if player=global.myself {
                global.playerName=player.name
                }
                break;
                 
            case PLAYER_SPAWN:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                doEventSpawn(player, read_ubyte(global.socketBuffer), read_ubyte(global.socketBuffer));
//                show_message("Player Spawned")
                break;
              
            case CHAT_BUBBLE:
                var bubbleImage;
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                setChatBubble(player, read_ubyte(global.socketBuffer));
                break;
                 
            case BUILD_SENTRY:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                if player.sentry == -1 {
                  buildSentry(player);
                }
                break;
              
            case DESTROY_SENTRY:
                playerID = read_ubyte(global.socketBuffer);
                otherPlayerID = read_ubyte(global.socketBuffer);
                assistantPlayerID = read_ubyte(global.socketBuffer);
                causeOfDeath = read_ubyte(global.socketBuffer);
            
                player = ds_list_find_value(global.players, playerID);
                if(otherPlayerID == 255) {
                    doEventDestruction(player, -1, -1, causeOfDeath);
                } else {
                    otherPlayer = ds_list_find_value(global.players, otherPlayerID);
                    if (assistantPlayerID == 255) {
                       doEventDestruction(player, otherPlayer, -1, causeOfDeath);
                    } else {
                       assistantPlayer = ds_list_find_value(global.players, assistantPlayerID);
                       doEventDestruction(player, otherPlayer, assistantPlayer, causeOfDeath);
                    }
                }
                break;
                      
            case GRAB_INTEL:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                doEventGrabIntel(player);
                break;
      
            case SCORE_INTEL:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                doEventScoreIntel(player);
                break;
      
            case DROP_INTEL:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                if player.object != -1 {
                    with player.object event_user(5); 
                }
                break;
  
            case GENERATOR_DESTROY:
                team = read_ubyte(global.socketBuffer);
                doEventGeneratorDestroy(team);
                break;
      
            case UBER_CHARGED:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                doEventUberReady(player);
                break;
  
            case UBER:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                doEventUber(player);
                break;    
  
            case OMNOMNOMNOM:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                if(player.object != -1) {
                  with(player.object) {
                      omnomnomnom=true;
                      if(player.team == TEAM_RED) {
                          omnomnomnomindex=0;
                          omnomnomnomend=31;
                      } else if(player.team==TEAM_BLUE) {
                          omnomnomnomindex=32;
                          omnomnomnomend=63;
                      }
                      xscale=image_xscale; 
                  } 
                }
                break;
      
            case SCOPE_IN:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                if player.object != -1 {
                    with player.object {
                        zoomed = true;
                        runPower = 0.6;
                        jumpStrength = 6;
                    }
                }
                break;
            
            case SCOPE_OUT:
                player = ds_list_find_value(global.players, read_ubyte(global.socketBuffer));
                if player.object != -1 {
                    with player.object {
                        zoomed = false;
                        runPower = 0.9;
                        jumpStrength = 8;
                    }
                }
                break;
                                         
            case PASSWORD_REQUEST:             
                global.clientPassword = get_string("Enter Password:", "");
                write_ubyte(global.serverSocket, PASSWORD_SEND);
                write_ubyte(global.serverSocket, string_length(global.clientPassword));
                write_string(global.serverSocket, global.clientPassword);
                break;
       
            case PASSWORD_WRONG:                                    
                show_message("Incorrect Password.");
                global.clientPassword = "";
                with(all) if id != AudioControl.id instance_destroy();
                room_goto_fix(Lobby);
                exit;                  
                break;
              
            case KICK:
                reason = read_ubyte(global.socketBuffer)
                if reason == KICK_NAME kickReason = "Name Exploit";
                else if reason == KICK_PASSWORDCOUNT kickReason = "Timed out from not submitting a password";                                    
                show_message("You have been kicked from the server. "+kickReason+".");
                with(all) if id != AudioControl.id instance_destroy();
                room_goto_fix(Lobby);
                exit;                  
                break;
              
            case ARENA_ENDROUND:
                with ArenaHUD clientArenaEndRound();
                break;   
        
            case ARENA_RESTART:
                doEventArenaRestart();
                break;
            
            case ARENA_UNLOCKCP:
                doEventArenaUnlockCP();
                break;
            case KOTH_UNLOCKCP:
                doEventKothUnlockCP();
                break; 
                   
            case MAP_END:
                global.nextMap=receivestring(global.socketBuffer);
                global.winners=read_ubyte(global.socketBuffer);
                global.currentMapArea=read_ubyte(global.socketBuffer);
                if !instance_exists(ScoreTableController) instance_create(0,0,ScoreTableController);
                instance_create(0,0,WinBanner);
                break;

            case CHANGE_MAP:
                roomchange=true;
                global.currentMap = receivestring(global.socketBuffer);
                global.currentMapURL = receivestring(global.socketBuffer);
                global.currentMapMD5 = receivestring(global.socketBuffer);
                if(global.currentMapMD5 == "") { // if this is an internal map (signified by the lack of an md5)
                    if(gotoInternalMapRoom(global.currentMap) != 0) {
                        show_message("Error:#Server went to invalid internal map: " + global.currentMap + "#Exiting.");
                        game_end();
                    }
                } else { // it's an external map
                    CustomMapDownload();
                }
                 
                for(i=0; i<ds_list_size(global.players); i+=1) {
                    player = ds_list_find_value(global.players, i);
                    if global.currentMapArea == 1 { 
                        player.stats[KILLS] = 0;
                        player.stats[DEATHS] = 0;
                        player.stats[CAPS] = 0;
                        player.stats[ASSISTS] = 0;
                        player.stats[DESTRUCTION] = 0;
                        player.stats[STABS] = 0;
                        player.stats[HEALING] = 0;
                        player.stats[DEFENSES] = 0;
                        player.stats[INVULNS] = 0;
                        player.stats[BONUS] = 0;
                        player.stats[DOMINATIONS] = 0;
                        player.stats[REVENGE] = 0;
                        player.stats[POINTS] = 0;
                        player.roundStats[KILLS] = 0;
                        player.roundStats[DEATHS] = 0;
                        player.roundStats[CAPS] = 0;
                        player.roundStats[ASSISTS] = 0;
                        player.roundStats[DESTRUCTION] = 0;
                        player.roundStats[STABS] = 0;
                        player.roundStats[HEALING] = 0;
                        player.roundStats[DEFENSES] = 0;
                        player.roundStats[INVULNS] = 0;
                        player.roundStats[BONUS] = 0;
                        player.roundStats[DOMINATIONS] = 0;
                        player.roundStats[REVENGE] = 0;
                        player.roundStats[POINTS] = 0;
                        player.team = TEAM_SPECTATOR;
                    }
                }
                break;
        
            case SERVER_FULL:
                show_message("The server is full.");
                instance_destroy();
                exit;

            default:
                show_message("The Server sent unexpected data");
                game_end();
                exit; 
        }
    }
    if !receivedInfo{
        if connectionTimer < 0
        {
            buffer_clear(global.sendBuffer);
            ClientPlayerJoin(global.playerName);
            write_buffer(global.serverSocket, global.sendBuffer);
            udp_send(global.serverSocket, global.serverIP, global.serverPort);
        }
        else if connectionTimer > 30*5
        {
            show_message("You have been disconnected from the server.");
            with(all) if id != AudioControl.id instance_destroy();
            room_goto_fix(Menu);
            exit;
        }
        else
        {
            connectionTimer += 1
        }
    }
    else
    {
        connectionTimer = 0
    }
}

buffer_clear(global.socketBuffer)
global.clientFrame += 1;
