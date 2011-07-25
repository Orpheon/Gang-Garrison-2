if sign(nearestTarget.hspeed) == 1
{
    direction_ = 'right'
}
else
{
    direction_ = 'left'
}

if attack_later == 0
{
    if(collision_line(object.x,object.y,Target_x,Target_y,Obstacle,true,true)<0
        && collision_line(object.x,object.y,Target_x,Target_y,TeamGate,true,true)<0
        && collision_line(object.x,object.y,Target_x,Target_y,ControlPointSetupGate,true,true)<0
        && collision_line(object.x,object.y,Target_x,Target_y,IntelGate,true,true)<0
        && collision_line(object.x,object.y,Target_x,Target_y,BulletWall,true,true)<0)

    {
        LMB = 1
    }
    else if(collision_line(object.x,object.y-40,Target_x,Target_y,Obstacle,true,true)<0
        && collision_line(object.x,object.y-40,Target_x,Target_y,TeamGate,true,true)<0
        && collision_line(object.x,object.y-40,Target_x,Target_y,ControlPointSetupGate,true,true)<0
        && collision_line(object.x,object.y-40,Target_x,Target_y,IntelGate,true,true)<0
        && collision_line(object.x,object.y-40,Target_x,Target_y,BulletWall,true,true)<0)
    {
        jump = 1
        attack_later = 1
    }
}
else
{
    if attack_later == 12
    {
        LMB = 1
        attack_later = 0
    }
    else
    {
        attack_later += 1
    }
}

if point_distance(object.x, object.y, nearestTarget.x, nearestTarget.y) > 350
{
    BotFighting = 0
    BotInit()
}
