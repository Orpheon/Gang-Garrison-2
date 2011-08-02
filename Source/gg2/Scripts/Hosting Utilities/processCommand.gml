//argument0 = user input

string_array[] = 0
i = 0

if string_copy(argument0, 0, 5) == "rcon " and global.myself.isRcon
{
    //Instead of unpacking everything, send to server.
    ClientSendRconString(global.serverSocket, string_copy(argument0, 6, string_length(argument0)-5))
    socket_send(global.serverSocket)
    exit;
}
else if string_copy(argument0, 0, 5) == "rcon "// and not rcon
{
    print("You are not a rcon, and are thus not permitted to execute this. Type 'rconPass -password' to access")
}

while argument0 != ""
{
    index = string_pos("-", argument0)
    if index != 0
    {
        string_array[i] = string_copy(argument0, 1, index-2)
        argument0 = string_delete(argument0, 1, index)
    }
    else
    {
        string_array[i] = argument0
        argument0 = ""
    }
    i += 1
}
// Fill up missing arguments, to prevent crashings.
string_array[i+1] = ""
string_array[i+2] = ""
string_array[i+3] = ""
string_array[i+4] = ""
string_array[i+5] = ""


if Console.mode == "console"
{
    index = ds_list_find_index(global.commandList, string_array[0])
    if index >= 0
    {
        execute_string(ds_list_find_value(global.executionList, index))
    }
    else
    {
        print("Unknown Command. Type help for a small list of commands, or see the complete list on the OHU thread.")
    }
}

else// Mode=Chat;
{
    if string_copy(string_array[0], 0, 1) == "/"
    {
        if string_array[0] == "/console" or string_array[0] == "/exit" or string_array[0] == "/quit"// If you want to leave the chat
        {
            write_ubyte(global.serverSocket, OHU_CHAT_LEAVE)
            socket_send(global.serverSocket)
            Console.mode = "console"
        }
        else if string_array[0] == "/kick" and (global.isHost or global.myself.isRcon == 1)
        {
            foundPlayer = 0
            for (w=0; w<ds_list_size(global.chatters); w+=1)
            {
                player = ds_list_find_value(global.chatters, w)
                if player.name == string_array[1]
                {
                    foundPlayer = 1
                    break;
                }
            }
            
            if foundPlayer
            {
                write_ubyte(global.serverSocket, OHU_CHAT_KICK)
                write_ubyte(global.serverSocket, ds_list_find_index(global.players, player))
                socket_send(global.serverSocket)
            }
            
            else
            {
                print("Could not find that player.")
            }
        }
    }
    else
    {
        tempBuffer = buffer_create()// I created my own buffer because that's simple and I don't want to interfere in something else.
        
        if string_length(string_array[0]+string_array[1]+string_array[2]+string_array[3]+string_array[4]) > 50
        {
            string_array[0] = string_copy(string_array[0]+string_array[1]+string_array[2]+string_array[3]+string_array[4], 0, 49)
            string_array[1] = ""
            string_array[2] = ""
            string_array[3] = ""
            string_array[4] = ""
            string_array[5] = ""
        }
        
        if publicChatEnabled
        {
            // Send to global chat
            ClientSendChatString(tempBuffer, string_array[0]+string_array[1]+string_array[2]+string_array[3]+string_array[4])
        }
        else
        {
            //Send to team-only chat
            write_ubyte(tempBuffer, OHU_CHAT_PRIVATE)
            write_ubyte(tempBuffer, string_length(string_array[0]+string_array[1]+string_array[2]+string_array[3]+string_array[4]))
            write_string(tempBuffer, string_array[0]+string_array[1]+string_array[2]+string_array[3]+string_array[4])
        }
        
        write_buffer(global.serverSocket, tempBuffer)
        socket_send(global.serverSocket)
        buffer_destroy(tempBuffer)
    }
}
