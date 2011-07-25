if class == CLASS_SCOUT
{
    weapon_speed = 13+object.hspeed
}

else if class == CLASS_SOLDIER
{
    weapon_speed = 13
}

else if class == CLASS_HEAVY
{
    weapon_speed = 12
}

else if class == CLASS_PYRO
{
    weapon_speed = 8
}

else if class == CLASS_ENGINEER
{
    weapon_speed = 13+object.hspeed
}

else if class != CLASS_SNIPER
{
    show_message("This class isn't ready yet. How did you manage to do this? Please post it on the thread.")
    class = CLASS_SCOUT
}

if class == CLASS_SNIPER
{
    Target_x = nearestTarget.x
    Target_y = nearestTarget.y
}
else
{
    if sign(object.x-nearestTarget.x) == 1
    {
        weapon_velocity = weapon_speed*(-1)
    }
    else
    {
        weapon_velocity = weapon_speed
    }

    if weapon_velocity-nearestTarget.hspeed < 1
    {
        Target_x = nearestTarget.x
        time = 0
    }
    else if nearestTarget.x-object.x < 0
    {
        Target_x = nearestTarget.x
        time = 0
    }
    else
    {
        time = (nearestTarget.x-object.x)/(weapon_velocity-nearestTarget.hspeed)
        Target_x = object.x+(weapon_velocity*time)
    }

    if !position_meeting(nearestTarget.x, nearestTarget.y+sprite_get_bbox_bottom(nearestTarget.sprite_index)+1, Obstacle)
    {                                                                  // This checks, or tries to check, the y positions of the target.
        calc_y = nearestTarget.y                                       // It does this by iterating because there is no better solution.
        calc_vspeed = nearestTarget.vspeed                             // Also, this gets completely owned by stairs.

        for (i=0; i<=time; i+=1)
        {
            calc_y += calc_vspeed
            calc_vspeed += 0.6
            if position_meeting(nearestTarget.x+(nearestTarget.hspeed*i), calc_y+1, Obstacle)
            {
                calc_vspeed = 0
            }
        }
        Target_y = calc_y
    }
    else
    {
        Target_y = nearestTarget.y
    }
    
    if class == CLASS_HEAVY// Take in account; bullets also have gravity.
    {
        Target_y -= 0.15*power(time, 2)
    }
}

aimDirection = point_direction(object.x, object.y, Target_x, Target_y)

if class == CLASS_SNIPER// Nerfing the snipers aim
{
    if aimModifier < -15
    {
        aimModifier += 10
    }
    else if aimModifier > 15
    {
        aimModifier -= 10
    }
    else
    {
        aimModifier += 2-random(4)
    }
    
    aimDirection += aimModifier
}

BotShoot()
