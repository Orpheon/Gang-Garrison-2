var name;

name = get_open_filename("*.gg2", "")

if file_exists(name)
{
    global.playback = 1

    var text;
    text = file_bin_open(name, 0);
    for(i=0; i<file_bin_size(text); i+=1)
    {
        write_ubyte(global.replayBuffer, file_bin_read_byte(text));
    }

    file_bin_close(text);
}
else
{
    global.isPlayingReplay = 0
    exit;
}

global.replaySpeed = 1
global.replayTime = 0
