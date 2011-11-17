// This script counts how many players have a certain class on one team.
// argument0 == team of the player
// argument1 == asked class

var i;

i = 0

with Player
{
    if team != argument0 continue
    
    if class == argument1 i+=1
}

return i
