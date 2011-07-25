// This is the special Demoman aiming script.
// I cut a few corners here, because calculating it exactly would mean a x^4 term.
// I'm not even going to try to explain it with comments.

// g = gravity of sticky = 0.2
g = 0.2
// Sticky speed = 12


//This is to get the sin size:

sin_answer = (nearestTarget.y-object.y-(g/2)*sqr((nearestTarget.x-object.x)/(1-nearestTarget.hspeed)))/((nearestTarget.x-object.x)/(1-nearestTarget.hspeed))*12
sin_answer = radtodeg(arcsin(sin_answer))


// This is to get the cos size.

a = object.y - nearestTarget.y
b = (2*nearestTarget.y*nearestTarget.hspeed - 2*object.y*nearestTarget.hspeed + nearestTarget.x - object.x)
c = (g*(nearestTarget.x-object.x))/2 + object.y*sqr(nearestTarget.hspeed) - nearestTarget.y*sqr(nearestTarget.hspeed) - nearestTarget.hspeed*(nearestTarget.x-object.x)

answer1 = (-b - sqrt(sqr(b)-4*a*c))/(2*a)
answer2 = (-b + sqrt(sqr(b)-4*a*c))/(2*a)

// Getting which of the two cos solutions is faster, therefore better.
time1 = (nearestTarget.x-object.x)/(answer1-nearestTarget.hspeed)
time2 = (nearestTarget.x-object.x)/(answer2-nearestTarget.hspeed)

if time1 < time2
{
    cos_answer = answer1
}
else
{
    cos_answer = answer2
}

// Sticky speed = 12.
cos_answer /= 12

cos_answer = radtodeg(arccos(cos_answer))

final_answer = sin_answer-((sin_answer-cos_answer)/2)

return final_answer
