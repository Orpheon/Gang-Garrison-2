// This script describes the behavior during fighting in close to medium combat.

if (ds_list_empty(directionList) or task != 'objective') and target_in_sight
{
    dir = sign(nearestEnemy.hspeed)// Copy the back-forward movement of your enemy.
                                   // --> If he attacks, retreat; else charge
    if dir == 0
    {
        dir = sign(nearestEnemy.x-object.x)
    }
}

if dir == 0
{
    dir = 1
}


if(collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,Obstacle,true,true)<0
    && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,TeamGate,true,true)<0
    && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,ControlPointSetupGate,true,true)<0
    && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,IntelGate,true,true)<0
    && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,BulletWall,true,true)<0)
{
    LMB = 1
}


// Building sentries:

var ypos;
if target_in_sight and class == CLASS_ENGINEER and object.nutsNBolts >= 100 and collision_circle(object.x, object.y, 50, Sentry, false, true) < 0
{
    ypos = object.y

    while true
    {
        if collision_point(object.x, ypos, Obstacle, 1, 1)
        {
            break
        }
        ypos += 1
    }
    if collision_circle(object.x, ypos, 50, Sentry, false, true) < 0
    {
        // Do I already have a sentry?
        if sentry != -1
        {
            if collision_line(sentry.x, sentry.y, object.x, object.y, Obstacle, 1, 1) >= 0
            {
                // Destroy sentry
                with sentry
                {
                    instance_destroy()
                }
                sentry = -1
            }
        }
        else
        {
            // Build a new Sentry
            buildSentry(id)
            write_ubyte(global.sendBuffer, BUILD_SENTRY)
            write_ubyte(global.sendBuffer, ds_list_find_index(global.players, id))
        }
    }
}
