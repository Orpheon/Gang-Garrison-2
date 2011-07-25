if collision_rectangle(object.x-1, object.y, object.x+1, object.y+(sprite_get_bbox_bottom(object.sprite_index)/2)+5, Obstacle, true, true) >= 0
{
    if position_meeting(object.x+sign(object.hspeed)*30, object.y, Obstacle) == 1
    {
        if position_meeting(object.x+sign(object.hspeed)*30, object.y-50, Obstacle) == 1
        {
            BotReverse()
        }
        else
        {
            jump = 1
        }
    }

    if position_meeting(object.x+sign(object.hspeed)*50, object.y+30, Obstacle) == 0
    {
        if position_meeting(object.x+object.hspeed*28, object.y+30, Obstacle) == 1
        {
            jump = 1
        }
    }

    if direction_ == 'right' //Doing it again with constants.
    {
        if position_meeting(object.x+30, object.y, Obstacle) == 1
        {
            if position_meeting(object.x+30, object.y-50, Obstacle) == 1
            {
                BotReverse()
            }
            else
            {
                jump = 1
            }
        }

        if position_meeting(object.x+50, object.y+30, Obstacle) == 0
        {
            if position_meeting(object.x+28, object.y+30, Obstacle) == 1
            {
                jump = 1
            }
        }
    }
    else
    {
        if position_meeting(object.x-30, object.y, Obstacle) == 1
        {
            if position_meeting(object.x-30, object.y-50, Obstacle) == 1
            {
                BotReverse()
            }
            else
            {
                jump = 1
            }
        }

        if position_meeting(object.x-50, object.y+30, Obstacle) == 0
        {
            if position_meeting(object.x-28, object.y+30, Obstacle) == 1
            {
                jump = 1
            }
        }
    }

    if last_x == object.x// and last_y == object.y // We can always try without...
    {
        jump = 1
    }
}
