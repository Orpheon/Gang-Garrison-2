// Special Pyro fighting script.
// Gotta take ammo in consideration as well. Sometime.

if sign(object.x-nearestTarget.x) == -1 and (point_distance(object.x, object.y, nearestTarget.x, nearestTarget.y) < point_distance(object.x, object.x, target.x, target.y))// Only follow an enemy if you aren't near to an objcetive
{
    if reverse
    {
        direction_ = 'left'
    }
    else
    {
        direction_ = 'right'
    }
}
else if (point_distance(object.x, object.y, nearestTarget.x, nearestTarget.y) < point_distance(object.x, object.x, target.x, target.y))
{
    if reverse
    {
        direction_ = 'right'
    }
    else
    {
        direction_ = 'left'
    }
}
else
{
    if sign(target.x-object.x) == 1
    {
        direction_ = 'right'
    }
    else
    {
        direction_ = 'left'
    }
}

if(collision_line(object.x,object.y,Target_x,Target_y,Obstacle,true,true)<0
&& collision_line(object.x,object.y,Target_x,Target_y,TeamGate,true,true)<0
&& collision_line(object.x,object.y,Target_x,Target_y,ControlPointSetupGate,true,true)<0
&& collision_line(object.x,object.y,Target_x,Target_y,IntelGate,true,true)<0
&& collision_line(object.x,object.y,Target_x,Target_y,BulletWall,true,true)<0)
{
    LMB = 1
}

if point_distance(object.x, object.y, nearestTarget.x, nearestTarget.y) > 350
{
    BotFighting = 0
    BotInit()
}
