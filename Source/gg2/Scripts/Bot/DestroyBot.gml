for (i=ds_list_size(global.players)-1; i>=0; i-=1) //I'd like to remove the last botPlayer, not the first. Hence the counting from last to first.
{
    if ds_list_find_value(global.players, i).object_index == BotPlayer
    {
        removePlayer(ds_list_find_value(global.players, i))
        ServerPlayerLeave(i)
        break;
    }
}

global.bot_num -= 1
