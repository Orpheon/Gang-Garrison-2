// Writes argument0 to the console
// Ripped from TTS

ds_list_add(global.ConsoleLog,argument0);
while (ds_list_size(global.ConsoleLog)>10) {
    ds_list_delete(global.ConsoleLog,0);
}
