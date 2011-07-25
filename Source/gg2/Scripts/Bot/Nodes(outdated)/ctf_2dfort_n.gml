//Lists didn't work, so I'm using 2d arrays. The list is to count.

red_node_counter = ds_list_create()

nodes_red[0,0] = 646.74
nodes_red[0,1] = 906.42
//skip the first counter because index starts with 0

nodes_red[1,0] = 944.29
nodes_red[1,1] = 906.17
ds_list_add(red_node_counter, "a")

nodes_red[2,0] = 1967.86
nodes_red[2,1] = 1140.25
ds_list_add(red_node_counter, "a")

nodes_red[3,0] = 2459.10
nodes_red[3,1] = 1139.81
ds_list_add(red_node_counter, "a")

nodes_red[4,0] = 2727.97
nodes_red[4,1] = 1139.91
ds_list_add(red_node_counter, "a")

nodes_red[5,0] = 3336.73
nodes_red[5,1] = 984.36
ds_list_add(red_node_counter, "a")

nodes_red[6,0] = 3214.35
nodes_red[6,1] = 888.45
ds_list_add(red_node_counter, "a")

nodes_red[7,0] = 3321.90
nodes_red[7,1] = 815.51
ds_list_add(red_node_counter, "a")

nodes_red[8,0] = 376.54
nodes_red[8,1] = 702.19
ds_list_add(red_node_counter, "a")

nodes_red[9,0] = 747.06
nodes_red[9,1] = 648.29
ds_list_add(red_node_counter, "a")

nodes_red[10,0] = 1283.37
nodes_red[10,1] = 911.79
ds_list_add(red_node_counter, "a")

nodes_red[11,0] = 1274.35
nodes_red[11,1] = 912.47
ds_list_add(red_node_counter, "a")

nodes_red[12,0] = 848.00
nodes_red[12,1] = 1139.82
ds_list_add(red_node_counter, "a")

nodes_red[13,0] = 1342.74
nodes_red[13,1] = 1139.79
ds_list_add(red_node_counter, "a")

//Blue Nod

blue_node_counter = ds_list_create()

nodes_blue[0,0] = 2577.89
nodes_blue[0,1] = 1140.11

nodes_blue[1,0] = 2082.09
nodes_blue[1,1] = 1140.47
ds_list_add(blue_node_counter, "a")

nodes_blue[2,0] = 1461.67
nodes_blue[2,1] = 1140.30
ds_list_add(blue_node_counter, "a")

nodes_blue[3,0] = 683.87
nodes_blue[3,1] = 1139.85
ds_list_add(blue_node_counter, "a")

nodes_blue[4,0] = 81.57
nodes_blue[4,1] = 978.22
ds_list_add(blue_node_counter, "a")

nodes_blue[5,0] = 182.43
nodes_blue[5,1] = 912.09
ds_list_add(blue_node_counter, "a")

nodes_blue[6,0] = 103.86
nodes_blue[6,1] = 816.21
ds_list_add(blue_node_counter, "a")

nodes_blue[7,0] = 3058.14
nodes_blue[7,1] = 702.12
ds_list_add(blue_node_counter, "a")

nodes_blue[8,0] = 2678.67
nodes_blue[8,1] = 648.15
ds_list_add(blue_node_counter, "a")

nodes_blue[9,0] = 2144.31
nodes_blue[9,1] = 912.29
ds_list_add(blue_node_counter, "a")

nodes_blue[10,0] = 2772.09
nodes_blue[10,1] = 906
ds_list_add(blue_node_counter, "a")

nodes_blue[11,0] = 2464.90
nodes_blue[11,1] = 905.56
ds_list_add(blue_node_counter, "a")

nodes_blue[12,0] = 2144.37
nodes_blue[12,1] = 912.42
ds_list_add(blue_node_counter, "a")

/* One coordinate is missing;, must've missed it while noding; put it here:
pos = ds_list_create()
pos[0] = x
pos[1] = y
nodes_blue[0] = pos
*/

//Red Reverse
red_reverse_counter = ds_list_create()

reverse_red[0,0] = 774.60
reverse_red[0,1] = 971.86

reverse_red[1,0] = 639.48
reverse_red[1,1]= 1098.42
ds_list_add(red_reverse_counter, 'a')

reverse_red[2,0] = 3320.30
reverse_red[2,1] = 996.47
ds_list_add(red_reverse_counter, 'a')

reverse_red[3,0] = 3230.72
reverse_red[3,1] = 900.48
ds_list_add(red_reverse_counter, 'a')

reverse_red[4,0] = 3329.74
reverse_red[4,1] = 803.55
ds_list_add(red_reverse_counter, 'a')

//Blue Reverse
blue_reverse_counter = ds_list_create()

reverse_blue[0,0] = 2655.28
reverse_blue[0,1] = 984.15

reverse_blue[1,0] = 2776.22
reverse_blue[1,1] = 1098.30
ds_list_add(blue_reverse_counter, 'a')

reverse_blue[2,0] = 98.01
reverse_blue[2,1] = 990.07
ds_list_add(blue_reverse_counter, 'a')

reverse_blue[3,0] = 185.15
reverse_blue[3,1] = 905.69
ds_list_add(blue_reverse_counter, 'a')

reverse_blue[4,0] = 96.53
reverse_blue[4,1] = 810.27
ds_list_add(blue_reverse_counter, 'a')
