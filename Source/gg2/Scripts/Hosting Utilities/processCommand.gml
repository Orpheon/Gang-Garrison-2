//argument0 = user input

string_array[] = 0
i = 0

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


if Console.mode == "console"
{
    index = ds_list_find_index(global.commandList, string_array[0])
    if index >= 0
    {
        execute_string(ds_list_find_value(global.executionList, index))
    }
    else
    {
        print("Unknown Command. Type help for a small list, and be sure to read the Read-me.")
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
        else if string_array[0] == "/kick" and global.isHost
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
        ClientSendChatString(tempBuffer, string_array[0])
        write_buffer(global.serverSocket, tempBuffer)
        socket_send(global.serverSocket)
        buffer_destroy(tempBuffer)
    }
}
