/*
All built-in console commands are defined here, big strings approaching.
*/


global.commandDict = ds_map_create();
global.documentationDict = ds_map_create();

ds_map_add(global.commandDict, "kick", "
var player;
player = findPlayer(input[1]);
if player != -1 and player != ds_list_find_value(global.players, 0)
{
    with player
    {
        socket_destroy_abortive(socket);
        socket = -1;
    }
    print(player.name+' has been kicked successfully.');
}
else
{
    print('Could not find a player with that ID.');
}")
ds_map_add(global.documentationDict, "kick", "
print('Syntax: kick playerID')
print('Use: Kicks the designed player from the game, disconnecting him but not banning him.')
print('Warning: Attempting to kick the host will have no effect.')");


ds_map_add(global.commandDict, "ban", "
var player, ip;
player = findPlayer(input[1]);
if player != -1 and player != ds_list_find_value(global.players, 0)
{
    with player
    {
        ip = socket_remote_ip(socket);
        ds_list_add(global.banlist, ip);
        socket_destroy_abortive(socket);
        socket = -1;
        print(player.name+' has been banned successfully.');
    }
}
else
{
    print('Could not find a player with that ID.');
}")
ds_map_add(global.documentationDict, "ban", "
print('Syntax: ban playerID')
print('Use: Bans the designed player from the game, disconnecting him and making it impossible for him to join later.')
print('Warning: Attempting to ban the host will have no effect.')
print('If you have not enabled persistent banning, all bans will be reset when gg2 is restarted.')
");


ds_map_add(global.commandDict, "listID", "
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

for (i=0; i<ds_list_size(redteam); i+=1)
{
    player = ds_list_find_value(redteam, i);
    print('/:/r'+player.name+':    ID='+string(player.ID)+'; IP='+string(socket_remote_ip(player.socket)));
}
for (i=0; i<ds_list_size(blueteam); i+=1)
{
    player = ds_list_find_value(blueteam, i);
    print('/:/b'+player.name+':    ID='+string(player.ID)+'; IP='+string(socket_remote_ip(player.socket)));
}
for (i=0; i<ds_list_size(specteam); i+=1)
{
    player = ds_list_find_value(specteam, i);
    print('/:/g'+player.name+':    ID='+string(player.ID)+'; IP='+string(socket_remote_ip(player.socket)));
}");
ds_map_add(global.documentationDict, "listID", "
print('Syntax: listID')
print('Use: Prints a color-coded list of the IDs of all the players in the game, as well as their IPs.')
print('These IDs are necessary for anything requiring a specific player, like kicking.')");


ds_map_add(global.commandDict, "help", "
if input[1] == ''
{
    var key;
    // User didn't ask any specific command, just give the general command list.
    print('----------------------------------------------------------------------------------');
    print('OHU'+string(GAME_VERSION_STRING)+' console;');
    print('');
    print('Usage: Type in the wanted command followed by its arguments in this syntax:');
    print('command arg1 arg2 arg3')
    print('');
    print('Some commands require Player IDs, the command listID can show them to you.')
    print('');
    print('The current command list:');
    key = ds_map_find_first(global.commandDict);
    print(key);
    for (i=0; i<ds_map_size(global.commandDict)-2; i+=1)
    {
        key = ds_map_find_next(global.commandDict, key);
        print(key);
    }
    print('')
    print('For more details on each command, enter |help commandName|.')
    print('Additional questions or requests should go to the OHU thread.')
    print('----------------------------------------------------------------------------------');
}
else
{
    if ds_map_exists(global.documentationDict, input[1])
    {
        execute_string(ds_map_find_value(global.documentationDict, input[1]));
    }
    else
    {
        print('No documentation could be found for that command.');
    }
}");


ds_map_add(global.commandDict, "clearScreen", "
ds_list_destroy(global.consoleLog)
global.consoleLog = ds_list_create();");
ds_map_add(global.commandDict, "clearScreen", "
print('Syntax: clearScreen')
print('Use: Clears the console')");


ds_map_add(global.commandDict, "setClasslimit", "
var chosenClass, noClassChosen;
noClassChosen = 0
switch string_lower(input[1])
{
    case 'scout':
        chosenClass = CLASS_SCOUT;
        break;
        
    case 'runner':
        chosenClass = CLASS_SCOUT;
        break;

    case 'soldier':
        chosenClass = CLASS_SOLDIER;
        break;
        
    case 'rocketman':
        chosenClass = CLASS_SOLDIER;
        break;
        
    case 'pyro':
        chosenClass = CLASS_PYRO;
        break;
    
    case 'firebug':
        chosenClass = CLASS_PYRO;
        break;
        
    case 'heavy':
        chosenClass = CLASS_HEAVY;
        break;
        
    case 'overweight':
        chosenClass = CLASS_HEAVY;
        break;
        
    case 'demoman':
        chosenClass = CLASS_DEMOMAN;
        break;
    
    case 'detonator':
        chosenClass = CLASS_DEMOMAN;
        break;
        
    case 'medic':
        chosenClass = CLASS_MEDIC;
        break;
        
    case 'healer':
        chosenClass = CLASS_MEDIC;
        break;
        
    case 'engineer':
        chosenClass = CLASS_ENGINEER;
        break;
        
    case 'constructor':
        chosenClass = CLASS_ENGINEER;
        break;
        
    case 'spy':
        chosenClass = CLASS_SPY;
        break;
        
    case 'infiltrator':
        chosenClass = CLASS_SPY;
        break;
        
    case 'sniper':
        chosenClass = CLASS_SNIPER;
        break;
        
    case 'rifleman':
        chosenClass = CLASS_SNIPER;
        break;
        
    case 'quote':
        chosenClass = CLASS_QUOTE;
        break;
        
    case 'curly':
        chosenClass = CLASS_QUOTE;
        break;
        
    case '':
        noClassChosen = 1;
        break;
        
    default:
        print('Could not find a class with that name.');
        exit;
}

if !noClassChosen
{
    if input[2] != 'off'
    {
        global.classlimits[chosenClass] = real(input[2])
    }
    else
    {
        global.classlimits[chosenClass] = global.playerLimit+15
    }

    var suggestedClass;

    with Player
    {
        if class == chosenClass
        {
            suggestedClass = getClasslimit(team, class);
            if suggestedClass != class// Class has been switched, send that to everyone
            {
                if(object != -1)
                {
                    with(object)
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
                else if(alarm[5]<=0)
                {
                    alarm[5] = 1;
                }
                    
                class = suggestedClass

                ServerPlayerChangeclass(ds_list_find_index(global.players, id), class, global.sendBuffer);
            }
        }
    }
}
print('Current classlimits:')

if global.classlimits[CLASS_SCOUT] >= global.playerLimit print(' Scout: Off');
else print(' Scout: '+string(global.classlimits[CLASS_SCOUT]));

if global.classlimits[CLASS_PYRO] >= global.playerLimit print(' Pyro: Off');
else print(' Pyro: '+string(global.classlimits[CLASS_PYRO]));

if global.classlimits[CLASS_SOLDIER] >= global.playerLimit print(' Soldier: Off');
else print(' Soldier: '+string(global.classlimits[CLASS_SOLDIER]));

if global.classlimits[CLASS_HEAVY] >= global.playerLimit print(' Heavy: Off');
else print(' Heavy: '+string(global.classlimits[CLASS_HEAVY]));

if global.classlimits[CLASS_DEMOMAN] >= global.playerLimit print(' Demoman: Off');
else print(' Demoman: '+string(global.classlimits[CLASS_DEMOMAN]));

if global.classlimits[CLASS_MEDIC] >= global.playerLimit print(' Medic: Off');
else print(' Medic: '+string(global.classlimits[CLASS_MEDIC]));

if global.classlimits[CLASS_ENGINEER] >= global.playerLimit print(' Engineer: Off');
else print(' Engineer: '+string(global.classlimits[CLASS_ENGINEER]));

if global.classlimits[CLASS_SPY] >= global.playerLimit print(' Spy: Off');
else print(' Spy: '+string(global.classlimits[CLASS_SPY]));

if global.classlimits[CLASS_SNIPER] >= global.playerLimit print(' Sniper: Off');
else print(' Sniper: '+string(global.classlimits[CLASS_SNIPER]));

if global.classlimits[CLASS_QUOTE] >= global.playerLimit print(' Quote: Off');
else print(' Quote: '+string(global.classlimits[CLASS_QUOTE]));
");
ds_map_add(global.documentationDict, "setClasslimit", "
print('Syntax: setClasslimit className newClasslimit');
print('className can be typed with the tf2 or the gg2 name, but only in singular.');
print('Use: Change current classlimits of a class');");


ds_map_add(global.commandDict, "startRecording", "
if global.recordingEnabled
{
    print('You are already recording.');
    exit;
}
else
{
    global.recordingEnabled = 1;
    global.justEnabledRecording = 1;
    print('Started recording...')
}");
ds_map_add(global.documentationDict, "startRecording", "
print('Syntax: startRecording');
print('Use: Begins to record the current game into a replay. To stop recording, call');
print('stopRecording');
");


ds_map_add(global.commandDict, "stopRecording", "
if !global.recordingEnabled
{
    print('You are not recording.');
    exit;
}
else
{
    print('Saving...')
    endRecording();
    print('Replay saved successfully');
}");
ds_map_add(global.documentationDict, "stopRecording", "
print('Syntax: stopRecording');
print('Use: Stops any recording going on and saves the replay.');
");


ds_map_add(global.commandDict, "setChatMode", "
switch string_lower(input[1])
{
    case 'off':
    case 'disabled':
        global.chatMode = 0;
        print('Chat has been disabled');
        break;
        
    case 'team':
        global.chatMode = 1;
        print('Chat has been enabled, but only for team chat');
        break;

    case 'global':
    case 'all':
    case 'crossteam':
        global.chatMode = 2;
        print('Global chat has been enabled.');
        break;
}");
ds_map_add(global.documentationDict, "setChatMode", "
print('Syntax: setChatMode mode');
print('Mode can be: off, team or all');
print('Use: Changes the chat settings. |off| disables all chat, |team| enables team only chat');
print(' and |all| enables both team and global chat');");


ds_map_add(global.commandDict, "mute", "
var player;
player = findPlayer(input[1]);
if player != -1 and player != ds_list_find_value(global.players, 0)
{
    with player
    {
        muted = 1;
    }
    print(player.name+' cannot chat anymore.');
}
else
{
    print('Could not find a player with that ID.');
}");
ds_map_add(global.documentationDict, "mute", "
print('Syntax: mute playerID');
print('Use: Bans the designated player from the chat until you unban him or he leaves.');
");


ds_map_add(global.commandDict, "unmute", "
var player;
player = findPlayer(input[1]);
if player != -1 and player != ds_list_find_value(global.players, 0)
{
    if player.muted == 0
    {
        print(player.name+' is not muted');
    }
    else
    {
        with player
        {
            muted = 0;
        }
        print(player.name+' can chat again.');
    }
}
else
{
    print('Could not find a player with that ID.');
}");
ds_map_add(global.documentationDict, "unmute", "
print('Syntax: unmute playerID');
print('Use: Allows a player banned from chat to re-enter it.');
");


ds_map_add(global.commandDict, "endMap", "
if input[1] != ''
{
    // User entered a map
    global.suggestedMap = input[1]
    global.mapchanging = 0
}
global.winners = TEAM_SPECTATOR;
");
ds_map_add(global.documentationDict, "endMap", "
print('Syntax: endMap optionalMapName')
print('Use: Ends the map with a stalemate, and if you have entered a map name will change to that map.')
print('If you havent, it will simply go to the next map in the rotation.');
print('Warning: Please be careful to enter a correct map name, entering a wrong one will crash the server!');
");


ds_map_add(global.commandDict, "shuffleMaps", "
ds_list_shuffle(global.map_rotation);
print('Shuffled map rotation');
");
ds_map_add(global.documentationDict, "shuffleMaps", "
print('Syntax: shuffleMaps');
print('Use: Randomizes the map rotation');
");


ds_map_add(global.commandDict, "changeNextMap", "
global.nextMap = input[1]
");
ds_map_add(global.documentationDict, "changeNextMap", "
print('Syntax: changeNextMap mapName')
print('Sets the designated map as the next map.');
print('Warning: Please be careful to enter a correct map name, entering a wrong one will crash the server!');
");
