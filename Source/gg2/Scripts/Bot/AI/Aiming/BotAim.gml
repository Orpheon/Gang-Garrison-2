// Predicts the movements of the nearest enemy and aims

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

else if class == CLASS_MEDIC
{
    weapon_speed = 9
}

else if class != CLASS_SNIPER
{
    show_message("This class isn't ready yet. How did you manage to do this? Please post it in the thread.")
    class = CLASS_SCOUT
}

if class == CLASS_SNIPER
{
    predictedEnemy_x = nearestEnemy.x
    predictedEnemy_y = nearestEnemy.y
}
else
{
    weapon_velocity = weapon_speed * sign(nearestEnemy.x-object.x)

    if weapon_velocity-nearestEnemy.hspeed == 0
    {
        predictedEnemy_x = nearestEnemy.x
        time = 0
    }
    else
    {
        time = (nearestEnemy.x-object.x)/(weapon_velocity-nearestEnemy.hspeed)
        predictedEnemy_x = object.x+(weapon_velocity*time)
    }
    
    if time < 0
    {
        predictedEnemy_x = nearestEnemy.x
        time = 0
    }

    if !position_meeting(nearestEnemy.x, nearestEnemy.y+1, Obstacle)
    {                                                                  // This checks, or tries to check, the y positions of the target.
        calc_y = nearestEnemy.y                                        // It does this by iterating because there is no better solution.
        calc_vspeed = nearestEnemy.vspeed                              // Also, this gets completely owned by stairs.

        time = min(150, time)
        
        for (i=0; i<=time; i+=1)
        {
            calc_y += calc_vspeed
            calc_vspeed += 0.6
            if position_meeting(nearestEnemy.x+(nearestEnemy.hspeed*i), calc_y+(nearestEnemy.sprite_height-nearestEnemy.sprite_yoffset)+1, Obstacle)
            {
                break
            }
        }
        predictedEnemy_y = calc_y
    }
    else
    {
        predictedEnemy_y = nearestEnemy.y
    }
    
    if class == CLASS_HEAVY// Take in account; bullets also have gravity.
    {
        predictedEnemy_y -= 0.15*power(time, 2)
    }
}

aimDirection = point_direction(object.x, object.y, predictedEnemy_x, predictedEnemy_y)

/*if class == CLASS_SNIPER// Nerfing the snipers aim; not really necessary imo because sniper bots are a bit UP
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
}*/
