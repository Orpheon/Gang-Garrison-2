{
    instance_create(0,0,RoomChangeObserver);
    set_little_endian_global(true);
    if file_exists("game_errors.log") file_delete("game_errors.log");
    
    var customMapRotationFile;
    
    //import wav files for music
    global.MenuMusic=sound_add(choose("Music/menumusic1.wav","Music/menumusic2.wav","Music/menumusic3.wav","Music/menumusic4.wav"), 1, true);
    global.IngameMusic=sound_add("Music/ingamemusic.wav", 1, true);
    global.FaucetMusic=sound_add("Music/faucetmusic.wav", 1, true);
    if(global.MenuMusic != -1)
        sound_volume(global.MenuMusic, 0.8);
    if(global.IngameMusic != -1)
        sound_volume(global.IngameMusic, 0.8);
    if(global.FaucetMusic != -1)
        sound_volume(global.FaucetMusic, 0.8);
        
    global.sendBuffer = buffer_create();
    global.eventBuffer = buffer_create();
    global.tempBuffer = buffer_create();
    global.HudCheck = false;
    global.map_rotation = ds_list_create();    
    
    OHU_Init()
    
    global.CustomMapCollisionSprite = -1;
        
    window_set_region_scale(-1, false);
    
    ini_open("gg2.ini");
    global.playerName = ini_read_string("Settings", "PlayerName", "Player");
    if string_count("#",global.playerName) > 0 global.playerName = "Player";
    global.playerName = string_copy(global.playerName, 0, min(string_length(global.playerName), MAX_PLAYERNAME_LENGTH));
    global.fullscreen = ini_read_real("Settings", "Fullscreen", 0);
    global.useLobbyServer = ini_read_real("Settings", "UseLobby", 1);
    global.hostingPort = ini_read_real("Settings", "HostingPort", 8190);
    global.ingameMusic = ini_read_real("Settings", "IngameMusic", 1);
    global.playerLimit = ini_read_real("Settings", "PlayerLimit", 10);
    global.particles =  ini_read_real("Settings", "Particles", PARTICLES_NORMAL);
    global.gibLevel = ini_read_real("Settings", "Gib Level", 3);
    global.killCam = ini_read_real("Settings", "Kill Cam", 1);
    global.monitorSync = ini_read_real("Settings", "Monitor Sync", 0);
    if global.monitorSync == 1 set_synchronization(true);
    else set_synchronization(false);
    global.medicRadar = ini_read_real("Settings", "Healer Radar", 1);
    global.showHealer = ini_read_real("Settings", "Show Healer", 1);
    global.showHealing = ini_read_real("Settings", "Show Healing",1);
    global.showHealthBar = ini_read_real("Settings", "Show Healthbar",0);
    //user HUD settings
    global.timerPos=ini_read_real("Settings","Timer Position", 0)
    global.killLogPos=ini_read_real("Settings","Kill Log Position", 0)
    global.kothHudPos=ini_read_real("Settings","KoTH HUD Position", 0)
    global.clientPassword = "";
    // for admin menu
    customMapRotationFile = ini_read_string("Server", "MapRotation", "");
    global.timeLimitMins = max(1, min(255, ini_read_real("Server", "Time Limit", 15)));
    global.serverPassword = ini_read_string("Server", "Password", "");
    global.mapRotationFile = customMapRotationFile;
    global.dedicatedMode = ini_read_real("Server", "Dedicated", 0);
    global.serverName = ini_read_string("Server", "ServerName", "My Server");
    global.caplimit = max(1, min(255, ini_read_real("Server", "CapLimit", 5)));
    global.caplimitBkup = global.caplimit;
    global.autobalance = ini_read_real("Server", "AutoBalance",1);
    global.Server_RespawntimeSec = ini_read_real("Server", "Respawn Time", 5);
    global.currentMapArea=1;
    global.totalMapAreas=1;
    global.setupTimer=1800;
    global.joinedServerName="";
    
    global.randomRotation = ini_read_real("Server", "Randomize Rotation", 0)
    
    //Classlimits:
    global.classlimits[CLASS_SCOUT] = ini_read_real("Server", "Runner Class Limit", 9999)
    global.classlimits[CLASS_PYRO] = ini_read_real("Server", "Firebug Class Limit", 9999)
    global.classlimits[CLASS_SOLDIER] = ini_read_real("Server", "Rocketman Class Limit", 9999)
    global.classlimits[CLASS_HEAVY] = ini_read_real("Server", "Overweight Class Limit", 9999)
    global.classlimits[CLASS_DEMOMAN] = ini_read_real("Server", "Detonator Class Limit", 9999)
    global.classlimits[CLASS_MEDIC] = ini_read_real("Server", "Healer Class Limit", 9999)
    global.classlimits[CLASS_ENGINEER] = ini_read_real("Server", "Constructor Class Limit", 9999)
    global.classlimits[CLASS_SPY] = ini_read_real("Server", "Infiltrator Class Limit", 9999)
    global.classlimits[CLASS_SNIPER] = ini_read_real("Server", "Rifleman Class Limit", 9999)
    global.classlimits[CLASS_QUOTE] = ini_read_real("Server", "Quote Class Limit", 9999)
    
    // Bot options
    global.bot_num_wished = ini_read_real("Bots", "Number of Bots", 10)
    global.bot_mode = ini_read_real("Bots", "Mode", 0)
    global.bot_coop = ini_read_real("Bots", "Co-op enabled", 0)
    global.bot_class_array[0] = ini_read_real("Bots", "Runner enabled", 1)
    global.bot_class_array[1] = ini_read_real("Bots", "Firebug enabled", 1)
    global.bot_class_array[2] = ini_read_real("Bots", "Rocketman enabled", 1)
    global.bot_class_array[3] = ini_read_real("Bots", "Overweight enabled", 1)
    global.bot_class_array[4] = ini_read_real("Bots", "Healer enabled", 1)
    global.bot_class_array[5] = ini_read_real("Bots", "Constructor enabled", 1)
    global.bot_class_array[6] = ini_read_real("Bots", "Rifleman enabled", 1)

    global.bot_num = 0
    global.bot_offset = 0
        
    ini_write_string("Settings", "PlayerName", global.playerName);
    ini_write_real("Settings", "Fullscreen", global.fullscreen);
    ini_write_real("Settings", "UseLobby", global.useLobbyServer);
    ini_write_real("Settings", "HostingPort", global.hostingPort);
    ini_write_real("Settings", "IngameMusic", global.ingameMusic);
    ini_write_real("Settings", "PlayerLimit", global.playerLimit);
    ini_write_real("Settings", "Particles", global.particles);
    ini_write_real("Settings", "Gib Level", global.gibLevel);
    ini_write_real("Settings", "Kill Cam", global.killCam);
    ini_write_real("Settings", "Monitor Sync", global.monitorSync);
    ini_write_real("Settings", "Healer Radar", global.medicRadar);
    ini_write_real("Settings", "Show Healer", global.showHealer);
    ini_write_real("Settings", "Show Healing", global.showHealing);
    ini_write_real("Settings", "Show Healthbar", global.showHealthBar);
    ini_write_real("Settings","Timer Position", global.timerPos)
    ini_write_real("Settings","Kill Log Position", global.killLogPos)
    ini_write_real("Settings","KoTH HUD Position", global.kothHudPos)
    ini_write_string("Server", "MapRotation", customMapRotationFile);
    ini_write_real("Server", "Dedicated", global.dedicatedMode);
    ini_write_string("Server", "ServerName", global.serverName);
    ini_write_real("Server", "CapLimit", global.caplimit);
    ini_write_real("Server", "AutoBalance", global.autobalance);
    ini_write_real("Server", "Respawn Time", global.Server_RespawntimeSec);
    ini_write_real("Server", "Time Limit", global.timeLimitMins);
    ini_write_string("Server", "Password", global.serverPassword);
    ini_write_real("Server", "Runner Class Limit", global.classlimits[CLASS_SCOUT])
    ini_write_real("Server", "Firebug Class Limit", global.classlimits[CLASS_PYRO])
    ini_write_real("Server", "Soldier Class Limit", global.classlimits[CLASS_SOLDIER])
    ini_write_real("Server", "Overweight Class Limit", global.classlimits[CLASS_HEAVY])
    ini_write_real("Server", "Detonator Class Limit", global.classlimits[CLASS_DEMOMAN])
    ini_write_real("Server", "Healer Class Limit", global.classlimits[CLASS_MEDIC])
    ini_write_real("Server", "Constructor Class Limit", global.classlimits[CLASS_ENGINEER])
    ini_write_real("Server", "Infiltrator Class Limit", global.classlimits[CLASS_SPY])
    ini_write_real("Server", "Rifleman Class Limit", global.classlimits[CLASS_SNIPER])
    ini_write_real("Server", "Quote Class Limit", global.classlimits[CLASS_QUOTE])
    ini_write_real("Bots", "Number of Bots", global.bot_num_wished)
    ini_write_real("Bots", "Mode", global.bot_mode)
    ini_write_real("Bots", "Co-op enabled", global.bot_coop);
    ini_write_real("Bots", "Runner enabled", global.bot_class_array[0])
    ini_write_real("Bots", "Firebug enabled", global.bot_class_array[1])
    ini_write_real("Bots", "Rocketman enabled", global.bot_class_array[2])
    ini_write_real("Bots", "Overweight enabled", global.bot_class_array[3])
    ini_write_real("Bots", "Healer enabled", global.bot_class_array[4])
    ini_write_real("Bots", "Constructor enabled", global.bot_class_array[5])
    ini_write_real("Bots", "Rifleman enabled", global.bot_class_array[6])
   
    //screw the 0 index we will start with 1
    //map_truefort 
    maps[1] = ini_read_real("Maps", "ctf_truefort", 1);
    //map_2dfort 
    maps[2] = ini_read_real("Maps", "ctf_2dfort", 2);
    //map_conflict 
    maps[3] = ini_read_real("Maps", "ctf_conflict", 3);
    //map_classicwell 
    maps[4] = ini_read_real("Maps", "ctf_classicwell", 4);
    //map_waterway 
    maps[5] = ini_read_real("Maps", "ctf_waterway", 5);
    //map_orange 
    maps[6] = ini_read_real("Maps", "ctf_orange", 6);
    //map_dirtbowl
    maps[7] = ini_read_real("Maps", "cp_dirtbowl", 7);
    //map_egypt
    maps[8] = ini_read_real("Maps", "cp_egypt", 8);
    //arena_montane
    maps[9] = ini_read_real("Maps", "arena_montane", 9);
    //arena_lumberyard
    maps[10] = ini_read_real("Maps", "arena_lumberyard", 10);
    //gen_destroy
    maps[11] = ini_read_real("Maps", "gen_destroy", 11);
    //koth_valley
    maps[12] = ini_read_real("Maps", "koth_valley", 12);
    //koth_corinth
    maps[13] = ini_read_real("Maps", "koth_corinth", 13);
    //koth_harvest
    maps[14] = ini_read_real("Maps", "koth_harvest", 14);
    
    //Server respawn time calculator. Converts each second to a frame. (read: multiply by 30 :hehe:)
    if (global.Server_RespawntimeSec == 0)
    {
        global.Server_Respawntime = 1;
    }    
    else
    {
        global.Server_Respawntime = global.Server_RespawntimeSec * 30;    
    }    
    
    // I have to include this, or the client'll complain about an unknown variable.
    global.mapchanging = false;
    
    ini_write_real("Maps", "ctf_truefort", maps[1]);
    ini_write_real("Maps", "ctf_2dfort", maps[2]);
    ini_write_real("Maps", "ctf_conflict", maps[3]);
    ini_write_real("Maps", "ctf_classicwell", maps[4]);
    ini_write_real("Maps", "ctf_waterway", maps[5]);
    ini_write_real("Maps", "ctf_orange", maps[6]);
    ini_write_real("Maps", "cp_dirtbowl", maps[7]);
    ini_write_real("Maps", "cp_egypt", maps[8]);
    ini_write_real("Maps", "arena_montane", maps[9]);
    ini_write_real("Maps", "arena_lumberyard", maps[10]);
    ini_write_real("Maps", "gen_destroy", maps[11]);
    ini_write_real("Maps", "koth_valley", maps[12]);
    ini_write_real("Maps", "koth_corinth", maps[13]);
    ini_write_real("Maps", "koth_harvest", maps[14]);

    ini_close();
    
       
    
var a, IPRaw, portRaw;
doubleCheck=0;
global.launchMap = "";

    for(a = 1; a <= parameter_count(); a += 1) 
    {
        if (parameter_string(a) == "-dedicated")
        {
            global.dedicatedMode = 1;
        }
        else if (parameter_string(a) == "-server")
        {
            IPRaw = parameter_string(a+1);
            if (doubleCheck == 1)
            {
                doubleCheck = 2;
            }
            else
            {
                doubleCheck = 1;
            }
        }
        else if (parameter_string(a) == "-port")
        {
            portRaw = parameter_string(a+1);
            if (doubleCheck == 1)
            {
                doubleCheck = 2;
            }
            else
            {
                doubleCheck = 1;
            }
        }
        else if (parameter_string(a) == "-map")
        {
            global.launchMap = parameter_string(a+1);
            global.dedicatedMode = 1;
        }
    }
    
    if (doubleCheck == 2)
    {
        global.serverPort = real(portRaw);
        global.serverIP = IPRaw;
        global.isHost = false;
        global.client = instance_create(0,0,Client);
    }   
    
    global.customMapdesginated = 0;    
    
    // if the user defined a valid map rotation file, then load from there

    if(customMapRotationFile != "" && file_exists(customMapRotationFile) && global.launchMap == "") {
        global.customMapdesginated = 1;
        var fileHandle, i, mapname;
        fileHandle = file_text_open_read(customMapRotationFile);
        for(i = 1; !file_text_eof(fileHandle); i += 1) {
            mapname = file_text_read_string(fileHandle);
            // remove leading whitespace from the string
            while(string_char_at(mapname, 0) == " " || string_char_at(mapname, 0) == chr(9)) { // while it starts with a space or tab
              mapname = string_delete(mapname, 0, 1); // delete that space or tab
            }
            if(mapname != "" && string_char_at(mapname, 0) != "#") { // if it's not blank and it's not a comment (starting with #)
                ds_list_add(global.map_rotation, mapname);
            }
            file_text_readln(fileHandle);
        }
        file_text_close(fileHandle);
    }
    
     else if (global.launchMap != "") && (global.dedicatedMode == 1)
        {  
        ds_list_add(global.map_rotation, global.launchMap);
        }
    
     else { // else load from the ini file Maps section
        //Set up the map rotation stuff
        var i, sort_list;
        sort_list = ds_list_create();
        for(i=1; i <= 14; i += 1) {
            if(maps[i] != 0) ds_list_add(sort_list, ((100*maps[i])+i));
        }
        ds_list_sort(sort_list, 1);
        
        // translate the numbers back into the names they represent
        for(i=0; i < ds_list_size(sort_list); i += 1) {
            switch(ds_list_find_value(sort_list, i) mod 100) {
                case 1:
                    ds_list_add(global.map_rotation, "ctf_truefort");
                break;
                case 2:
                    ds_list_add(global.map_rotation, "ctf_2dfort");
                break;
                case 3:
                    ds_list_add(global.map_rotation, "ctf_conflict");
                break;
                case 4:
                    ds_list_add(global.map_rotation, "ctf_classicwell");
                break;
                case 5:
                    ds_list_add(global.map_rotation, "ctf_waterway");
                break;
                case 6:
                    ds_list_add(global.map_rotation, "ctf_orange");
                break;
                case 7:
                    ds_list_add(global.map_rotation, "cp_dirtbowl");
                break;
                case 8:
                    ds_list_add(global.map_rotation, "cp_egypt");
                break;
                case 9:
                    ds_list_add(global.map_rotation, "arena_montane");
                break;
                case 10:
                    ds_list_add(global.map_rotation, "arena_lumberyard");
                break;
                case 11:
                    ds_list_add(global.map_rotation, "gen_destroy");
                break;
                case 12:
                    ds_list_add(global.map_rotation, "koth_valley");
                break;
                case 13:
                    ds_list_add(global.map_rotation, "koth_corinth");
                break;
                case 14:
                    ds_list_add(global.map_rotation, "koth_harvest");
                break;
                    
            }
        }
        ds_list_destroy(sort_list);
    }
    
    window_set_fullscreen(global.fullscreen);
    
    draw_set_font(fnt_gg2);
    cursor_sprite = CrosshairS;
    
    if(!directory_exists(working_directory + "\Maps")) directory_create(working_directory + "\Maps");
    
    instance_create(0, 0, AudioControl);
    
    if(global.dedicatedMode == 1) {
        AudioControlToggleMute();
        room_goto_fix(Menu);
    }
    
    if global.randomRotation
    {
        copy_list = ds_list_create()
        
        while ds_list_size(global.map_rotation) > 0
        {
            index = random_range(0, ds_list_size(global.map_rotation)-1)
            ds_list_add(copy_list, ds_list_find_value(global.map_rotation, index))
            ds_list_delete(global.map_rotation, index)
        }
        
        for (s=0; s<ds_list_size(copy_list); s+=1)
        {
            ds_list_add(global.map_rotation, ds_list_find_value(copy_list, s))
        }
        
        ds_list_destroy(copy_list)
    }
        
    
    // custom dialog box graphics
    message_background(popupBackgroundB);
    message_button(popupButtonS);
    message_text_font("Century",9,c_white,1);
    message_button_font("Century",9,c_white,1);
    message_input_font("Century",9,c_white,0);
    
    // parse the protocol version UUID for later use
    parseProtocolUuid();
    
    //Key Mapping
    ini_open("controls.gg2");
    global.jump = ini_read_real("Controls", "jump", ord("W"));
    global.down = ini_read_real("Controls", "down", ord("S"));
    global.left = ini_read_real("Controls", "left", ord("A"));
    global.right = ini_read_real("Controls", "right", ord("D"));
    global.attack = ini_read_real("Controls", "attack", MOUSE_LEFT);
    global.special = ini_read_real("Controls", "special", MOUSE_RIGHT);
    global.taunt = ini_read_real("Controls", "taunt", ord("F"));
    global.chat1 = ini_read_real("Controls", "chat1", ord("Z"));
    global.chat2 = ini_read_real("Controls", "chat2", ord("X"));
    global.chat3 = ini_read_real("Controls", "chat3", ord("C"));
    global.medic = ini_read_real("Controls", "medic", ord("E"));
    global.drop = ini_read_real("Controls", "drop", ord("B"));
    global.changeTeam = ini_read_real("Controls", "changeTeam", ord("N"));
    global.changeClass = ini_read_real("Controls", "changeClass", ord("M"));
    global.showScores = ini_read_real("Controls", "showScores", vk_shift);
    ini_close();
    
    calculateMonthAndDay();
    
}
