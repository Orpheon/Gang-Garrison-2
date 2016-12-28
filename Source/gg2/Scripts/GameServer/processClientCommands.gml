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

        case commandBytesPrefixLength2:
            player.commandReceiveState = 3;
            player.commandReceiveExpectedBytes = 2;
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

    case 3:
        player.commandReceiveState = 2;
        player.commandReceiveExpectedBytes = read_ushort(socket);
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
            if instance_exists(ArenaHUD) and global.isLive==1{
                if ArenaHUD.roundStart == 0 && ArenaHUD.endCount == 0{
                    break;
                }
            }
            var class;
            class = read_ubyte(socket);
            if(getCharacterObject(player.team, class) != -1){
                if(player.object != -1){
                    with(player.object){
                        if (collision_point(x,y,SpawnRoom,0,0) < 0){
                            if (!instance_exists(lastDamageDealer) || lastDamageDealer == player){
                                sendEventPlayerDeath(player, player, noone, DAMAGE_SOURCE_BID_FAREWELL);
                                doEventPlayerDeath(player, player, noone, DAMAGE_SOURCE_BID_FAREWELL);
                            }else{
                                var assistant;
                                assistant = secondToLastDamageDealer;
                                if (lastDamageDealer.object){
                                    if (lastDamageDealer.object.healer){
                                        assistant = lastDamageDealer.object.healer;
                                    }
                                }
                                sendEventPlayerDeath(player, lastDamageDealer, assistant, DAMAGE_SOURCE_FINISHED_OFF);
                                doEventPlayerDeath(player, lastDamageDealer, assistant, DAMAGE_SOURCE_FINISHED_OFF);
                            }
                        }else
                        instance_destroy(); 
                    }
                }else if(player.alarm[5]<=0){
                    player.alarm[5] = 1;
                }
                class = checkClasslimits(player, player.team, class);
                player.class = class;
                ServerPlayerChangeclass(playerId, player.class, global.sendBuffer);
            }
            break;
            
        case PLAYER_CHANGETEAM:
            var newTeam, balance, redSuperiority;
            newTeam = read_ubyte(socket);
            
            if global.lockedTeams==1{
                break;
			}
            
            if global.maxPlayers!=-1{
                var redTeam,blueTeam;
                redTeam=0
                blueTeam=0
                for (i=0; i<ds_list_size(global.players); i+=1){
                    player=ds_list_find_value(global.players, i)
                    if player.team==TEAM_RED{
                        redTeam+=1
                    }else if player.team==TEAM_BLUE{
                        blueTeam+=1
                    }
                }
                if redTeam>=global.maxPlayers and newTeam==TEAM_RED{
                    exit;
                }
                if blueTeam>=global.maxPlayers and newTeam==TEAM_BLUE{
                    exit;
                }
            }
			
			// Invalid team was requested, treat it as a random team
			if(newTeam != TEAM_RED and newTeam != TEAM_BLUE and newTeam != TEAM_SPECTATOR)
				newTeam = TEAM_ANY;
            
            redSuperiority = 0   //calculate which team is bigger
            balance = -1;

            if(balance != newTeam)
            {
                if(getCharacterObject(newTeam, player.class) != -1 or newTeam==TEAM_SPECTATOR)
                {
                    if(player.object != -1)
                    {
                        with(player.object)
                        {
                            if (!instance_exists(lastDamageDealer) || lastDamageDealer == player)
                            {
                                sendEventPlayerDeath(player, player, noone, DAMAGE_SOURCE_BID_FAREWELL);
                                doEventPlayerDeath(player, player, noone, DAMAGE_SOURCE_BID_FAREWELL);
                            }
                            else
                            {
                                var assistant;
                                assistant = secondToLastDamageDealer;
                                if (lastDamageDealer.object)
                                    if (lastDamageDealer.object.healer)
                                        assistant = lastDamageDealer.object.healer;
                                sendEventPlayerDeath(player, lastDamageDealer, assistant, DAMAGE_SOURCE_FINISHED_OFF);
                                doEventPlayerDeath(player, lastDamageDealer, assistant, DAMAGE_SOURCE_FINISHED_OFF);
                            }
                        }
                        if global.isLive==1{
                            player.alarm[5] = global.Server_Respawntime / global.delta_factor
                        }
                    }else if(player.alarm[5]<=0){
                        player.alarm[5] = 1;
                    }
                    var newClass;
                    newClass = checkClasslimits(player, newTeam, player.class);
                    if newClass != player.class
                    {
                        player.class = newClass;
                        ServerPlayerChangeclass(playerId, player.class, global.sendBuffer);
                    }
                    player.team = newTeam;
                    ServerPlayerChangeteam(playerId, player.team, global.sendBuffer);
                    ServerBalanceTeams();
                }
            }
            break;
            
        case CHAT_BUBBLE:
            var bubbleImage;
            bubbleImage = read_ubyte(socket);
            if(global.aFirst and bubbleImage != 45){
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
                        and player.object.nutsNBolts == 100
                        and (collision_point(player.object.x,player.object.y,SpawnRoom,0,0) < 0)
                        and !player.sentry
                        and !player.object.onCabinet)
                {
                    write_ubyte(global.sendBuffer, BUILD_SENTRY);
                    write_ubyte(global.sendBuffer, playerId);
                    write_ushort(global.serializeBuffer, round(player.object.x*5));
                    write_ushort(global.serializeBuffer, round(player.object.y*5));
                    write_byte(global.serializeBuffer, player.object.image_xscale);
                    buildSentry(player, player.object.x, player.object.y, player.object.image_xscale);
                }
            }
            break;

        case DESTROY_SENTRY:
            with(player.sentry)
                instance_destroy();
            break;
        
        case DROP_INTEL:
            if (player.object != -1)
            {
                if (player.object.intel)
                {
                    sendEventDropIntel(player);
                    doEventDropIntel(player);
                }
            }
            break;
              
        case OMNOMNOMNOM:
            if(player.object != -1) {
                if(!player.humiliated
                    and !player.object.taunting
                    and !player.object.omnomnomnom
                    and player.object.canEat
                    and player.class==CLASS_HEAVY){
                    write_ubyte(global.sendBuffer, OMNOMNOMNOM);
                    write_ubyte(global.sendBuffer, playerId);
                    with(player.object)
                    {
                        omnomnomnom = true;
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
                    oldname=name
                    name = read_string(socket, nameLength);
                    
                    with(ModController){
                        event_user(0)
                    }
                    if global.chatPBF_4==1{
                        var message, color;
                        color = getPlayerColor(player, true);
                        message = global.chatPrintPrefix+color+c_filter(oldname)+" "+C_WHITE+"has changed their name to"+color+" "+c_filter(name)+C_WHITE+"."
                        write_ubyte(global.publicChatBuffer, CHAT_PUBLIC_MESSAGE);
                        write_ushort(global.publicChatBuffer, string_length(message));
                        write_string(global.publicChatBuffer, message);
                        write_byte(global.publicChatBuffer,-1)
                        print_to_chat(message);// For the host
                    }
                    
                    write_ubyte(global.sendBuffer, PLAYER_CHANGENAME);
                    write_ubyte(global.sendBuffer, playerId);
                    write_ubyte(global.sendBuffer, string_length(name));
                    write_string(global.sendBuffer, name);
                }
            }
            break;
            
        case INPUTSTATE:
            if(player.object != -1){
                with(player.object){
                    keyState = read_ubyte(socket);
                    netAimDirection = read_ushort(socket);
                    aimDirection = netAimDirection*360/65536;
                    aimDistance = read_ubyte(socket)*2;

                    event_user(1);
                }
            }
            break;
        
        case REWARD_REQUEST:
            player.rewardId = read_string(socket, socket_receivebuffer_size(socket));
            player.challenge = rewardCreateChallenge();
            
            write_ubyte(socket, REWARD_CHALLENGE_CODE);
            write_binstring(socket, player.challenge);
            break;
            
        case REWARD_CHALLENGE_RESPONSE:
            var answer, i, authbuffer;
            answer = read_binstring(socket, 16);
            
            with(player)
                if(variable_local_exists("challenge") and variable_local_exists("rewardId")){
                    rewardAuthStart(player, answer, challenge, true, rewardId);
                }
           
            break;

        case PLUGIN_PACKET:
            var packetID, buf, success;

            packetID = read_ubyte(socket);
            
            // get packet data
            buf = buffer_create();
            write_buffer_part(buf, socket, socket_receivebuffer_size(socket));

            // try to enqueue
            success = _PluginPacketPush(packetID, buf, player);
            
            // if it returned false, packetID was invalid
            if (!success)
            {
                // clear up buffer
                buffer_destroy(buf);

                // kick player
                write_ubyte(player.socket, KICK);
                write_ubyte(player.socket, KICK_BAD_PLUGIN_PACKET);
                socket_destroy(player.socket);
                player.socket = -1;
            }
            break;
            
        case CLIENT_SETTINGS:
            var mirror;
            mirror = read_ubyte(player.socket);
            player.queueJump = mirror;
            
            write_ubyte(global.sendBuffer, CLIENT_SETTINGS);
            write_ubyte(global.sendBuffer, playerId);
            write_ubyte(global.sendBuffer, mirror);
            break;
        
        case RCON_LOGIN:
            var rconCommand,commandLength;
            commandLength=socket_receivebuffer_size(player.socket)
            rconCommand=read_string(player.socket,commandLength)
            
            if global.RCONAllowed==0 break;
            
            if string(rconCommand)==string(global.RCONPassword){
                write_ubyte(player.socket,RCON_LOGIN)
                write_ubyte(player.socket,RCON_LOGIN_SUCCESSFUL) //valid password
                ds_list_add(global.RCONList,player)
                console_print(C_PINK+'RCON: '+player.name+' is now identified as a RCON.')
                var color;
                color=getPlayerColor(player, true);
                global.srvMsgChatPrint=global.chatPrintPrefix+color+c_filter(player.name)+C_WHITE+' is now a '+C_PINK+'RCON'+C_WHITE+'.'
                console_sendmsg()
            }else{
                write_ubyte(player.socket,RCON_LOGIN)
                write_ubyte(player.socket,RCON_LOGIN_FAILED) //invalid password
            }
            break;
        
        case RCON_COMMAND:
            var rconCommand,commandLength;
            commandLength=socket_receivebuffer_size(player.socket)
            rconCommand=read_string(player.socket,commandLength)
            
            if global.RCONAllowed==0 or ds_list_find_value(global.RCONList,ds_list_find_index(global.RCONList,player))!=player{
                write_ubyte(player.socket,RCON_COMMAND)
                write_ubyte(player.socket,RCON_COMMAND_FAILED)
                break;
            }
            
            if(string_length(rconCommand) > MAX_RCON_COMMAND_LENGTH){
                write_ubyte(player.socket, KICK)
                write_ubyte(player.socket, KICK_RCON)
                console_print(C_PINK+'RCON: '+player.name+' sent a command with a length over the maximum limit; kicking.')
                socket_destroy(player.socket);
                player.socket = -1;
                break;
            }
            
            console_parseInput_RCON(rconCommand,player.name)
            write_ubyte(player.socket,RCON_COMMAND)
            write_ubyte(player.socket,RCON_COMMAND_SUCESSFUL)
            break;
            
        case CHAT_PUBLIC_MESSAGE:
            var messageLength;
            messageLength = socket_receivebuffer_size(socket);
            if(messageLength > CHAT_MAX_STRING_LENGTH){
                write_ubyte(player.socket, KICK);
                write_ubyte(player.socket, KICK_NAME);
                socket_destroy(player.socket);
                player.socket = -1;
            }else{
                with(player){
                    //dont send messgaes from muted players
                    if ds_list_find_index(global.chatBanList,id)!=-1{
                        break;
                    }
                    if(current_time - lastChatTime < 500){
                        break;
                    }
                    lastChatTime = current_time;
                    
                    var message;
                    message = read_string(socket, messageLength);
                    // Prevent messing with the color code as well
                    if(string_count("/:/", message) > 0){
                        message = c_filter(message)
                    }
                    
                    message = parse_custom_color(message)
                    playerListID=ds_list_find_index(global.players,id)
                    
                    if string_char_at(message,0)=="!"{
                        var globalCommand;
                        globalCommand=string_delete(message,1,1)
                        chat_parseInputCommandSent(string(globalCommand), player)
                    }
                    
                    if object!=-1 and team!=TEAM_SPECTATOR{
                        with object{
                            sAfkTimer=sAfkTimeout
                        }
                    }
                    
                    var color, roleColour;
                    color = getPlayerColor(player, true);
                    
                    if isDerpduck==1{
                        roleColour=P_ORNGE
                    }else if ds_list_find_index(global.players, player)==0{
                        roleColour=P_YELLW
                    }else if ds_list_find_index(global.RCONList, player)!=-1{
                        roleColour=C_LPINK
                    }else{
                        roleColour=C_WHITE
                    }
                    
                    if team == TEAM_RED{
                        message = color + c_filter(name) + ": " + roleColour + message;
                    }else if team == TEAM_BLUE{
                        message = color + c_filter(name) + ": " + roleColour + message;
                    }else{
                        message = color + c_filter(name) + ": " + roleColour + message;
                    }
                    
                    write_ubyte(global.publicChatBuffer, CHAT_PUBLIC_MESSAGE);
                    write_ushort(global.publicChatBuffer, string_length(message));
                    write_string(global.publicChatBuffer, message);
                    write_byte(global.publicChatBuffer,playerListID);
                    
                    // For the host, who never receives stuff
                    if ds_list_find_index(global.clientChatBanList,permID)!=-1{
                        break;
                    }
                    print_to_chat(message);
                }
            }
            break;

        case CHAT_PRIV_MESSAGE:
            var messageLength;
            messageLength = socket_receivebuffer_size(socket);
            if(messageLength > CHAT_MAX_STRING_LENGTH){
                write_ubyte(player.socket, KICK);
                write_ubyte(player.socket, KICK_NAME);
                socket_destroy(player.socket);
                player.socket = -1;
            }else{
                with(player){
                    //dont send muted players messages
                    if ds_list_find_index(global.chatBanList,id)!=-1{
                        break;
                    }
                    if(current_time - lastChatTime < 500){
                        break;
                    }
                    lastChatTime = current_time;
                    var message, teambuffer;
                    message = read_string(socket, messageLength);
                    // Prevent messing with the color code as well
                    if(string_count("/:/", message) > 0){
                        message = c_filter(message)
                    }
                    
                    message = parse_custom_color(message)
                    playerListID=ds_list_find_index(global.players,id)
                    
                    if string_char_at(message,0)=="!"{
                        var globalCommand;
                        globalCommand=string_delete(message,1,1)
                        chat_parseInputCommandSent(string(globalCommand), player)
                    }
                    
                    if object!=-1 and team!=TEAM_SPECTATOR{
                        with object{
                            sAfkTimer=sAfkTimeout
                        }
                    }

                    var color;
                    color = getPlayerColor(player, false);
                    
                    if team == TEAM_RED{
                        teambuffer = global.privChatRedBuffer;
                        message = color + "(team) " + c_filter(name) + ": " + message;
                    }else if team == TEAM_BLUE{
                        teambuffer = global.privChatBlueBuffer;
                        message = color + "(team) " + c_filter(name) + ": " + message;
                    }else{
                        teambuffer = global.privChatSpecBuffer;
                        message = color + "(team) " + c_filter(name) + ": " + message;
                    }
                    write_ubyte(teambuffer, CHAT_PRIV_MESSAGE);
                    write_ushort(teambuffer, string_length(message));
                    write_string(teambuffer, message);
                    write_byte(teambuffer,playerListID);

                    // For the host, who never receives stuff
                    if global.myself.team == team or (global.myself.team==TEAM_SPECTATOR and global.specReadChat==1){
                        if ds_list_find_index(global.clientChatBanList,permID)!=-1{
                            break;
                        }
                        print_to_chat(message);
                    }
                }
            }
            break;
            
        case RUP_READY:
            with(player){
                if(current_time - lastChatTime < 800){
                    break;
                }
                lastChatTime=current_time;
                
                if team==TEAM_SPECTATOR{
                    break;
                }
                if object!=-1{
                    with object{
                        sAfkTimer=sAfkTimeout
                    }
                }
            }
            
            if global.canStart==0{
                break;
            }
            
            if ds_map_find_value(rupPlayers,player)==0{
                ds_map_replace(rupPlayers,player,1)
                
                with(ModController){
                    event_user(0)
                }
                if global.chatPBF_128==1{
                    var message,color;
                    color = getPlayerColor(player, true);
                    message = global.chatPrintPrefix+color+c_filter(player.name)+C_WHITE+" is ready."
                    write_ubyte(global.publicChatBuffer, CHAT_PUBLIC_MESSAGE);
                    write_ushort(global.publicChatBuffer, string_length(message));
                    write_string(global.publicChatBuffer, message);
                    write_byte(global.publicChatBuffer,-1)
                    print_to_chat(message);// For the host
                }
            }
            break;
            
        case RUP_UNREADY:
            with(player){
                if(current_time - lastChatTime < 800){
                    break;
                }
                lastChatTime=current_time;
                
                if team==TEAM_SPECTATOR{
                    break;
                }
                if object!=-1{
                    with object{
                        sAfkTimer=sAfkTimeout
                    }
                }
            }
            
            if global.canStart==0{
                break;
            }
            
            if ds_map_find_value(rupPlayers,player)==1{
                ds_map_replace(rupPlayers,player,0)
                
                with(ModController){
                    event_user(0)
                }
                if global.chatPBF_128==1{
                    var message,color;
                    color = getPlayerColor(player, true);
                    message = global.chatPrintPrefix+color+c_filter(player.name)+C_WHITE+" is no longer ready."
                    write_ubyte(global.publicChatBuffer, CHAT_PUBLIC_MESSAGE);
                    write_ushort(global.publicChatBuffer, string_length(message));
                    write_string(global.publicChatBuffer, message);
                    write_byte(global.publicChatBuffer,-1)
                    print_to_chat(message);// For the host
                }
            }
            break;
            
        case DC_REASON_USER:
            with(player){
                dcReason=DC_REASON_USER
            }
            break;
            
        case PLAYER_PING:
            if(player.object != -1){
                with(player.object){
                    playerPing=read_ushort(player.socket)
                }
            }
            break;
            
        //end of cases
        }
        break;
    } 
}
