var targetQueue, testDist, playercheck, targetAngle, obscured, rotateoffset;

nearestTarget = -1;
targetQueue = ds_priority_create();

// Build a queue of potential targets
with(Character) {
    testDist = distance_to_object(other.object);
    
    if (cloakAlpha != 0.5 and random(5)<2) or cloakAlpha == 1 or cloakAlpha == 0 {
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

nearestTarget = -1

while(nearestTarget == -1 && !ds_priority_empty(targetQueue)) {
    playercheck = ds_priority_delete_min(targetQueue);
    targetAngle = point_direction(x,y,playercheck.x,playercheck.y);
    if (playercheck.team != team 
        && (collision_line(object.x,object.y,playercheck.x,playercheck.y,Obstacle,true,true)<0
        && collision_line(object.x,object.y,playercheck.x,playercheck.y,TeamGate,true,true)<0
        && collision_line(object.x,object.y,playercheck.x,playercheck.y,ControlPointSetupGate,true,true)<0
        && collision_line(object.x,object.y,playercheck.x,playercheck.y,IntelGate,true,true)<0
        && collision_line(object.x,object.y,playercheck.x,playercheck.y,BulletWall,true,true)<0)) {        // Target looks valid, but it might be obscured by a sentry.
        // That has to be tested individually because we have to exclude both this sentry and the target
        // from the collision check
        nearestTarget = playercheck
/*        with(Sentry) {
            if(!obscured && id != other.ownerPlayer.sentry && id != playercheck && collision_line(other.x,other.y,playercheck.x,playercheck.y,id,false,false)>=0) {
                obscured = true;
            }
        }
        if(!obscured) {
            nearestTarget = playercheck;
        }*/       
    }
}
ds_priority_destroy(targetQueue);

target_in_sight = 0
if nearestTarget != -1
{
    target_in_sight = 1
}

targetQueue = ds_priority_create();// no target in sight, just take the nearest one. Just do the entire thing again.
with(Character) {
    testDist = distance_to_object(other.object);
    if(cloakAlpha!=0.5){
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

if nearestTarget == -1 
{
    while(nearestTarget == -1 && !ds_priority_empty(targetQueue)) {
        playercheck = ds_priority_delete_min(targetQueue);
        targetAngle = point_direction(x,y,playercheck.x,playercheck.y);
        if (playercheck.team != team)
        {
            nearestTarget = playercheck
        }
    }
}

ds_priority_destroy(targetQueue);

/*
i = 0
min_dist = 999999999999
while i < ds_priority_size(targetQueue)
{
    if ds_priority_value(targetQueue, i) < min_dist
    {
        min_dist = ds_priority_value(targetQueue, i)
    }
}

global.min_dist = min_dist


show_message(string(targetQueue))
show_message(ds_priority_size(targetQueue))

ds_priority_destroy(targetQueue);


nearestTarget = -1
targetQueue = ds_list_create()

with(Character)
{
    testDist = distance_to_object(other)
    if(!cloak)
    {
        ds_list_add(targetQueue, testDist)
    }
}
*/
if nearestTarget != -1
{
    BotAim()
}
