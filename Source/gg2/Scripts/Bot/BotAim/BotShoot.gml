if point_distance(nearestTarget.x, nearestTarget.y, object.x, object.y) < 300 and (!followingHuman or target_in_sight) and class != CLASS_MEDIC
{
    BotFighting = 1
}
