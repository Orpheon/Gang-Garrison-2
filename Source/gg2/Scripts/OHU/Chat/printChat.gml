var input;
input = argument0

with ChatBox
{
    ds_list_add(chatLog, argument0)

    while ds_list_size(chatLog) > 20
    {
        ds_list_delete(chatLog, 0)
    }
}
