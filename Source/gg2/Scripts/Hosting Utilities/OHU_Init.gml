global.botJoined[0] = false
global.ConsoleLog = ds_list_create();
global.ConsoleCmdLog = ds_list_create();
global.typing = false
global.mapChangeCommanded = 0

// Reading the Banlist:
if !file_exists("banlist.txt")
{
    text = file_text_open_write("banlist.txt")
    file_text_close(text)
}

text = file_text_open_read("banlist.txt")
banString = file_text_read_string(text)
file_text_close(text)
    
global.banlist = ds_list_create()
    
while string_count("sepChar", banString) > 0
{
    if string_copy(banString, 0, 1) != "s"
    {
        show_message("Error while parsing the banlist.#"+banString)
        game_end()
    }
    banString = string_copy(banString, 8, string_length(banString)-6)
    
    if string_count("sepChar", banString) > 0
    {
        nextIP = string_pos("sepChar", banString)
    }
    else
    {
        nextIP = string_length(banString)
    }
        
    ds_list_add(global.banlist, string_copy(banString, 0, nextIP-1))
    
    banString = string_copy(banString, nextIP, string_length(banString)-nextIP)
}


// All the built-in commands:
global.commandList = ds_list_create()
global.executionList = ds_list_create()

ds_list_add(global.commandList, "addBot")
ds_list_add(global.executionList,'
bot_team = string_array[1]
        
bot_class = string_array[2]
        
var i, player;
    
player = instance_create(0, 0, BotPlayer)

GetBotTeam(player)
    
GetBotClass(player)

player.name = "Tempest Bot "+string(global.bot_num+global.bot_offset);

if bot_team == "red"
{
    player.team = TEAM_RED
}
else if bot_team == "blue" or bot_team == "blu"
{
    player.team = TEAM_BLUE
}
else
{
    print("Unvalid Team. Please write either red, blue or random as the team argument.")
    exit;
}
        
if bot_class == "runner" or bot_class == "scout"
{
    player.class = CLASS_SCOUT
}
else if bot_class = "rocketman" or bot_class == "soldier"
{
    player.class = CLASS_SOLDIER
}
else if bot_class = "firebug" or bot_class == "pyro"
{
    player.class = CLASS_PYRO
}
else if bot_class = "overweight" or bot_class == "heavy"
{
    player.class = CLASS_HEAVY
}
else if bot_class = "detonator" or bot_class == "demoman"
{
    player.class = CLASS_DEMOMAN
}
else if bot_class = "healer" or bot_class == "medic"
{
    player.class = CLASS_MEDIC
}
else if bot_class = "constructor" or bot_class == "engineer"
{
    player.class = CLASS_ENGINEER
}
else if bot_class = "infiltrator" or bot_class == "spy"
{
    player.class = CLASS_SPY
}
else if bot_class = "rifleman" or bot_class == "sniper"
{
    player.class = CLASS_SNIPER
}
else
{
    print("Unvalid Class. Please write either the tf2 or the gg2 name in lowercase, eg. runner. Note that Healer, Detonator and Spy are deactivated.")
    exit;
}
    
global.bot_num_wished += 1

// This records everything the bot should be, and because bot_num_wished is higher, the next time GameServerBeginStep is called, a bot is added.
// For details, see CreateBot()
global.botJoined[0] = true
global.botJoined[1] = player.name
global.botJoined[2] = player.team
global.botJoined[3] = player.class
    
with player
{
    instance_destroy()
}
')

ds_list_add(global.commandList, "removeBot")
ds_list_add(global.executionList, '
global.bot_num_wished -= 1')

ds_list_add(global.commandList, "kick")
ds_list_add(global.executionList, '
foundPlayer = false
for (a=0; a<ds_list_size(global.players); a+=1)
{
    player = ds_list_find_value(global.players, a)
            
    if player.name == string_array[1] or player.name == string_lower(string_array[1]) or player.name == string_upper(string_array[1])
    {
        foundPlayer = true
        a = ds_list_size(global.players)+15
    }
}
        
if foundPlayer
{
    socket_destroy(player.socket)
}
else
{
    print("Could not find that player. Please try retyping the name.")
}')

ds_list_add(global.commandList, "ban")
ds_list_add(global.executionList, '
    foundPlayer = false
    for (a=0; a<ds_list_size(global.players); a+=1)
    {
        player = ds_list_find_value(global.players, a)
            
        if player.name == string_array[1] or player.name == string_lower(string_array[1]) or player.name == string_upper(string_array[1])
        {
            foundPlayer = true
            a = ds_list_size(global.players)+15
        }
    }
        
    if foundPlayer
    {
        ip = socket_remote_ip(player.socket)
            
        text = file_text_open_append("banlist.txt")
        file_text_write_string(text, "sepChar")
        file_text_write_string(text, string(ip))
        file_text_close(text)
                        
        socket_destroy(player.socket)
    }
    else
    {
        print("Could not find that player. Please try retyping the name.")
    }
')

ds_list_add(global.commandList, "ISeeSpies")// Just for laughs inc.
ds_list_add(global.executionList, '
{
    with Character cloak = 0
}')

ds_list_add(global.commandList, "showIP")
ds_list_add(global.executionList, '
    foundPlayer = false
    for (a=0; a<ds_list_size(global.players); a+=1)
    {
        player = ds_list_find_value(global.players, a)
            
        if player.name == string_array[1] or player.name == string_lower(string_array[1]) or player.name == string_upper(string_array[1])
        {
            foundPlayer = true
            a = ds_list_size(global.players)+15
        }
    }
        
    if foundPlayer
    {
        ip = socket_remote_ip(player.socket)
        print(string(ip))
    }
    else
    {
        print("Could not find that player. Please try retyping the name.")
    }
')

ds_list_add(global.commandList, "nextMap")
ds_list_add(global.executionList, "global.winners = 2")

ds_list_add(global.commandList, "changeMap")
ds_list_add(global.executionList, "global.winners = 2
global.currentMapArea = 1
global.nextMap = string_array[1]
global.mapChangeCommanded = 1")

loadPlugins()
