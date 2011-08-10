if class == CLASS_MEDIC
{
    var targetQueue, testDist, playercheck, targetAngle, obscured, rotateoffset;

    nearestFriend = -1;
    targetQueue = ds_priority_create();

    // Build a queue of potential targets
    with(Character) {
        testDist = distance_to_object(other.object);
        if(id != other.object.id and team == other.team and testDist < 300 and (player.class != CLASS_MEDIC or player.object_index == Player)) {// Only consider Characters near enough, the others get considered later. Also don't heal medic bots.
            ds_priority_add(targetQueue, id, maxHp-hp);
        }
    }

    while(nearestFriend == -1 && !ds_priority_empty(targetQueue)) {
        playercheck = ds_priority_delete_max(targetQueue);
        
        if collision_line(object.x, object.y, playercheck.x, playercheck.y, Obstacle, 1, 1)<=0
        {
            nearestFriend = playercheck
        }
    }
    ds_priority_destroy(targetQueue);
    
    if nearestFriend == -1
    {
        if nearestTarget != -1
        {
            if target_in_sight and point_distance(nearestTarget.x, nearestTarget.y, object.x, object.y) < 200
            {
                RMB = 1
                if sign(object.x-nearestTarget.x) == 1
                {
                    direction_ = "right"
                }
                else
                {
                    direction_ = "left"
                }
                exit;
            }
        }

        // No near friend; no near enemy; go to the most hurt Friend, even if they are far away.
        {
            var targetQueue, testDist, playercheck, targetAngle, obscured, rotateoffset;

            nearestFriend = -1;
            targetQueue = ds_priority_create();

            // Build a queue of potential targets
            with(Character) {
                testDist = distance_to_object(other.object);
                if(id != other.object.id and team == other.team) {
                    ds_priority_add(targetQueue, id, maxHp-hp);
                }
            }

            while(nearestFriend == -1 && !ds_priority_empty(targetQueue)) {
                playercheck = ds_priority_delete_max(targetQueue);
        
                if collision_line(object.x, object.y, playercheck.x, playercheck.y, Obstacle, 1, 1)<=0
                {
                    nearestFriend = playercheck
                }
            }
            ds_priority_destroy(targetQueue);
            
            if nearestFriend != -1// Go to that far-away friend
            {
                reverse = 0// The medic just runs away from you if this is on. Blast it.
                if sign(nearestFriend.x-object.x) == 1
                {
                    direction_ = "left"
                }
                else
                {
                    direction_ = "right"
                }
            }
            else// No friend on the map. Go to the enemy spawn.
            {
                if team == TEAM_RED
                {
                    target = SpawnPointBlue
                }
                else
                {
                    target = SpawnPointRed
                }
                
                if sign(target.x-object.x) == 1
                {
                    direction_ = "right"
                }
                else
                {
                    direction_ = "left"
                }
            }
        }
    }
    else// You are in proximity and in a line of sight of a friend. Heal him, and uber if either of your hps get too low.
    {
    
        if nearestFriend.vspeed < -5 //If the patient is jumping; jump as well.
        {
            jump = 1
        }
    
        aimDirection = point_direction(object.x, object.y, nearestFriend.x, nearestFriend.y)
    
        if sign(nearestFriend.x-object.x) == 1
        {
            direction_ = "right"
        }
        else
        {
            direction_ = "left"
        }

        if object.currentWeapon.healTarget != noone// You've switched targets. Let go of LMB to change patient.
        {
            if object.currentWeapon.healTarget.object != nearestFriend
            {
                LMB = 0
                exit;
            }
        }

        LMB = 1
        
        if (object.hp < 50 or nearestFriend.hp < 50) and object.currentWeapon.uberCharge == 2000
        {
            RMB = 1// Uber.
        }
    }
}
