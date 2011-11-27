// Gets a pair of coordinates and tries to find the closest node.
// argument0=xpos; argument1=ypos; argument2=source node

var xpos, ypos, list, source, node;

xpos = argument0
ypos = argument1
source = argument2

list = ds_priority_create()

for(i=0; i<ds_list_size(source.network); i+=1)
{
    node = ds_list_find_value(source.network, i)
    ds_priority_add(list, node, point_distance(xpos, ypos, node.x, node.y))
}

var nearestNode;

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
