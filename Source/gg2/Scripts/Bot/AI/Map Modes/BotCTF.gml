var intel;

if object.intel // If I have the intel
{
    task = 'objective'// Don't let anything delay me
    switch team
    {
        case TEAM_BLUE:
            target = IntelligenceBaseBlue
            break
        
        case TEAM_RED:
            target = IntelligenceBaseRed
            break
            
        default:
            show_message("Invalid team at BotCTF#Team: "+string(team))
    }
    return 1
}

switch team
{
    case TEAM_RED:
        intel = IntelligenceBlue
        break
        
    case TEAM_BLUE:
        intel = IntelligenceRed
        break
}

if !instance_exists(intel)
{
    switch team
    {
        case TEAM_RED:
            intel = IntelligenceBaseBlue
            break
        
        case TEAM_BLUE:
            intel = IntelligenceBaseRed
            break
    }
}

if !instance_exists(intel)
{
    var newPlayer;

    for (i=0; i<ds_list_size(global.players); i+=1)
    {
        newPlayer = ds_list_find_value(global.players, i)
        
        if newPlayer.team == team and newPlayer.object.intel == 1
        {
            target = newPlayer.object
        }
    }
}
else
{
    target = intel
}
