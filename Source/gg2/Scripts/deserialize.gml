var numInstances, newInstance;
with(argument0) {
    instance_destroy();
}
numInstances = read_ushort(global.socketBuffer);
repeat(numInstances) {
    newInstance = instance_create(0,0,argument0);
    with(newInstance) {
        event_user(11);
    }
}
