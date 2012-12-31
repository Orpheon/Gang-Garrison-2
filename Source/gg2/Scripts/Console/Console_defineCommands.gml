// This defines all the built-in commands

// input[1] = first argument, input[2] = second, etc...

Console_addCommand("help", "
if input[1] == ''
{
    var key;
    // User didn't ask any specific command, just give the general command list and infos.
    Console_print('GG2'+string(GAME_VERSION_STRING)+' console;');
    Console_print('');
    Console_print('Usage: Type in the wanted command followed by its arguments in this syntax:');
    Console_print('command arg1 arg2 arg3')
    Console_print('');
    Console_print('If an argument contains spaces, please surround it with '+chr(34)+' '+chr(34)+'.');
    Console_print('Some commands require Player IDs, the command listPlayers can show them to you.');
    Console_print('');
    Console_print('The current command list:');
    key = ds_map_find_first(global.commandMap);
    Console_print(key);
    for (i=0; i<ds_map_size(global.commandMap)-1; i+=1)
    {
        key = ds_map_find_next(global.commandMap, key);
        Console_print(key);
    }
    Console_print('')
    Console_print('For more details on each command, enter '+chr(34)+'help commandName'+chr(34)+'.')
    Console_print('----------------------------------------------------------------------------------');
}
else
{
    if ds_map_exists(global.documentationMap, input[1])
    {
        execute_string(ds_map_find_value(global.documentationMap, input[1]));
    }
    else
    {
        Console_print('No documentation could be found for that command.');
    }
}
", "
Console_print('Try entering help once, not twice.');
");


Console_addCommand("kick", "
// Check whether we are the host before anything else
if not global.isHost
{
    Console_print('Only the host can use this command.');
    exit;
}

var player;
// Check whether a name or a ID was given
if string_letters(input[1]) == ''
{
    // No letters were given
    // First check whether that ID is even valid
    if floor(real(string_digits(input[1]))) < ds_list_size(global.players) and floor(real(string_digits(input[1]))) > 0
    {
        // Valid ID, kick that player
        player = ds_list_find_value(global.players, floor(real(string_digits(input[1]))));
        with player
        {
            socket_destroy_abortive(socket);
            socket = -1;
        }
        Console_print(string_replace_all(player.name, '/:/', '/;/')+' has been kicked successfully.');
        exit;
    }
    else if floor(real(string_digits(input[1]))) == 0
    {
        // Can't kick yourself
        Console_print('The host cannot be kicked.');
    }
}
// If that system above did not work, try checking names
with Player
{
    if name == other.input[1]
    {
        // Don't kick the host
        if id == global.myself
        {
            Console_print('The host cannot be kicked.');
            continue;
        }
        // Found the name, kick that player
        socket_destroy_abortive(socket);
        socket = -1;
        Console_print(string_replace_all(name, '/:/', '/;/')+' has been kicked successfully.');
        exit;
    }
}
// We failed
Console_print('Could not find a player with that ID or name');

", "
Console_print('Syntax: kick playerID/playerName')
Console_print('Use: Kicks the designed player from the game, disconnecting him but not banning him.')
Console_print('Warning: IDs will be considered before names, so if a name of player x is equal to')
Console_print('         the ID of player y, player y will get kicked.')
Console_print('         Also, attempting to kick the host will have no effect.')");


Console_addCommand("ban", "
// Check whether we are the host before anything else
if not global.isHost
{
    Console_print('Only the host can use this command.');
    exit;
}

var player;
// Check whether a name or a ID was given
if string_letters(input[1]) == ''
{
    // No letters were given
    // First check whether that ID is even valid
    if floor(real(string_digits(input[1]))) < ds_list_size(global.players) and floor(real(string_digits(input[1]))) > 0
    {
        // Valid ID, ban that player
        player = ds_list_find_value(global.players, floor(real(string_digits(input[1]))));
        ds_list_add(global.banned_ips, socket_remote_ip(player.socket));
        with player
        {
            socket_destroy_abortive(socket);
            socket = -1;
        }
        // Write it now in a file
        var text, str, i;
        str = ''
        for (i=0; i<ds_list_size(global.banned_ips); i+=1)
        {
            // chr(10) == newline
            str += ds_list_find_value(global.banned_ips, i) + chr(10);
        }
        text = file_text_open_write('Banned ips.txt');
        file_text_write_string(text, str);
        file_text_close(text);
        
        Console_print(string_replace_all(player.name, '/:/', '/;/')+' has been banned successfully.');
        exit;
    }
    else if floor(real(string_digits(input[1]))) == 0
    {
        // Can't ban yourself
        Console_print('The host cannot be banned.');
    }
}
// If that system above did not work, try checking names
with Player
{
    if name == other.input[1]
    {
        // Don't ban the host
        if id == global.myself
        {
            Console_print('The host cannot be banned.');
            continue;
        }
        // Found the name, ban that player
        ds_list_add(global.banned_ips, socket_remote_ip(socket));
        socket_destroy_abortive(socket);
        socket = -1;
        
        // Write it now in a file
        var text, str, i;
        str = ''
        for (i=0; i<ds_list_size(global.banned_ips); i+=1)
        {
            // chr(10) == newline
            str += ds_list_find_value(global.banned_ips, i) + chr(10);
        }
        text = file_text_open_write('Banned ips.txt');
        file_text_write_string(text, str);
        file_text_close(text);
        
        Console_print(string_replace_all(name, '/:/', '/;/')+' has been banned successfully.');
        exit;
    }
}
// We failed
Console_print('Could not find a player with that ID or name');

", "
Console_print('Syntax: ban playerID/playerName')
Console_print('Use: Bans the designed player from the game, disconnecting him and preventing him from ever joining again.')
Console_print('Warning: IDs will be considered before names, so if a name of player x is equal to')
Console_print('         the ID of player y, player y will get kicked.')
Console_print('         Also, attempting to ban the host will have no effect.')
Console_print('You can unban a person by removing their ip from the banlist.')");


Console_addCommand("listPlayers", "
var redteam, blueteam, specteam, player;
redteam = ds_list_create();
blueteam = ds_list_create();
specteam = ds_list_create();

with Player
{
    if team == TEAM_RED
    {
        ds_list_add(redteam, id);
    }
    else if team == TEAM_BLUE
    {
        ds_list_add(blueteam, id);
    }
    else
    {
        ds_list_add(specteam, id);
    }
}

Console_print('')
Console_print('Current Player list:')

for (i=0; i<ds_list_size(redteam); i+=1)
{
    player = ds_list_find_value(redteam, i);
    if player.muted
    {
        Console_print('/:/'+COLOR_RED+string_replace_all(player.name, '/:/', '/;/')+':    ID='+string(ds_list_find_index(global.players, player.id))+'/:/'+COLOR_RED+'   |   MUTED');
    }
    else
    {
        Console_print('/:/'+COLOR_RED+string_replace_all(player.name, '/:/', '/;/')+':    ID='+string(ds_list_find_index(global.players, player.id)));
    }
}
for (i=0; i<ds_list_size(blueteam); i+=1)
{
    player = ds_list_find_value(blueteam, i);
    if player.muted
    {
        Console_print('/:/'+COLOR_BLUE+string_replace_all(player.name, '/:/', '/;/')+':    ID='+string(ds_list_find_index(global.players, player.id))+'/:/'+COLOR_RED+'   |   MUTED');
    }
    else
    {
        Console_print('/:/'+COLOR_BLUE+string_replace_all(player.name, '/:/', '/;/')+':    ID='+string(ds_list_find_index(global.players, player.id)));
    }
}
for (i=0; i<ds_list_size(specteam); i+=1)
{
    player = ds_list_find_value(specteam, i);
    if player.muted
    {
        Console_print('/:/'+COLOR_GREEN+string_replace_all(player.name, '/:/', '/;/')+':    ID='+string(ds_list_find_index(global.players, player.id))+'/:/'+COLOR_RED+'   |   MUTED');
    }
    else
    {
        Console_print('/:/'+COLOR_GREEN+string_replace_all(player.name, '/:/', '/;/')+':    ID='+string(ds_list_find_index(global.players, player.id)));
    }
}
", "
Console_print('Syntax: listPlayers')
Console_print('Use: Prints a color-coded list of the IDs of all the players in the game.')
Console_print('These IDs are necessary for anything requiring a specific player, like kicking.')");


Console_addCommand("clearScreen", "
with Console
{
    clearScreenTimer = 36// Makes text zoom up instead of just disappearing
}
", "
Console_print('Syntax: clearScreen')
Console_print('Use: Clears the console')");


Console_addCommand("broadcast", "
if not global.isHost
{
    Console_print('Only the host can use this command.');
    exit;
}

if input[1] != ''
{
    var message;
    message = input[1];
    if string_copy(message, 0, 1) == chr(34)
    {
        // Cut off starting and ending quotes
        message = string_copy(message, 2, string_length(message)-2);
    }
    message = string_copy(message, 0, 255);
    
    // Send it to everyone
    write_ubyte(global.eventBuffer, MESSAGE_STRING);
    write_ubyte(global.eventBuffer, string_length(message));
    write_string(global.eventBuffer, message);
    // Show it for the host as well
    var notice;
    with NoticeO instance_destroy();
    notice = instance_create(0, 0, NoticeO);
    notice.notice = NOTICE_CUSTOM;
    notice.message = message;
}
", "
Console_print('Syntax: broadcast '+chr(34)+'message to be sent'+chr(34));
Console_print('Use: Makes all clients receive a notification bearing the message');
Console_print('Warning: If spaces are in the message, remember to surround the message in double-quotes!');
");


Console_addCommand("execute", "
execute_string(input[1]);
", "
Console_print('Syntax: execute '+chr(34)+'<code>'+chr(34));
Console_print('Use: Executes the given code immediately.');
Console_print('Warning: Can cause crashes, use at own responsability!');
");


Console_addCommand("mute", "
// Check whether we are the host before anything else
if not global.isHost
{
    Console_print('Only the host can use this command.');
    exit;
}
var player;
// Check whether a name or a ID was given
if string_letters(input[1]) == ''
{
    // No letters were given
    // First check whether that ID is even valid
    if floor(real(string_digits(input[1]))) < ds_list_size(global.players) and floor(real(string_digits(input[1]))) >= 0
    {
        player = ds_list_find_value(global.players, floor(real(string_digits(input[1]))));
        // Valid ID, mute that player
        if player.muted
        {
            // If player was already muted
            Console_print(string_replace_all(player.name, '/:/', '/;/')+' is already muted!');
        }
        else
        {
            Console_print('Successfully muted '+string_replace_all(player.name, '/:/', '/;/'));
        }
        player.muted = true;
        // Notify the chat
        var message;
        message = '/:/'+COLOR_WHITE+string_replace_all(string_replace_all(player.name, '/:/', '/;/'), '/:/', '/;/')+' was muted';
        write_ubyte(global.publicChatBuffer, CHAT_PUBLIC_MESSAGE);
        write_ushort(global.publicChatBuffer, string_length(message));
        write_string(global.publicChatBuffer, message);
        print_to_chat(message);// For the host
        exit;
    }
}
// If that system above did not work, try checking names
with Player
{
    if name == other.input[1]
    {
        // Found the name, mute that player
        if muted
        {
            // If player was already muted
            Console_print(string_replace_all(name, '/:/', '/;/')+' is already muted!');
        }
        else
        {
            Console_print('Successfully muted '+string_replace_all(name, '/:/', '/;/'));
        }
        muted = true;
        // Notify the chat
        var message;
        message = '/:/'+COLOR_WHITE+string_replace_all(name, '/:/', '/;/')+' was muted';
        write_ubyte(global.publicChatBuffer, CHAT_PUBLIC_MESSAGE);
        write_ushort(global.publicChatBuffer, string_length(message));
        write_string(global.publicChatBuffer, message);
        print_to_chat(message);// For the host
        exit;
    }
}
// We failed
Console_print('Could not find a player with that ID or name');
", "
Console_print('Syntax: mute playerID/playerName');
Console_print('Use: Disallows chatting for that particular player.');
Console_print('Warning: IDs are considered before names.');
");


Console_addCommand("unmute", "
// Check whether we are the host before anything else
if not global.isHost
{
    Console_print('Only the host can use this command.');
    exit;
}
var player;
// Check whether a name or a ID was given
if string_letters(input[1]) == ''
{
    // No letters were given
    // First check whether that ID is even valid
    if floor(real(string_digits(input[1]))) < ds_list_size(global.players) and floor(real(string_digits(input[1]))) >= 0
    {
        player = ds_list_find_value(global.players, floor(real(string_digits(input[1]))));
    
        // Valid ID, unmute that player
        if not player.muted
        {
            // If player was not muted
            Console_print(string_replace_all(player.name, '/:/', '/;/')+' is not muted!');
        }
        else
        {
            Console_print('Successfully unmuted '+string_replace_all(player.name, '/:/', '/;/'));
        }
        player.muted = false;
        // Notify the chat
        var message;
        message = '/:/'+COLOR_WHITE+string_replace_all(string_replace_all(player.name, '/:/', '/;/'), '/:/', '/;/')+' was unmuted';
        write_ubyte(global.publicChatBuffer, CHAT_PUBLIC_MESSAGE);
        write_ushort(global.publicChatBuffer, string_length(message));
        write_string(global.publicChatBuffer, message);
        print_to_chat(message);// For the host
        exit;
    }
}
// If that system above did not work, try checking names
with Player
{
    if name == other.input[1]
    {
        // Found the name, unmute that player
        if not muted
        {
            // If player wasn't muted
            Console_print(string_replace_all(name, '/:/', '/;/')+' is not muted!');
        }
        else
        {
            Console_print('Successfully unmuted '+string_replace_all(name, '/:/', '/;/'));
        }
        muted = false;
        // Notify the chat
        var message;
        message = '/:/'+COLOR_WHITE+string_replace_all(name, '/:/', '/;/')+' was unmuted';
        write_ubyte(global.publicChatBuffer, CHAT_PUBLIC_MESSAGE);
        write_ushort(global.publicChatBuffer, string_length(message));
        write_string(global.publicChatBuffer, message);
        print_to_chat(message);// For the host
        exit;
    }
}
// We failed
Console_print('Could not find a player with that ID or name');
", "
Console_print('Syntax: unmute playerID/playerName');
Console_print('Use: Allows chatting for that particular player (By default enabled).');
Console_print('Warning: IDs are considered before names.');
");


Console_addCommand("ignore", "
var player;
// Check whether a name or a ID was given
if string_letters(input[1]) == ''
{
    // No letters were given
    // First check whether that ID is even valid
    if floor(real(string_digits(input[1]))) < ds_list_size(global.players) and floor(real(string_digits(input[1]))) >= 0
    {
        player = ds_list_find_value(global.players, floor(real(string_digits(input[1]))));
        // Valid ID, start ignoring that player
        if ds_list_find_index(global.ignore_list, player) < 0
        {
            ds_list_add(global.ignore_list, player);
            Console_print(string_replace_all(player.name, '/:/', '/;/')+' is now ignored.');
        }
        else
        {
            Console_print(string_replace_all(player.name, '/:/', '/;/')+' is already being ignored.');
        }
    }
}
// If that system above did not work, try checking names
with Player
{
    if name == other.input[1]
    {
        // Valid ID, start ignoring that player
        if ds_list_find_index(global.ignore_list, id) < 0
        {
            ds_list_add(global.ignore_list, id);
            Console_print(string_replace_all(name, '/:/', '/;/')+' is now ignored.');
        }
        else
        {
            Console_print(string_replace_all(name, '/:/', '/;/')+' is already being ignored.');
        }
    }
}
// We failed
Console_print('Could not find a player with that ID or name');
", "
Console_print('Syntax: ignore playerID/playerName');
Console_print('Use: Hides all chat messages (public and private) from that person');
Console_print('Warning: IDs are considered before names.');
");

Console_addCommand("unignore", "
var player;
// Check whether a name or a ID was given
if string_letters(input[1]) == ''
{
    // No letters were given
    // First check whether that ID is even valid
    if floor(real(string_digits(input[1]))) < ds_list_size(global.players) and floor(real(string_digits(input[1]))) >= 0
    {
        player = ds_list_find_value(global.players, floor(real(string_digits(input[1]))));
        // Valid ID, stop ignoring that player
        if ds_list_find_index(global.ignore_list, player) >= 0
        {
            ds_list_delete(global.ignore_list, player);
            Console_print(string_replace_all(player.name, '/:/', '/;/')+' isn't ignored anymore.');
        }
        else
        {
            Console_print(string_replace_all(player.name, '/:/', '/;/')+' wasn't being ignored.');
        }
    }
}
// If that system above did not work, try checking names
with Player
{
    if name == other.input[1]
    {
        // Valid ID, stop ignoring that player
        if ds_list_find_index(global.ignore_list, id) >= 0
        {
            ds_list_delete(global.ignore_list, id);
            Console_print(string_replace_all(name, '/:/', '/;/')+' isn't ignored anymore.');
        }
        else
        {
            Console_print(string_replace_all(name, '/:/', '/;/')+' wasn't being ignored.');
        }
    }
}
// We failed
Console_print('Could not find a player with that ID or name');
", "
Console_print('Syntax: unignore playerID/playerName');
Console_print('Use: Makes all messages from that person visible again (reverts the ignore command).');
Console_print('Warning: IDs are considered before names.');
");
