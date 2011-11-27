// argument0 == source node

ds_list_clear(directionList)

targetNode = FindNearestNode(target.x, target.y, argument0)
directionList = FindNodePath(argument0, targetNode)
