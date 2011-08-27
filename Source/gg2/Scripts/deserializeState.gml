// Read state data from the global.serverSocket and deserialize it
// argument0: Type of the state update

global.updateType = argument0;

playerNumber = read_ubyte(global.socketBuffer)
if(playerNumber != ds_list_size(global.players)) {
show_message("Wrong number of players while deserializing state");
}

if argument0 != CAPS_UPDATE {

    for(i=0; i<ds_list_size(global.players); i+=1) {
        player = ds_list_find_value(global.players, i);
        with(player) {
            event_user(13);
        }
    }
}

if(argument0 == FULL_UPDATE) {

    deserialize(IntelligenceRed);
    deserialize(IntelligenceBlue);

    global.caplimit = read_ubyte(global.socketBuffer);
    global.redCaps = read_ubyte(global.socketBuffer);
    global.blueCaps = read_ubyte(global.socketBuffer);
    global.Server_RespawntimeSec = read_ubyte(global.socketBuffer);
    global.Server_Respawntime = global.Server_RespawntimeSec * 30;
         
    if instance_exists(ControlPointHUD){
        with ControlPointHUD event_user(13);
    }
    else if instance_exists(ScorePanel){
        with ScorePanel event_user(13);
    }
    else if instance_exists(GeneratorHUD) {
        with GeneratorHUD event_user(13);
    }
    else if instance_exists(ArenaHUD) {
        with ArenaHUD event_user(13);
    }
    else if instance_exists(KothHUD) {
        with KothHUD event_user(13);
    }
}

if(argument0 == CAPS_UPDATE) {
    global.redCaps = read_ubyte(global.socketBuffer);
    global.blueCaps = read_ubyte(global.socketBuffer);
    global.Server_RespawntimeSec = read_ubyte(global.socketBuffer);

    if instance_exists(ControlPointHUD){
        with ControlPointHUD event_user(13);
    }
    else if instance_exists(ScorePanel){
        with ScorePanel event_user(13);
    }
    else if instance_exists(GeneratorHUD) {
            with GeneratorHUD event_user(13);
    }
    else if instance_exists(ArenaHUD) {
            with ArenaHUD event_user(13);
    }
    else if instance_exists(KothHUD) {
            with KothHUD event_user(13);
    }
}
