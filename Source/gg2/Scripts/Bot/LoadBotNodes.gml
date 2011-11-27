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

var numOfNodes, node, newNode, xPos, yPos, numOfConnections;

numOfNodes = ini_read_real("Nodes:", "Number Of Nodes", 0)

nodeList = ds_list_create()

for (i=0; i<numOfNodes; i+=1)
{
    xPos = ini_read_real("Node"+string(i), "xPos", 0)
    yPos = ini_read_real("Node"+string(i), "yPos", 0)

    node = instance_create(xPos, yPos, Node)
    
    ds_list_add(nodeList, node)
    //ds_list_add(node.network, node)
}

for (i=0; i<ds_list_size(nodeList); i+=1)
{
    node = ds_list_find_value(nodeList, i)
    
    numOfConnections = ini_read_real("Node"+string(i), "NumOfConnections", 0)
    
    for (a=0; a<numOfConnections; a+=1)
    {
        newNode = ds_list_find_value(nodeList, ini_read_real("Node"+string(i), "ID"+string(a), 0))
        ds_list_add(node.connections, newNode)
        ds_list_add(node.commands, ini_read_real("Node"+string(i), "Command"+string(a), 0))
        ds_list_add(node.distance, ini_read_real("Node"+string(i), "Dist"+string(a), 0))
        
        var tempNode;
        
        /*for (e=0; e<ds_list_size(newNode.network); e+=1)
        {
            tempNode = ds_list_find_value(newNode.network, e)
            if ds_list_find_index(node.network, tempNode) < 0
            {
                for(r=0; r<ds_list_size(node.network); r+=1)
                {
                    ds_list_add((ds_list_find_value(node.network, r)).network, tempNode)
                }
            }
        }*/
    }
    
    for(a=0; a<numOfNodes; a+=1)
    {
        ds_list_add(node.network, ds_list_find_value(nodeList, a))
    }
}

ds_list_destroy(nodeList)

ini_close()
