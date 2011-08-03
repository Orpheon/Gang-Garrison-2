if global.bot_coop and class != CLASS_MEDIC
{
    var targetQueue, testDist, playercheck, targetAngle, obscured, rotateoffset;

    nearestFriend = -1;
    targetQueue = ds_priority_create();

    // Build a queue of potential targets
    with(Character) {
        testDist = distance_to_object(other.object);
        if(player.object_index == Player and team == other.team) {//If the Character is not a bot and on our team:
            ds_priority_add(targetQueue, id, testDist);
        }
    }

    if(nearestFriend == -1 && !ds_priority_empty(targetQueue)) {
        playercheck = ds_priority_delete_min(targetQueue);
        nearestFriend = playercheck     
    }
    ds_priority_destroy(targetQueue);

    if nearestFriend != -1
    {
        if point_distance(object.x, object.y, nearestFriend.x, nearestFriend.y) < 150
        {
            followingHuman = 1
        }
        else
        {
            followingHuman = 0
        }
    }
}
