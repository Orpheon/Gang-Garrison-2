if !global.chatBoxOpen
{
    global.chatBoxOpen = 1
    keyboard_string = ""
}
else
{
    global.chatBoxOpen = 0
    if keyboard_string != ""
    {
        keyboard_string = string_copy(keyboard_string, 0, min(string_length(keyboard_string), 53))// Limit the message to 53 characters, to prevent huge spam.
    
        if ChatBox.public// If this was made on global chat
        {
            ClientSendPublicChatMessage(keyboard_string);
        }
        else
        {
            ClientSendChatMessage(keyboard_string)
        }
    }
    
    ChatBox.public = 0
    keyboard_string = ""
    
    socket_send(global.serverSocket);
}
