// This script describes the behavior during fighting in close to medium combat.

// Charge at everything, but only if you're not walking somewhere already.
if (ds_list_empty(directionList) or task != 'objective') and target_in_sight
{
    dir = sign(predictedEnemy_x-object.x)
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
