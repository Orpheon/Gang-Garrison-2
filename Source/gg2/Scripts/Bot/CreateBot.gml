bot = instance_create(0, 0, BotPlayer)
ds_list_add(global.players, bot)
        
with bot
{
    BotInit()
}
        
bot.team = GetBotTeam(bot)
bot.class = GetBotClass(bot)
        
if global.botNamePrefix == ""
{
    bot.name = "Tempest Bot "+string(global.botNameCounter)
}
else
{
    bot.name = global.botNamePrefix+string(global.botNameCounter)
}
global.botNameCounter += 1
        
bot.alarm[5] = 1

ServerPlayerJoin(bot, global.sendBuffer)
ServerPlayerChangeteam(ds_list_size(global.players)-1, bot.team, global.sendBuffer)
ServerPlayerChangeclass(ds_list_size(global.players)-1, bot.class, global.sendBuffer)
