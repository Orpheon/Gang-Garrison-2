if sign(nearestTarget.hspeed) == 1
{
    direction_ = 'right'
}
else
{
    direction_ = 'left'
}

with object
{
    other.distance = distance_to_object(other.nearestTarget)
}

if object.zoomed == 0 and distance > 100 //If I'm not scoped and not in immediate danger; scope
{
    RMB = 1
}
else if object.zoomed == 1 and distance < 100 and object.currentWeapon.readyToShoot == 0 //If I'm scoped, have an enemy really near to me and just shot; unscope.
{
    RMB = 1
}

// Did this because I was to lazy to erase all the "Target_x" and the "Target_y", normally they contain the predicted position for the enemy, but sniper is instant.
Target_x = nearestTarget.x
Target_y = nearestTarget.y

if(collision_line(object.x,object.y,Target_x,Target_y,Obstacle,true,true)<0
&& collision_line(object.x,object.y,Target_x,Target_y,TeamGate,true,true)<0
&& collision_line(object.x,object.y,Target_x,Target_y,ControlPointSetupGate,true,true)<0
&& collision_line(object.x,object.y,Target_x,Target_y,IntelGate,true,true)<0
&& collision_line(object.x,object.y,Target_x,Target_y,BulletWall,true,true)<0)
{
    doesnt_collide = true

    list_of_char = ds_list_create()

    with Character
    {
        if player.team == other.team && id != other.object.id
        {
            ds_list_add(other.list_of_char, id)
        }
    }

    for (i=0; i<ds_list_size(list_of_char)-1; i+=1)
    {
        if collision_line(object.x, object.y, Target_x, Target_y, ds_list_find_value(list_of_char, i,), true, true)
        {
            doesnt_collide = false
            i = 100000//You'll never have that many players.
        }
    }
    
    if doesnt_collide
    {
        LMB = 1
    }
    ds_list_destroy(list_of_char)
}

// Maybe some function to descern whether you're in a very open spot, in which case you stop.
/* Something of the genre:

in_free_place = 1
h = 150
v = 10

while v < 151 and in_free_place == 1
{
    if collision_line(x, y, x+h, y+v, Obstacle, true, true)
    {
        in_free_place = 0
    }
}
