pressed = 0

target = -1

aimModifier = 0

isHealing = 0
patient = -1

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

oldX = 0
oldY = 0

reloadCounter = 0

// Task selecting

task = choose("roam", "roam", "roam", "objective", "hunt")
// tasks possible: hunt (search enemies and kill them); roam (just wander around killing everyone you meet); and objective (capture the flag/point ignoring any enemies)
// roam has priority over everything else.

if class == CLASS_MEDIC
{
    task = 'roam'
}
