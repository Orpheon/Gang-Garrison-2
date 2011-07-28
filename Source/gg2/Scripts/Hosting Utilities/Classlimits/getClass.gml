// This chooses a good class for players while taking classlimits in account.
// argument0 = the player team.
// argument1 = the class the player wishes.

if iterateTeammates(argument0, argument1) < global.classlimits[argument1]
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

    validClass = -1

    while validClass == -1 and ds_list_size(classes) > 0
    {
        index = random(ds_list_size(classes)-1)

        if iterateTeammates(ds_list_find_value(classes, index)) < global.classlimits[ds_list_find_value(classes, index)]
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
        show_message("Classlimits set too low on the server. No class free.#Please complain at the host or report this as a bug on the OHU thread.")
        game_end()
    }

    return validClass
}
