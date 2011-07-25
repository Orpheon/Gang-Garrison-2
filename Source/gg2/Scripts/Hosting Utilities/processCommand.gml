//argument0 = user input

string_array[] = 0
i = 0

while argument0 != ""
{
    index = string_pos("-", argument0)
    if index != 0
    {
        string_array[i] = string_copy(argument0, 1, index-2)
        argument0 = string_delete(argument0, 1, index)
    }
    else
    {
        string_array[i] = argument0
        argument0 = ""
    }
    i += 1
}

index = ds_list_find_index(global.commandList, string_array[0])
if index >= 0
{
    execute_string(ds_list_find_value(global.executionList, index))
}
else
{
    print("Unknown Command. Type help for a small list, and be sure to read the Read-me.")
}
