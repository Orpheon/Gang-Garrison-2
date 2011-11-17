ini_open("gg2.ini");

global.permBan = ini_read_real("Server", "Permanent Ban enabled", 0);
global.classlimits[CLASS_SCOUT] = ini_read_real("Classlimits", "Scout", 9999);
global.classlimits[CLASS_PYRO] = ini_read_real("Classlimits", "Pyro", 9999);
global.classlimits[CLASS_SOLDIER] = ini_read_real("Classlimits", "Soldier", 9999);
global.classlimits[CLASS_HEAVY] = ini_read_real("Classlimits", "Heavy", 9999);
global.classlimits[CLASS_DEMOMAN] = ini_read_real("Classlimits", "Demoman", 9999);
global.classlimits[CLASS_MEDIC] = ini_read_real("Classlimits", "Medic", 9999);
global.classlimits[CLASS_ENGINEER] = ini_read_real("Classlimits", "Engineer", 9999);
global.classlimits[CLASS_SPY] = ini_read_real("Classlimits", "Spy", 9999);
global.classlimits[CLASS_SNIPER] = ini_read_real("Classlimits", "Sniper", 9999);
global.classlimits[CLASS_QUOTE] = ini_read_real("Classlimits", "Quote", 9999);


ini_write_real("Server", "Permanent Ban enabled", global.permBan);
ini_write_real("Classlimits", "Scout", global.classlimits[CLASS_SCOUT]);
ini_write_real("Classlimits", "Pyro", global.classlimits[CLASS_PYRO]);
ini_write_real("Classlimits", "Soldier", global.classlimits[CLASS_SOLDIER]);
ini_write_real("Classlimits", "Heavy", global.classlimits[CLASS_HEAVY]);
ini_write_real("Classlimits", "Demoman", global.classlimits[CLASS_DEMOMAN]);
ini_write_real("Classlimits", "Medic", global.classlimits[CLASS_MEDIC]);
ini_write_real("Classlimits", "Engineer", global.classlimits[CLASS_ENGINEER]);
ini_write_real("Classlimits", "Spy", global.classlimits[CLASS_SPY]);
ini_write_real("Classlimits", "Sniper", global.classlimits[CLASS_SNIPER]);
ini_write_real("Classlimits", "Quote", global.classlimits[CLASS_QUOTE]);

ini_close();

global.banlist = ds_list_create()
global.banlistNames = ds_list_create()

// Load the banlist if persistent banning was enabled.
if global.permBan
{
    var text;
        
    if !file_exists("Banlist.txt")
    {
        text = file_text_open_write("Banlist.txt")
        file_text_close(text)
    }
    else
    {
        var ip, name;
            
        text = file_text_open_read("Banlist.txt")
        while !file_text_eof(text)
        {
            ip = file_text_read_string(text)
            file_text_readln(text)// Next line
                
            if string_count("#", ip) > 0
            {
                name = string_copy(ip, string_pos("#", ip)+2, string_length(ip))
                ip = string_copy(ip, 0, string_pos("#", ip)-1)// Remove the name which is preceded with that "#".
                ds_list_add(global.banlistNames, name)
            }
            else
            {
                ds_list_add(global.banlistNames, "")
            }

            ds_list_add(global.banlist, ip)
        }
            
        file_text_close(text)
    }
}

defineConsoleCommands()
chatInit()
consoleInit()
loadPlugins()
