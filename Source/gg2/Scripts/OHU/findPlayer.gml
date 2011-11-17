// argument0 == player name
// Returns the object id of the corresponding player object.

var foundPlayer, searchedID, player;
foundPlayer = false;
searchedID = argument0;

with Player
{
    if ID == searchedID
    {
        foundPlayer = true;
        player = id;
        break;
    }
}

if foundPlayer
{
    return player
}
else
{
    return -1
}
