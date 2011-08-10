foundCP = false// This is for A/D blu

with ControlPoint
{
    if locked == 0 and team != -1 and team != other.team
    {
        other.target = id
        foundCP = true
        break;
    }
}

if !foundCP
{
    if team == TEAM_RED
    {
        target = SpawnPointRed
    }
    else
    {
        target = SpawnPointBlue
    }
}
