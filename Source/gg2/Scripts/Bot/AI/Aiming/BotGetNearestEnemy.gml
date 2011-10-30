// Finds the nearest enemy


var targetQueue, testDist, playercheck, nearstEnemy, closestEnemy;

nearestEnemy = -1;
targetQueue = ds_priority_create();

// Build a queue of potential targets
with(Character) {
    testDist = distance_to_object(other.object);
    
    if cloakAlpha == 1 or cloakAlpha == 0 {
        ds_priority_add(targetQueue, id, testDist);
    }
}

with(Sentry) {
    testDist = distance_to_object(other.object);
    if(testDist) {
        ds_priority_add(targetQueue, id, testDist);
    }
}

with(Generator) {
    testDist = distance_to_object(other.object);
    if(testDist) {
        ds_priority_add(targetQueue, id, testDist);
    }
}

nearestEnemy = -1
closestEnemy = ds_priority_find_min(targetQueue)

while(nearestEnemy == -1 && !ds_priority_empty(targetQueue)) {
    playercheck = ds_priority_delete_min(targetQueue);
    if (playercheck.team != team 
        && (collision_line(object.x,object.y,playercheck.x,playercheck.y,Obstacle,true,true)<0
        && collision_line(object.x,object.y,playercheck.x,playercheck.y,TeamGate,true,true)<0
        && collision_line(object.x,object.y,playercheck.x,playercheck.y,ControlPointSetupGate,true,true)<0
        && collision_line(object.x,object.y,playercheck.x,playercheck.y,IntelGate,true,true)<0
        && collision_line(object.x,object.y,playercheck.x,playercheck.y,BulletWall,true,true)<0)) {        // Target looks valid, but it might be obscured by a sentry.
        // That has to be tested individually because we have to exclude both this sentry and the target
        // from the collision check
        nearestEnemy = playercheck    
    }
}
ds_priority_destroy(targetQueue);

target_in_sight = 1

if nearestEnemy != -1
{
    return nearestEnemy
}

target_in_sight = 0

return closestEnemy
