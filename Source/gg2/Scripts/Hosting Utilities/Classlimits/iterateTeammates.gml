// Did this instead of the much better instance_number() because of spawning players.

//argument0 = the team of the player
//argument1 = the class in question

i = 0
for (a=0; a<ds_list_size(global.players)-1; a+=1)
{
    otherPlayer = ds_list_find_value(global.players, a)
    if otherPlayer.team == argument0 and otherPlayer.object_index == Player// Don't count bots, or things will get stupid.
    {
        if otherPlayer.class = argument1
        {
            i += 1
        }
    }
}

return i
