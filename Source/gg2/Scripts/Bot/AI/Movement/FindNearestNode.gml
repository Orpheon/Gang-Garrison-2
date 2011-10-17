// Gets a pair of coordinates and tries to find the closest node.
// argument0=xpos; argument1=ypos

var xpos, ypos, list;

xpos = argument0
ypos = argument1

list = ds_priority_create()

with Node
{
    ds_priority_add(list, id, point_distance(xpos, ypos, x, y))
}

var node, nearestNode;

nearestNode = ds_priority_find_min(list)

while !ds_priority_empty(list)
{
    node = ds_priority_delete_min(list)
    if collision_line(node.x, node.y, xpos, ypos, Obstacle, 1, 1) < 0
    {
        return node
    }
}
return nearestNode
