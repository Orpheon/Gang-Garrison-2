while true
{
    receivedInfo = udp_receive(global.socketAcceptor)

    if receivedInfo
    {
        ip = socket_remote_ip(global.socketAcceptor)
    
        foundPlayer = 0
        for (a=0; a<ds_list_size(global.players); a+=1)
        {
            player = ds_list_find_value(global.players, a)
        
            if player.ip == ip
            {
                playerId = a
                foundPlayer = 1
                break;
            }
        }
        if !foundPlayer
        {
            if read_ubyte(global.socketAcceptor) == PLAYER_JOIN
            {
                acceptJoiningPlayer()
            }
            else
            {
                show_message("Invalid Player IP: "+string(ip))
                break;
            }
        }
        else
        {
            player.AfkTimer = 0
        }
    }
    else
    {
        break;
    }

    // replace socket with a buffer, and use buffer_read_pos

    global.receiveBuffer = buffer_create()
    write_buffer(global.receiveBuffer, global.socketAcceptor)

    while receivedInfo and buffer_bytes_left(global.receiveBuffer) > 0
    {
            switch(read_ubyte(global.receiveBuffer))
            {
            
            case ACK:
    
                packetID = read_ushort(global.receiveBuffer)
    
                var offset, index;
    
                if packetID > player.lastAckedIndex
                {
                    offset = 0
                }
                else if packetID < 100 and player.lastAckedIndex > 31900// The tag has looped. The numbers were decided on a whim.
                {
                    offset = 31999
                }
                else
                {
                    // Should ideally never happen; I'm not sure which reaction should follow. I chose "Ignore".
                    buffer_clear(global.receiveBuffer)
                    break;
                }
    
                // The ACK is actual and new. Update the player.ACKbuffer and delete the ACKed parts.
                var index, a;
                if player.lastAckedIndex != -1
                {
                    index = player.lastAckedIndex+1// Don't delete again what you just deleted last time
                }
                else
                {
                    index = packetID
                }
                a = 0
                while index <= packetID+offset
                {
                    if index > 31999
                    {
                        offset = 0
                        index = 0
                    }
    
                    for(e=0; e<global.eventBufferLengthArray[index]; e+=1)
                    {
                        read_ubyte(player.ACKbuffer)
                        a+=1
                    }
                    
                    index += 1
                }
                player.lastAckedIndex = packetID
                
    //            show_message("Player ACK received, "+string(a)+" bytes deleted.")
    
                tempBuffer = buffer_create()
                write_buffer_part(tempBuffer, player.ACKbuffer, buffer_size(player.ACKbuffer)+10)
                buffer_clear(player.ACKbuffer)
                write_buffer(player.ACKbuffer, tempBuffer)
                buffer_destroy(tempBuffer)
                break;
            
            
            case PLAYER_LEAVE:
                break;
                
            case PLAYER_CHANGECLASS:
                var class;
                class = read_ubyte(global.receiveBuffer);
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
                    ServerPlayerChangeclass(playerId, player.class, global.eventBuffer);
                }
                break;
            
            case PLAYER_CHANGETEAM:
                var newTeam, balance, redSuperiority;
                newTeam = read_ubyte(global.receiveBuffer);
            
                redSuperiority = 0   //calculate which team is bigger
                with(Player)
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
                        ServerPlayerChangeteam(playerId, player.team, global.eventBuffer);
                    }
                }
                break;                   
            
            case CHAT_BUBBLE:
    
                var bubbleImage;
                bubbleImage = read_ubyte(global.receiveBuffer);
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
            
                passwordLength = read_ubyte(global.receiveBuffer)
                password = read_string(global.receiveBuffer, passwordLength);
                if(global.serverPassword != password) {
                    //write_ubyte(player.ACKbuffer, PASSWORD_WRONG);
                    player.kick = 1
                } else {
                    player.authorized = true;
                }
                break;
            
            case PLAYER_CHANGENAME:
                var nameLength;
                nameLength = read_ubyte(global.receiveBuffer);
                if(nameLength > MAX_PLAYERNAME_LENGTH)
                {
                    //write_ubyte(player.ACKbuffer, KICK);
                    //write_ubyte(player.ACKbuffer, KICK_NAME);
                    player.kick = 1
                }
                else
                {
                    with(player)
                    {
                        if(variable_local_exists("lastNamechange")) 
                            if(current_time - lastNamechange < 1000)
                                break;
                        lastNamechange = current_time;
                        name = read_string(global.receiveBuffer, nameLength);
                        if(string_count("#",name) > 0)
                        {
                            name = "I <3 Bacon";
                        }
                        write_ubyte(global.eventBuffer, PLAYER_CHANGENAME);
                        write_ubyte(global.eventBuffer, other.playerId);
                        write_ubyte(global.eventBuffer, string_length(name));
                        write_string(global.eventBuffer, name);
                    }
                }
                break;
            
            case INPUTSTATE:
                if(player.object != -1 && player.authorized == true) {
                    with(player.object)
                    {
                        keyState = read_ubyte(global.receiveBuffer);
                        netAimDirection = read_ushort(global.receiveBuffer);
                        aimDirection = netAimDirection*360/65536;
                        event_user(1);
                    }
                } else if(player.authorized == false) { //disconnect them
                    player.kick = 1
                }
                break; 
            }
    }
    buffer_destroy(global.receiveBuffer)
}
