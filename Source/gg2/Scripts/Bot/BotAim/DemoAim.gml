if point_distance(object.x, object.y, nearestTarget.x, nearestTarget.y) < 800
{
/* A short explanation of this code:

Lets call the shot angle alpha. Because the speed of the sticky is =12, we can say that the vertical speed of the sticky is sin(alpha)*12
If then we use the physics formula for accelerating objects(new_x = x + v*t + a*(1/2)*t^2):

nearestTarget.y = object.y + sin(alpha)*12*time + -0.2*(1/2)*time^2

You then change it to time=stuff; and you have a formula to calculate t out of the angle.

Then, you make:

nearestTarget.x + nearestTarget.hspeed*time = cos(angle)*12*time

Enter the previous formula in time, and you have the monster which holds the solution(s).


The problem is that his becomes an x^4 term, which is an annoyance.
This is why I make an assumtion:

Say we had a guess that is almost true, and we're missing a tiny correction angle.

If we also said that u=sin(this_tiny_angle); then normally cos(this_tiny_angle) = sqrt(1-u^2). Since u must be ridiculously small, we can assume that cos(tiny_angle) = 1

This reduces the formula to a much-easier-to-manage quadratic formula.

Since we said that the correction angle has to be really small, we can go further and say that the whole quadratic bit just falls out.

This is then iterated until a very small correction angle is found
*/

    g = 0.2// Gravity
    v = 12// Sticky speed
    wx = nearestTarget.hspeed
    dx = nearestTarget.x-object.x
    dy = nearestTarget.y-object.y

    if nearestTarget.x >= object.x// Now I'm guessing the angle
    {
        if nearestTarget.y >= object.y
        {
            beta = degtorad(45)
        }
        else
        {
            beta = degtorad(340)
        }
    }
    else
    {
        if nearestTarget.y >= object.y
        {
            beta = degtorad(135)
        }
        else
        {
            beta = degtorad(200)
        }
    }

    timer = 30// To avoid infinite loops, which do happen sometimes.
    do// Correct the angle with an approx. until the correction is small enough (0.2 deg)
    {
        p = wx-v*cos(beta)
        q = v*sin(beta)
        r = -v*sin(beta)
        s = v*cos(beta)

        b = (((-p*s)-(q*r))*dx - (2*r*s*dy))

        c = (1/2)*g*power(dx, 2) - p*r*dx + power(r, 2)*dy

        answer1 = -c/b

        beta = answer1+beta
        timer -= 1
    }
    until abs(radtodeg(answer1)) <= 0.2 or timer <= 0

    return radtodeg(beta)
}
else// Don't lag if not necessary. Only try to calculate it if target is in range.
{
    if nearestTarget.x > object.x
    {
        return 0
    }
    else
    {
        return 180
    }
}
