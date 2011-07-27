var player, playerId, commandLimitRemaining;

player = argument0;
playerId = argument1;

// To prevent players from flooding the server, limit the number of commands to process per step and player.
commandLimitRemaining = 10;

if player.team != TEAM_SPECTATOR and player.class != getClass(player.class)
{
    player.class = getClass(player.team, player.class)
    ServerPlayerChangeclass(playerId, player.class, global.sendBuffer);
}

with(player) {
    if(!variable_local_exists("commandReceiveState")) {
        // 0: waiting for command byte.
        // 1: waiting for command data length (1 byte)
        // 2: waiting for command data.
        commandReceiveState = 0;
        commandReceiveExpectedBytes = 1;
        commandReceiveCommand = 0;
    }
}

while(commandLimitRemaining > 0) {
    var socket;
    socket = player.socket;
    if(!tcp_receive(socket, player.commandReceiveExpectedBytes)) {
        return 0;
    }
    
    switch(player.commandReceiveState)
    {
    case 0:
        player.commandReceiveCommand = read_ubyte(socket);
        switch(commandBytes[player.commandReceiveCommand]) {
        case commandBytesInvalidCommand:
            // Invalid byte received. Wait for another command byte.
            break;
            
        case commandBytesPrefixLength1:
            player.commandReceiveState = 1;
            player.commandReceiveExpectedBytes = 1;
            break;
            
        default:
            player.commandReceiveState = 2;
            player.commandReceiveExpectedBytes = commandBytes[player.commandReceiveCommand];
            break;
        }
        break;
        
    case 1:
        player.commandReceiveState = 2;
        player.commandReceiveExpectedBytes = read_ubyte(socket);
        break;
        
    case 2:
        player.commandReceiveState = 0;
        player.commandReceiveExpectedBytes = 1;
        commandLimitRemaining -= 1;
        
        switch(player.commandReceiveCommand)
        {

        case OHU_HELLO:
            player.isOHU = 1
            break;

        case OHU_CHAT_JOIN:
            ds_list_add(global.chatters, player)

            if player.team = TEAM_RED
            {
                write_ubyte(global.chatBufferRed, OHU_CHAT_JOIN)
                write_ubyte(global.chatBufferRed, playerId)// I'm letting the clients reconstruct their own string as it doesn't create as much lag.
                print("/r"+player.name+" has joined the chat")// The /r is a color tag.Yes, clients can do this manually. This is printed here for the server.
            }
            else if player.team == TEAM_BLUE
            {
                write_ubyte(global.chatBufferBlue, OHU_CHAT_JOIN)
                write_ubyte(global.chatBufferBlue, playerId)
                print("/b"+player.name+" has joined the chat")

            }
            else if player.team == TEAM_SPECTATOR
            {
                write_ubyte(global.chatBufferSpectator, OHU_CHAT_JOIN)
                write_ubyte(global.chatBufferSpectator, playerId)
                print("/g"+player.name+" has joined the chat")
            }
            break;

        case OHU_CHAT_LEAVE:
            ds_list_delete(global.chatters, ds_list_find_index(global.chatters, player))

            if player.team = TEAM_RED
            {
                write_ubyte(global.chatBufferRed, OHU_CHAT_LEAVE)
                write_ubyte(global.chatBufferRed, playerId)// I'm letting the clients reconstruct their own string as it doesn't create as much lag.
                print("/r"+player.name+" has left the chat")
            }
            else if player.team == TEAM_BLUE
            {
                write_ubyte(global.chatBufferBlue, OHU_CHAT_LEAVE)
                write_ubyte(global.chatBufferBlue, playerId)
                print("/b"+player.name+" has left the chat")
            }
            else if player.team == TEAM_SPECTATOR
            {
                write_ubyte(global.chatBufferSpectator, OHU_CHAT_LEAVE)
                write_ubyte(global.chatBufferSpectator, playerId)
                print("/g"+player.name+" has left the chat")
            }

            break;

        case OHU_CHAT:
            length = socket_receivebuffer_size(socket);
            chatString = read_string(socket, length)

            if playerId == 0// If the host is talking:
            {
                ServerSendChatString(global.chatBufferRed, playerId, "/v"+chatString)
                ServerSendChatString(global.chatBufferBlue, playerId, "/v"+chatString)
                ServerSendChatString(global.chatBufferSpectator, playerId, "/v"+chatString)
                print("/v"+player.name+": "+chatString)
            }
            else if player.team = TEAM_RED
            {
                ServerSendChatString(global.chatBufferRed, playerId, chatString)
                print("/r"+player.name+": "+chatString)
            }
            else if player.team == TEAM_BLUE
            {
                ServerSendChatString(global.chatBufferBlue, playerId, chatString)
                print("/b"+player.name+": "+chatString)
            }
            else if player.team == TEAM_SPECTATOR
            {
                write_ubyte(global.chatBufferSpectator, OHU_CHAT_LEAVE)
                write_ubyte(global.chatBufferSpectator, playerId)
                print("/g"+player.name+": "+chatString)
            }

            break;

        case OHU_CHAT_KICK:
            player_id = read_ubyte(socket)
            kick_player = ds_list_find_value(global.players, player_id)

            if playerId != 0// The kicker isn't the host...
            {
                show_message("Someone has tried to abuse OHU and has tried to kick someone out of chat.#Kicking.")
                string_array[1] = player.name// This is used by the kicking script, it's noramlly the first arg you type.
                execute_string(ds_list_find_value(global.executionList, ds_list_find_index(global.commandList, "kick")))
            }
            else
            {            
                ds_list_delete(global.chatters, ds_list_find_index(global.chatters, player))
            
                if kick_player.team = TEAM_RED
                {
                    write_ubyte(global.chatBufferRed, OHU_CHAT_KICK)
                    write_ubyte(global.chatBufferRed, player_id)// I'm letting the clients reconstruct their own string as it doesn't create as much lag.
                }
                else if kick_player.team == TEAM_BLUE
                {
                    write_ubyte(global.chatBufferBlue, OHU_CHAT_KICK)
                    write_ubyte(global.chatBufferBlue, player_id)
                }
                else if kick_player.team == TEAM_SPECTATOR
                {
                    write_ubyte(global.chatBufferSpectator, OHU_CHAT_KICK)
                    write_ubyte(global.chatBufferSpectator, player_id)
                }
            }
            print("You have successfully kicked "+ds_list_find_value(global.players, player_id).name)
            break;

        case PLAYER_LEAVE:
            socket_destroy(player.socket);
            player.socket = -1;
            break;

        case PLAYER_CHANGECLASS:
            var class;
            class = read_ubyte(socket);
            team = player.team
            if(getCharacterObject(player.team, class) != -1)
            {
                if(player.object != -1)
                {
                    with(player.object)
                    {
                        if (collision_point(x,y,SpawnRoom,0,0) < 0)
                        {
                            if (lastDamageDealer == -1 || lastDamageDealer == player)
                            {
                                sendEventPlayerDeath(player, player, noone, BID_FAREWELL);
                                doEventPlayerDeath(player, player, noone, BID_FAREWELL);
                            }
                            else
                            {
                                var assistant;
                                assistant = secondToLastDamageDealer;
                                if (lastDamageDealer.object != -1)
                                    if (lastDamageDealer.object.healer != -1)
                                        assistant = lastDamageDealer.object.healer;
                                sendEventPlayerDeath(player, lastDamageDealer, assistant, FINISHED_OFF);
                                doEventPlayerDeath(player, lastDamageDealer, assistant, FINISHED_OFF);
                            }
                        }
                        else
                            instance_destroy();
                    }
                }
                else if(player.alarm[5]<=0)
                    player.alarm[5] = 1;
                player.class = class;
                ServerPlayerChangeclass(playerId, player.class, global.sendBuffer);
            }
            break;

        case PLAYER_CHANGETEAM:
            var newTeam, balance, redSuperiority;
            newTeam = read_ubyte(socket);
            
            redSuperiority = 0   //calculate which team is bigger
            with(Player)
            {
                if(team == TEAM_RED)
                    redSuperiority += 1;
                else if(team == TEAM_BLUE)
                    redSuperiority -= 1;
            }
            with(BotPlayer)
            {
                if(team == TEAM_RED)
                    redSuperiority += 1;
                else if(team == TEAM_BLUE)
                    redSuperiority -= 1;
            }
            if(redSuperiority > 0)
                balance = TEAM_RED;
            else if(redSuperiority < 0)
                balance = TEAM_BLUE;
            else
                balance = -1;
            
            if(balance != newTeam)
            {
                if(getCharacterObject(newTeam, player.class) != -1 or newTeam==TEAM_SPECTATOR)
                {  
                    if(player.object != -1)
                    {
                        with(player.object)
                        {
                            if (lastDamageDealer == -1 || lastDamageDealer == player)
                            {
                                sendEventPlayerDeath(player, player, noone, BID_FAREWELL);
                                doEventPlayerDeath(player, player, noone, BID_FAREWELL);
                            }
                            else
                            {
                                var assistant;
                                assistant = secondToLastDamageDealer;
                                if (lastDamageDealer.object != -1)
                                    if (lastDamageDealer.object.healer != -1)
                                        assistant = lastDamageDealer.object.healer;
                                sendEventPlayerDeath(player, lastDamageDealer, assistant, FINISHED_OFF);
                                doEventPlayerDeath(player, lastDamageDealer, assistant, FINISHED_OFF);
                            }
                        }
                        player.alarm[5] = global.Server_Respawntime;
                    }
                    else if(player.alarm[5]<=0)
                        player.alarm[5] = 1;
                    player.team = newTeam;
                    ServerPlayerChangeteam(playerId, player.team, global.sendBuffer);
                }
            }
            break;                   
            
        case CHAT_BUBBLE:
            var bubbleImage;
            bubbleImage = read_ubyte(socket);
            if(global.aFirst) {
                bubbleImage = 0;
            }
            write_ubyte(global.sendBuffer, CHAT_BUBBLE);
            write_ubyte(global.sendBuffer, playerId);
            write_ubyte(global.sendBuffer, bubbleImage);
            
            setChatBubble(player, bubbleImage);
            break;
            
        case BUILD_SENTRY:
            if(player.object != -1)
            {
                if(player.class == CLASS_ENGINEER
                and collision_circle(player.object.x, player.object.y, 50, Sentry, false, true) < 0
                and player.object.nutsNBolts == 100 and (collision_point(player.object.x,player.object.y,SpawnRoom,0,0) < 0)
                and player.sentry == -1 and !player.object.onCabinet)
                {
                    buildSentry(player);
                    write_ubyte(global.sendBuffer, BUILD_SENTRY);
                    write_ubyte(global.sendBuffer, playerId);
                }
            }
            break;                                       

        case DESTROY_SENTRY:
            if(player.sentry != -1) {
                with(player.sentry) {
                    instance_destroy();
                }
            }
            player.sentry = -1;
            break;                     
        
        case DROP_INTEL:                                                                  
            if(player.object != -1) {
                write_ubyte(global.sendBuffer, DROP_INTEL);
                write_ubyte(global.sendBuffer, playerId);
                with player.object event_user(5);  
            }
            break;     
              
        case OMNOMNOMNOM:
            if(player.object != -1) {
                if(player.humiliated == 0
                        && player.object.taunting==false
                        && player.object.omnomnomnom==false
                        && player.class==CLASS_HEAVY) {                            
                    write_ubyte(global.sendBuffer, OMNOMNOMNOM);
                    write_ubyte(global.sendBuffer, playerId);
                    with(player.object) {
                        omnomnomnom=true;
                        if player.team == TEAM_RED {
                            omnomnomnomindex=0;
                            omnomnomnomend=31;
                        } else if player.team==TEAM_BLUE {
                            omnomnomnomindex=32;
                            omnomnomnomend=63;
                        } 
                        xscale=image_xscale;
                    }             
                }
            }
            break;
             
        case SCOPE_IN:
             if player.object != -1 {
                if player.class == CLASS_SNIPER {
                   write_ubyte(global.sendBuffer, SCOPE_IN);
                   write_ubyte(global.sendBuffer, playerId);
                   with player.object {
                        zoomed = true;
                        runPower = 0.6;
                        jumpStrength = 6;
                   }
                }
             }
             break;
                
        case SCOPE_OUT:
             if player.object != -1 {
                if player.class == CLASS_SNIPER {
                   write_ubyte(global.sendBuffer, SCOPE_OUT);
                   write_ubyte(global.sendBuffer, playerId);
                   with player.object {
                        zoomed = false;
                        runPower = 0.9;
                        jumpStrength = 8;
                   }
                }
             }
             break;
                                                      
        case PASSWORD_SEND:
            password = read_string(socket, socket_receivebuffer_size(socket));
            if(global.serverPassword != password) {
                write_ubyte(player.socket, PASSWORD_WRONG);
                socket_destroy(player.socket);
                player.socket = -1;
            } else {
                player.authorized = true;
            }
            break;
            
        case PLAYER_CHANGENAME:
            var nameLength;
            nameLength = socket_receivebuffer_size(socket);
            if(nameLength > MAX_PLAYERNAME_LENGTH)
            {
                write_ubyte(player.socket, KICK);
                write_ubyte(player.socket, KICK_NAME);
                socket_destroy(player.socket);
                player.socket = -1;
            }
            else
            {
                with(player)
                {
                    if(variable_local_exists("lastNamechange")) 
                        if(current_time - lastNamechange < 1000)
                            break;
                    lastNamechange = current_time;
                    name = read_string(socket, nameLength);
                    if(string_count("#",name) > 0)
                    {
                        name = "I <3 Bacon";
                    }
                    if ds_list_find_index(global.chatters, player) >= 0// The player is part of the chat, gotta change the name there too.
                    {
                        ServerSendChatString(global.chatBuffer, player.name+" is now known as "+name)
                    }
                    write_ubyte(global.sendBuffer, PLAYER_CHANGENAME);
                    write_ubyte(global.sendBuffer, playerId);
                    write_ubyte(global.sendBuffer, string_length(name));
                    write_string(global.sendBuffer, name);
                }
            }
            break;
            
        case INPUTSTATE:
            if(player.object != -1 && player.authorized == true) {
                with(player.object)
                {
                    keyState = read_ubyte(socket);
                    netAimDirection = read_ushort(socket);
                    aimDirection = netAimDirection*360/65536;
                    event_user(1);
                }
            } else if(player.authorized == false) { //disconnect them
                socket_destroy_abortive(player.socket);
                player.socket = -1;
            }
            break; 
        }
        break;
    } 
}
