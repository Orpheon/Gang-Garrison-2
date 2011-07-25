// This adds a command to the processCommand script.
// argument0 = the command name
// argument1 = the command

ds_list_add(global.commandList, string(argument0))
ds_list_add(global.executionList, string(argument1))
