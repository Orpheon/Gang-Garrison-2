// This fakes the creation of a new player for the bot

/*if(ds_list_size(global.players) >= global.playerLimit) //I'm turning this off because Bots aren't really counted as players for anyone anymore.
{
    exit
}
else*/
{
    var i, player;

    player = instance_create(0,0,BotPlayer);
    
    player.aimDirection = 0

    if global.botJoined[0]// The hoster decided to add a few bots via console.
    {
        player.name = global.botJoined[1]
        player.team = global.botJoined[2]
        player.class = global.botJoined[3]
        
        global.botJoined[0] = false
    }
    else
    {
        GetBotTeam(player)
    
        GetBotClass(player)

        player.name = "Tempest Bot "+string(global.bot_num+global.bot_offset);
    }
    
    global.bot_num += 1
    
    player.authorized = true
    
    ds_list_add(global.players, player);
    
    ServerPlayerJoin(player.name, global.sendBuffer);
    ServerPlayerChangeteam(ds_list_size(global.players)-1, player.team, global.sendBuffer)
    ServerPlayerChangeclass(ds_list_size(global.players)-1, player.class, global.sendBuffer)
}
