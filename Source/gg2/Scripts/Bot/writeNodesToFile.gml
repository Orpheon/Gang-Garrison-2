// Write all nodes to an ini file
var text, node, nodeList;

if file_exists(string(global.currentMap)+"_botMap.ini")
{
    file_delete(string(global.currentMap)+"_botMap.ini")
}

text = ini_open(string(global.currentMap)+"_botMap.ini")

ini_write_real("Nodes:", "Number Of Nodes", instance_number(Node))

nodeList = ds_list_create()
with Node
{
    ds_list_add(nodeList, id)
}

for(i=0; i<ds_list_size(nodeList); i+=1)
{
    node = ds_list_find_value(nodeList, i)
    
    ini_write_real("Node"+string(i), "xPos", node.x)    
    ini_write_real("Node"+string(i), "yPos", node.y)
    
    ini_write_real("Node"+string(i), "NumOfConnections", ds_list_size(node.connections))
    
    for (a=0; a<ds_list_size(node.connections); a+=1)
    {
        ini_write_real("Node"+string(i), "ID"+string(a), ds_list_find_index(nodeList, ds_list_find_value(node.connections, a)))
        ini_write_real("Node"+string(i), "Dist"+string(a), ds_list_find_value(node.distance, a))
        ini_write_real("Node"+string(i), "Command"+string(a), ds_list_find_value(node.commands, a))
    }
}

ds_list_destroy(nodeList)

ini_close()
