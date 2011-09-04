var socket, joiningPlayer, totalClientNumber;

        length = read_ubyte(global.socketAcceptor)
        name = read_string(global.socketAcceptor, length)
        
        var noOfPlayers;
        noOfPlayers = ds_list_size(global.players);
        if(global.dedicatedMode)
            noOfPlayers -= 1;
            
        if(noOfPlayers >= global.playerLimit) {
            write_ubyte(socket, SERVER_FULL);

        } else {
            player = instance_create(0,0,Player);

            player.ip = socket_remote_ip(global.socketAcceptor)
            player.port = socket_remote_port(global.socketAcceptor)

            player.name = name

            ds_list_add(global.players, player);

            newBuffer = buffer_create()
            ServerJoinUpdate(newBuffer);// This is reliable data, thus it has to be handed to the player.ACKbuffer and be handled like any other reliable information.

            global.frameCount += 1// This is to prevent eventBuffer length conflicts for different players without even more player variables.
            if global.frameCount > 31999
            {
                global.frameCount = 0
            }

            write_ubyte(player.ACKbuffer, ACK_REQUEST)
            write_ushort(player.ACKbuffer, global.frameCount)
            write_ushort(player.ACKbuffer, buffer_size(newBuffer))
            write_buffer(player.ACKbuffer, newBuffer)

            global.eventBufferLengthArray[global.frameCount] = buffer_size(newBuffer)+5// See end of GameServerBeginStep for details about this 5.

//            show_message("accept array length: "+string(global.eventBufferLengthArray[global.frameCount])+"; frame:"+string(global.frameCount))

            buffer_destroy(newBuffer)

            // sanitize player name
            player.name = string_copy(player.name, 0, MAX_PLAYERNAME_LENGTH);
            player.name = string_replace_all(player.name, "#", " ");

            global.frameCount += 1// This is to prevent eventBuffer length conflicts for different players without even more player variables.
            if global.frameCount > 31999
            {
                global.frameCount = 0
            }

            for (i=1; i<ds_list_size(global.players)-1; i+=1)// "-1" because the new player shouldn't receive this, he'll get himself inside the ServerJoinUpdate.
            {                                                //"i=1" because no need to save stuff in the server player buffer, it'll never get sent.
                oldPlayer = ds_list_find_value(global.players, i)
                
                // Fill in the missing bytes of that "frame" for all the players; gotta fix this someday
                for (a=0; a<global.eventBufferLengthArray[global.frameCount-1]; a+=1)
                {
                    write_ubyte(oldPlayer.ACKbuffer, IGNORE_MESSAGE)
                }
                
                write_ubyte(oldPlayer.ACKbuffer, ACK_REQUEST)
                write_ushort(oldPlayer.ACKbuffer, global.frameCount)
                write_ushort(oldPlayer.ACKbuffer, 2+string_length(player.name))
                ServerPlayerJoin(oldPlayer.name, oldPlayer.ACKbuffer);
            }
            global.eventBufferLengthArray[global.frameCount] = 7+string_length(player.name)// See end of GameServerBeginStep for details about this 5.
            
            
            // Because of the faulty architecture of the global.eventBufferLengthArray system, I need to make sure all players have the same amount of data in their buffers.
            // Hence an IGNORE_MESSAGE byte
            
            // This is for the newly joined player.
            for (i=0; i<global.eventBufferLengthArray[global.frameCount]; i+=1)
            {
                write_ubyte(player.ACKbuffer, IGNORE_MESSAGE)
            }
        }
