var input;
input = argument0

with ChatBox
{
    ds_list_add(global.chatLog, argument0)
    ds_list_add(global.chatFadeTimers, 0)

    while ds_list_size(global.chatLog) > 20
    {
        ds_list_delete(global.chatLog, 0)
        ds_list_delete(global.chatFadeTimers, 0)
    }
}
