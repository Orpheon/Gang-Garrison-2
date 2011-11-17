var inputi;
input = argument0

while string_length(input) > 84
{
    ds_list_add(global.consoleLog, string_copy(input, 0, 83));
    input = string_copy(input, 84, string_length(input));
}

ds_list_add(global.consoleLog, input);

while ds_list_size(global.consoleLog) > 100
{
    ds_list_delete(global.consoleLog, 0)
}
