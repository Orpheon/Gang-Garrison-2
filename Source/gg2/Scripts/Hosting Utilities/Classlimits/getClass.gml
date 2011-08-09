// This chooses a good class for players while taking classlimits in account.
// argument0 = the player team.
// argument1 = the class the player wishes.
// argument2 = whether an extra class niche should be counted for the player.

/*if !variable_global_exists("global.classlimits[argument1]")
{
    // Should never happen, but it does. I've given up on trying to find out why.
    show_message("Error: "+string(argument1))
    return argument1
}*/

if iterateTeammates(argument0, argument1, argument2) <= global.classlimits[argument1]
{
    // You're allowed to get that class
    return argument1
}
else
{
    classes = ds_list_create()
    ds_list_add(classes, CLASS_SCOUT)
    ds_list_add(classes, CLASS_SOLDIER)
    ds_list_add(classes, CLASS_PYRO)
    ds_list_add(classes, CLASS_HEAVY)
    ds_list_add(classes, CLASS_DEMOMAN)
    ds_list_add(classes, CLASS_MEDIC)
    ds_list_add(classes, CLASS_ENGINEER)
    ds_list_add(classes, CLASS_SPY)
    ds_list_add(classes, CLASS_SNIPER)
    // No quote; you shouldn't be assigned quote by luck.
    
    validClass = -1
    
    while validClass == -1 and ds_list_size(classes) > 0
    {
        index = random(ds_list_size(classes)-1)

        if iterateTeammates(argument0, ds_list_find_value(classes, index), argument2) <= global.classlimits[ds_list_find_value(classes, index)]
        {
            validClass = ds_list_find_value(classes, index)
        }
        else
        {
            ds_list_delete(classes, index)
        }
    }
    
    if validClass == -1
    {
        show_message("Classlimits set too low on the server. No class free.")
        game_end()
    }
    
    return validClass
}
