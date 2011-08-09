// Special Pyro fighting script.
// Gotta take ammo in consideration as well. Sometime.


if sign(object.x-nearestTarget.x) == -1
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
else
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
