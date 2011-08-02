if nearestTarget != -1
{
    target = nearestTarget //target the nearest enemy
}
else
{
    if team == TEAM_RED
        {
            target = SpawnPointBlue
        }
        else
        {
            target = SpawnPointRed
        }

}
