var class_list; 
class_list = ds_list_create()   

team = argument0.team

if global.bot_class_array[0]
{
    ds_list_add(class_list, CLASS_SCOUT)
}
if global.bot_class_array[1]
{
    ds_list_add(class_list, CLASS_PYRO)
}
if global.bot_class_array[2]
{
    ds_list_add(class_list, CLASS_SOLDIER)
}
if global.bot_class_array[3]
{
    ds_list_add(class_list, CLASS_HEAVY)
}
if global.bot_class_array[4]
{
    ds_list_add(class_list, CLASS_ENGINEER)
}
if global.bot_class_array[5]
{
    ds_list_add(class_list, CLASS_SNIPER)
}
    
index = random_range(0, ds_list_size(class_list)-1)
    
if ds_list_size(class_list) > 0 //If at least one bot has been enabled...
{
    argument0.class = ds_list_find_value(class_list, index)
}
else
{
    argument0.class = choose(CLASS_SCOUT, CLASS_PYRO, CLASS_SOLDIER, CLASS_HEAVY, CLASS_SNIPER)
}
    
ds_list_destroy(class_list)
