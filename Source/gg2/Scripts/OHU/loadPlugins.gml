// Pretty much directly copy-pasted from Lorgan, loads every plugin it sees.

var pluginArray, plugin, first, PluginObject, i;
first = true;
pluginArray[0] = 1;

while (true) {
    if (first == true){
        plugin = file_find_first("Plugins/*.gml",0);
        first = false;
    }else{
        plugin = file_find_next();
    }
    if (plugin != "") {
        pluginArray[0]+=1;
        pluginArray[pluginArray[0]] = plugin;
    } else break;
} 
    
PluginObject = object_add();
for(i=2;i <= pluginArray[0];i+=1) {
    with (instance_create(0,0,PluginObject)) {
        execute_file("Plugins/"+string(pluginArray[i]),"Plugins/");
        instance_destroy();
    }
}
