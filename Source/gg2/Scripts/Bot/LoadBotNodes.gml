with Node
{
    // Destroy all old nodes
    instance_destroy()
}

// Open a node file and load new ones
if !file_exists(string(global.currentMap)+"_botMap.ini")
{
    exit
}

ini_open(string(global.currentMap)+"_botMap.ini")

var numOfNodes, node, xPos, yPos, numOfConnections;

numOfNodes = ini_read_real("Nodes:", "Number Of Nodes", 0)

nodeList = ds_list_create()

for (i=0; i<numOfNodes; i+=1)
{
    xPos = ini_read_real("Node"+string(i), "xPos", 0)
    yPos = ini_read_real("Node"+string(i), "yPos", 0)

    node = instance_create(xPos, yPos, Node)
    
    ds_list_add(nodeList, node)
}

for (i=0; i<ds_list_size(nodeList); i+=1)
{
    node = ds_list_find_value(nodeList, i)
    
    numOfConnections = ini_read_real("Node"+string(i), "NumOfConnections", 0)
    
    for (a=0; a<numOfConnections; a+=1)
    {
        ds_list_add(node.connections, ds_list_find_value(nodeList, ini_read_real("Node"+string(i), "ID"+string(a), 0)))
        ds_list_add(node.commands, ini_read_real("Node"+string(i), "Command"+string(a), 0))
        ds_list_add(node.distance, ini_read_real("Node"+string(i), "Dist"+string(a), 0))
    }
}



ds_list_destroy(nodeList)

ini_close()
