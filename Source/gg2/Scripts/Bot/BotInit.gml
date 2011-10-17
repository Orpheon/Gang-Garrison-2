pressed = 0

target = -1

aimModifier = 0

if variable_local_exists("directionList")
{
    ds_list_clear(directionList)
}
else
{
    directionList = ds_list_create()
}

wasFighting = 0

dir = 1

stuckTimer = 0

oldX = object.x
oldY = object.y

// Task selecting

task = 'roam'// tasks possible: hunt (search enemies and kill them); roam (just wander around killing everyone you meet); and objective (capture the flag/point ignoring any enemies)

if (class == CLASS_SCOUT and random(10)<4) or random(20)<4
{
    task = 'objective'
}

if random(10)<6
{
    task = 'hunt'
}
