if object.intel //I've got the enemy intel!!
{
    if team == TEAM_RED //Get back to my base
    {
        target = IntelligenceBaseRed
    }
    else
    {
        target = IntelligenceBaseBlue
    }
}
else
{
    if team == TEAM_RED
    {
        target = IntelligenceBaseBlue
    }
    else
    {
        target = IntelligenceBaseRed
    }
}
