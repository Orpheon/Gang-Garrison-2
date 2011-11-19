var player, playerId, commandLimitRemaining;

player = argument0;
playerId = argument1;

// To prevent players from flooding the server, limit the number of commands to process per step and player.
commandLimitRemaining = 10;

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
        case PLAYER_LEAVE:
            socket_destroy(player.socket);
            player.socket = -1;
            break;
            
        case PLAYER_CHANGECLASS:
            var class;
            class = read_ubyte(socket);
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
                class = getClasslimit(player.team, class);
                player.class = class;
                ServerPlayerChangeclass(playerId, player.class, global.sendBuffer);
            }
            break;
            
        case CHAT_JOIN:
        
            if player.muted
            {
                break
            }

            if ds_list_find_index(global.chatters, player) < 0 and global.chatMode > 0// Chat is enabled
            {
                ds_list_add(global.chatters, player);
            }
            else
            {
                break;
            }

            switch (player.team)
            {
                case TEAM_RED:
                    message = "r"+player.name+" has joined the chat";
                    buffer = global.redChatBuffer;
                    break;
                    
                case TEAM_BLUE:
                    message = "b"+player.name+" has joined the chat";
                    buffer = global.blueChatBuffer;
                    break;
            }
            
            if player.team == TEAM_SPECTATOR
            {
                if playerId == 0// The host
                {
                    message = "p"+player.name+" has joined the chat";
                    buffer = global.publicChatBuffer// The host will be alone anyways, no-one cares about this.
                }
                else if global.chatMode == 2// If global chat is enabled, let the spec get announced.
                {
                    message = "g"+player.name+" has joined the chat";
                    buffer = global.publicChatBuffer;
                }
                else break;
            }
            else if global.myself.team == TEAM_SPECTATOR or global.myself.team == player.team// For the host.
            {
                printChat(message);
            }
            
            write_ubyte(buffer, CHAT_JOIN);
            write_ubyte(buffer, playerId);
            break;
            
        case CHAT_MESSAGE_PUBLIC:
            var length, message;
            length = socket_receivebuffer_size(socket);
            message = read_string(socket, length);
            message = string_copy(message, 0, min(string_length(message), 53))// Limit the message to 53 characters, to prevent huge spam.
            
            if global.chatMode != 2
            {
                break;// If global chat is disabled
            }
            
            if player.chatJustSent// Uh-oh, the player sent something not long ago, ignore.
            {
                player.alarm[1] = 20;// Reset the alarm to really shut down not carefully timed spam.
                break;
            }
            else// Everything's in order.
            {
                player.chatJustSent = 1;// Prevent the player to send something again soon.
                player.alarm[1] = 20;// 20 is arbitrary. Change when necessary.
            }
            
            if player.muted
            {
                break
            }
            
            switch (player.team)
            {
                case TEAM_RED:
                    message = "r"+player.name+": "+message;
                    break;
                    
                case TEAM_BLUE:
                    message = "b"+player.name+": "+message;
                    break;

                default:// spec
                    if playerId != 0
                    {
                        message = "g"+player.name+": "+message;
                    }
                    else
                    {
                        message = "p"+player.name+": "+message;
                    }
                    break
            }

            printChat(message);  
            write_ubyte(global.publicChatBuffer, CHAT_MESSAGE_PRIVATE);// The client doesn't care, and I have to code less.
            write_ubyte(global.publicChatBuffer, string_length(message));
            write_string(global.publicChatBuffer, message);
            break;
            
        case CHAT_MESSAGE_PRIVATE:        
            var length, message, buffer;
            
            length = socket_receivebuffer_size(socket);
            message = read_string(socket, length);
            message = string_copy(message, 0, min(string_length(message), 53))// Limit the message to 53 characters, to prevent huge spam.
            
            if global.chatMode == 0
            {
                break;// If chat is disabled
            }
            
            if player.chatJustSent// Uh-oh, the player sent something not long ago, ignore.
            {
                player.alarm[1] = 20;// Reset the alarm to really shut down not carefully timed spam.
                break;
            }
            else// Everything's in order.
            {
                player.chatJustSent = 1;// Prevent the player to send something again soon.
                player.alarm[1] = 20;// 20 is arbitrary. Change when necessary.
            }
            
            if player.muted
            {
                break
            }
            
            switch (player.team)
            {
                case TEAM_RED:
                    message = "r"+player.name+": "+message;
                    buffer = global.redChatBuffer;
                    break;
                    
                case TEAM_BLUE:
                    message = "b"+player.name+": "+message;
                    buffer = global.blueChatBuffer;
                    break;

             // Spec should not get chat, except the host, which comes later.
            }
            
            if player.team == TEAM_SPECTATOR
            {
                if playerId == 0// The host
                {
                    message = "p"+player.name+": "+message;

                    write_ubyte(global.redChatBuffer, CHAT_MESSAGE_PRIVATE);// Send to red and blue.
                    write_ubyte(global.redChatBuffer, string_length(message));
                    write_string(global.redChatBuffer, message);
                    
                    buffer = global.blueChatBuffer
                }
                else break;
            }
            if global.myself.team == TEAM_SPECTATOR or global.myself.team == player.team// For the host.
            {
                printChat(message);
            }
            
            write_ubyte(buffer, CHAT_MESSAGE_PRIVATE);
            write_ubyte(buffer, string_length(message));
            write_string(buffer, message);
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

                    if player.team != TEAM_SPECTATOR and ds_list_find_index(global.chatters, player) >= 0 and player.team != newTeam
                    {
                        switch (player.team)
                        {
                            case TEAM_RED:
                                write_ubyte(global.redChatBuffer, CHAT_LEAVE);
                                write_ubyte(global.redChatBuffer, playerId);
                                if player.team == global.myself.team or global.myself.team == TEAM_SPECTATOR or global.chatMode == 2
                                {
                                    printChat("r"+player.name+" has left the chat");
                                }
                                break;
                                
                            case TEAM_BLUE:
                                write_ubyte(global.blueChatBuffer, CHAT_LEAVE);
                                write_ubyte(global.blueChatBuffer, playerId);
                                if player.team == global.myself.team or global.myself.team == TEAM_SPECTATOR or global.chatMode == 2
                                {
                                    printChat("b"+player.name+" has left the chat");
                                }
                                break;
                        }
                    }      

                    var class;
                    class = getClasslimit(newTeam, player.class)
                    if class != player.class
                    {
                        player.class = class
                        ServerPlayerChangeclass(playerId, player.class, global.sendBuffer)
                    }

                    player.team = newTeam;
                    
                    if ds_list_find_index(global.chatters, player) >= 0
                    {
                        switch (player.team)
                        {
                            case TEAM_RED:
                                write_ubyte(global.redChatBuffer, CHAT_JOIN);
                                write_ubyte(global.redChatBuffer, playerId);
                                if player.team == global.myself.team or global.myself.team == TEAM_SPECTATOR or global.chatMode == 2
                                {
                                    printChat("r"+player.name+" has joined the chat");
                                }
                                break;
                                
                            case TEAM_BLUE:
                                write_ubyte(global.blueChatBuffer, CHAT_JOIN);
                                write_ubyte(global.blueChatBuffer, playerId);
                                if player.team == global.myself.team or global.myself.team == TEAM_SPECTATOR or global.chatMode == 2
                                {
                                    printChat("b"+player.name+" has joined the chat");
                                }
                                break;
                        }
                    }
                    
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

        case TOGGLE_ZOOM:
            if player.object != -1 {
                if player.class == CLASS_SNIPER {
                    write_ubyte(global.sendBuffer, TOGGLE_ZOOM);
                    write_ubyte(global.sendBuffer, playerId);
                    toggleZoom(player.object);
                }
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
                    
                    write_ubyte(global.sendBuffer, PLAYER_CHANGENAME);
                    write_ubyte(global.sendBuffer, playerId);
                    write_ubyte(global.sendBuffer, string_length(name));
                    write_string(global.sendBuffer, name);
                }
            }
            break;
            
        case INPUTSTATE:
            if(player.object != -1)
            {
                with(player.object)
                {
                    keyState = read_ubyte(socket);
                    netAimDirection = read_ushort(socket);
                    aimDirection = netAimDirection*360/65536;
                    event_user(1);
                }
            }
            break;

        case I_AM_A_HAXXY_WINNER:
            write_ubyte(socket, HAXXY_CHALLENGE_CODE);
            player.challenge = "";
            repeat(16)
                player.challenge += chr(irandom_range(1,255));
            write_string(socket, player.challenge);
            break;
            
        case HAXXY_CHALLENGE_RESPONSE:
            var answer, i;
            answer = "";
            for(i=1;i<=16;i+=1)
                answer += chr(read_ubyte(socket) ^ ord(string_char_at(player.challenge, i)));
            if(HAXXY_PUBLIC_KEY==md5(answer)) {
                player.isHaxxyWinner = true;
            } else {
                socket_destroy_abortive(player.socket);
                player.socket = -1;
            }
            break;
        }
        break;
    } 
}
