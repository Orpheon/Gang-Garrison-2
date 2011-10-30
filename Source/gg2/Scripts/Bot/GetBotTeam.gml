// argument0=the bot object

if global.botMode == 0 or global.botMode == 3// Mixed vs Mixed
{
    if calculateTeamBalance() == TEAM_RED
    {
        argument0.team = TEAM_BLUE
    }
    else if calculateTeamBalance() == TEAM_BLUE
    {
        argument0.team = TEAM_RED
    }
    else
    {
        argument0.team = choose(TEAM_RED, TEAM_BLUE)
    }
}
else// Human vs Bots
{
    argument0.team = global.botChosenTeam
}
