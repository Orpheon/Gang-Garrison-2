{
    if ds_list_find_index(global.ignore_list, argument0) >= 0
    {
        ds_list_delete(global.ignore_list, argument0);
    }

    with(argument0) {
        instance_destroy();
    }
    
    ds_list_delete(global.players, ds_list_find_index(global.players, argument0));
}