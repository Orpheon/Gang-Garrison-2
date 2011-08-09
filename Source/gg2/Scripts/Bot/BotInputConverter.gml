// If you want to make your own bot off this, you need to define these 6 values:
left = 0
right = 0
jump = 0
LMB = 0
RMB = 0
aimDirection = 0
bubbleHP = 0

BotMain();

if pressed
{
    jump = 0
    pressed = !pressed
}
else if jump
{
    pressed = !pressed
}

keybyte = 0 //keybyte converter. Simple as shit.

if left == 1
{
keybyte |= $40
}

if right == 1
{
keybyte |= $20
}

if jump == 1
{
keybyte |= $80
}

if LMB == 1
{
keybyte |= $10
}

if RMB == 1
{
keybyte |= $08
}

if bubbleHP
{
keybyte |= $04
}
return keybyte
