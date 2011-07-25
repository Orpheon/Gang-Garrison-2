// I made this into a separate script because of map-changing.
//argument0=the bot object

argument0.team = calculateTeamBalance();
    
if global.bot_mode == 0 //If Bots should be split evenly over the teams; else they'll all stack on one team.
{
    if argument0.team == TEAM_RED
    {
        argument0.team = TEAM_BLUE
    }
    else if argument0.team == TEAM_BLUE
    {
        argument0.team = TEAM_RED
    }
}
if argument0.team == -1
{
    argument0.team = choose(TEAM_RED, TEAM_BLUE)
}
