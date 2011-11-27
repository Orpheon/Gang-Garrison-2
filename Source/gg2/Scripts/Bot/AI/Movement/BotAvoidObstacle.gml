// This script tells the bot to jump when there is a crate in front, and to reverse direction when faced with an unsurmountable wall.

with object
{
    other.yOffset = sprite_height-sprite_yoffset
}

if collision_point(object.x, object.y+yOffset+3, Obstacle, 1, 0) > 0// Only do something if you're touching the ground
{
    if collision_point(object.x+15*dir, object.y, Obstacle, 1, 0) > 0// Is there ground in front of us at waist-height?
    {
        if collision_point(object.x+15*dir, object.y-40, Obstacle, 1, 0) > 0// Is there also a wall too high to jump over for us?
        {
            dir *= -1// Change direction
        }
        else
        {
            jump = 1
        }
    }
}

if oldX-2 <= object.x and oldX+2 >= object.x and object.cappingPoint == noone// If you're at the same place as last frame
{
    stuckTimer -= 1// Start the "stuck" alarm (see BotMain)
}
else
{
    stuckTimer = 0
}
