var positions, size, X, Y;

positions[] = 0;
size = 0;

for (Y=0; Y<map_height()-1; Y+=1)// Generate a node in all possible floor pixels
{
    for (X=0; X<map_width()-1; X+=1)
    {
        if !position_meeting(X, Y, Obstacle) and position_meeting(X, Y+1, Obstacle)
        {
            positions[size, 0] = X;
            positions[size, 1] = Y;
            size += 1;
        }
    }
}

var inRow, i, nodeList, newNode, node;
inRow = 0;
nodeList = ds_list_create();

for(i=0; i<size; i+=1)// Get rid of all those that are in a horizontal row, save the edges.
{
    if !inRow// The beginning of a row
    {
        newNode = instance_create(positions[i, 0], positions[i, 1], Node);
        ds_list_add(nodeList, newNode);
        inRow = 1;
    }
    else if i < size-1
    {
        if positions[i, 0]+1 != positions[i+1, 0] or positions[i, 1] != positions[i+1, 1]// If this is the last node
        {
            newNode = instance_create(positions[i, 0], positions[i, 1], Node);
            ds_list_add(nodeList, newNode);
            inRow = 0;
        }
    }
    else// The last node in the list
    {
        newNode = instance_create(positions[i, 0], positions[i, 1], Node);
        ds_list_add(nodeList, newNode);
        inRow = 0;
    }
}

for(i=0; i<ds_list_size(nodeList); i+=1)// Get rid of long stairs, save the edges (again). Also get rid of any in a spawnroom
{
    node = ds_list_find_value(nodeList, i)
    
    if collision_circle(node.x, node.y, 5, SpawnRoom, 1, 1)
    {
        with node
        {
            ds_list_delete(nodeList, ds_list_find_index(nodeList, id))
            instance_destroy()
        }
        continue
    }
    
    // Remove one-step stairs

    newNode = instance_position(node.x-6, node.y+6, Node)// Top-right to Bottom-left stairs first.
    while newNode
    {
        X = newNode.x
        Y = newNode.y

        with newNode
        {
            ds_list_delete(nodeList, ds_list_find_index(nodeList, id))
            instance_destroy()
        }
        
        newNode = instance_position(X-6, Y+6, Node)

        if newNode
        {
            if !instance_position(newNode.x-6, newNode.y+6, Node)// If the next node is the last one, spare it
            {
                break;
            }
        }
    }
    
    newNode = instance_position(node.x+6, node.y+6, Node)// Top-left to Bottom-right stairs.
    while newNode
    {
        X = newNode.x;
        Y = newNode.y;

        with newNode
        {
            ds_list_delete(nodeList, ds_list_find_index(nodeList, id));
            instance_destroy();
        }
        
        newNode = instance_position(X+6, Y+6, Node);

        if newNode
        {
            if !instance_position(newNode.x+6, newNode.y+6, Node)// If the next node is the last one, spare it
            {
                break;
            }
        }
    }
    
    
    // Remove double stairs
    
    newNode = instance_position(node.x-12, node.y+6, Node)// Top-right to Bottom-left stairs first.
    while newNode
    {
        X = newNode.x
        Y = newNode.y

        with newNode
        {
            ds_list_delete(nodeList, ds_list_find_index(nodeList, id))
            instance_destroy()
        }
        
        newNode = instance_position(X-12, Y+6, Node)

        if newNode
        {
            if !instance_position(newNode.x-12, newNode.y+6, Node)// If the next node is the last one, spare it
            {
                break;
            }
        }
    }
    
    newNode = instance_position(node.x+12, node.y+6, Node)// Top-left to Bottom-right stairs.
    while newNode
    {
        X = newNode.x;
        Y = newNode.y;

        with newNode
        {
            ds_list_delete(nodeList, ds_list_find_index(nodeList, id));
            instance_destroy();
        }
        
        newNode = instance_position(X+12, Y+6, Node);

        if newNode
        {
            if !instance_position(newNode.x+12, newNode.y+6, Node)// If the next node is the last one, spare it
            {
                break;
            }
        }
    }
}

for(i=0; i<ds_list_size(nodeList); i+=1)// Remove nodes almost directly underneath another node.
{
    node = ds_list_find_value(nodeList, i);
    
    for(a=i; a<ds_list_size(nodeList); a+=1)
    {
        newNode = ds_list_find_value(nodeList, a)
        if abs(newNode.x-node.x) == 1 and point_distance(newNode.x, newNode.y, node.x, node.y) <= 40
        {
            if collision_line(newNode.x, newNode.y, node.x-sign(node.x-newNode.x), node.y, Obstacle, 1, 1) <= 0
            {
                with newNode
                {
                    ds_list_delete(nodeList, ds_list_find_index(nodeList, id));
                    instance_destroy();
                }
            }
        }
    }
}

for(i=0; i<ds_list_size(nodeList); i+=1)// Move nodes up, and remove any nodes that can't do that.
{
    node = ds_list_find_value(nodeList, i);
    
    if collision_line(node.x, node.y, node.x, node.y-30, Obstacle, 1, 1) > 0
    {
        with node
        {
            ds_list_delete(nodeList, ds_list_find_index(nodeList, id));
            instance_destroy();
        }
    }
    /*else
    {
        node.y -= 30
    }*/
}

ds_list_destroy(nodeList)
