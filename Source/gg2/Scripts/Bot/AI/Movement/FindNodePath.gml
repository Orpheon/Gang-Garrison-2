// Given a source and a target node, returns the shortest node path to get there.
// argument0=source node, argument1=target node


var source, target, unvisited, node, newNode;

unvisited = ds_priority_create()
source = argument0
target = argument1

if source == target
{
    return ds_list_create()
}

// Network is the list of all nodes you can get to from source.
for (i=0; i<ds_list_size(source.network); i+=1)
{
    with ds_list_find_value(source.network, i)
    {
        ds_priority_add(unvisited, id, point_distance(x, y, source.x, source.y)+power(map_width(), 2)*power(map_height(), 2))// Big big big number. No real node distance is going to be bigger than this.
    
        ds_list_clear(history)
    
        dist = point_distance(x, y, source.x, source.y)+power(map_width(), 2)*power(map_height(), 2)
    }
}
node = source

ds_priority_delete_value(unvisited, source)

source.dist = 0

while true
{
    ds_list_add(node.history, node)

    if node == target
    {
        break
    }

    for (i=0; i<ds_list_size(node.connections); i+=1)
    {
        newNode = ds_list_find_value(node.connections, i)
        
        if node.dist+ds_list_find_value(node.distance, i) < newNode.dist
        {
//            show_message(node.dist)
//            show_message(ds_list_size(node.history))
            ds_list_clear(newNode.history)
            ds_list_copy(newNode.history, node.history)
            
            newNode.dist = node.dist+ds_list_find_value(node.distance, i)
            ds_priority_change_priority(unvisited, newNode, newNode.dist)
        }
    }
    
//    if ds_priority_size(unvisited) mod 10 == 0 show_message(string(ds_priority_size(unvisited))+"; x="+string(node.x)+"; y="+string(node.y)+"; dist="+string(node.dist)+"; size of list="+string(ds_list_size(node.history)))

    if ds_priority_size(unvisited) <= 0
    {
        return ds_list_create();
    }

    node = ds_priority_delete_min(unvisited)
}

// node == target
ds_list_add(node.history, node)

// node.history == List of nodes that must in turn be passed to get to the target node.
return node.history
