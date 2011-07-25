//For Red
if team == TEAM_RED
{
    i = 0
    while i <= ds_list_size(red_node_counter) and direction_ = "right" //This checks every node and decides if I should jump.
    {
        if (object.x <= nodes_red[i,0]+5) and (object.x >= nodes_red[i,0]-5)
        {
            if (object.y <= nodes_red[i,1]+5) and (object.y >= nodes_red[i,1]-5)
            {
                jump = 1
            }
        }
    i +=1
    }

    i = 0
    while i <= ds_list_size(red_reverse_counter) and direction_ = "right" // This is the same thing, only for reverse
    {
        if (object.x <= reverse_red[i,0]+10) and (object.x >= reverse_red[i,0]-10)
        {
            if (object.y <= reverse_red[i,1]+10) and (object.y >= reverse_red[i,1]-10)
            {
                BotReverse()
            }
        }
        i +=1
    }

}

// Now for Blu
else
{
    i = 0
    while i <= ds_list_size(blue_node_counter) and direction_ = "left"
    {
        if (object.x <= nodes_blue[i,0]+10) and (object.x >= nodes_blue[i,0]-10)
        {
            if (object.y <= nodes_blue[i,1]+10) and (object.y >= nodes_blue[i,1]-10)
            {
                jump = 1
            }
        }
    i +=1
    }


    i = 0
    while i <= ds_list_size(blue_reverse_counter) and direction_ = "left"
    {
        if (object.x <= reverse_blue[i,0]+10) and (object.x >= reverse_blue[i,0]-10)
        {
            if (object.y <= reverse_blue[i,1]+10) and (object.y >= reverse_blue[i,1]-10)
            {
                BotReverse()
            }
        }
        i +=1
    }

}
