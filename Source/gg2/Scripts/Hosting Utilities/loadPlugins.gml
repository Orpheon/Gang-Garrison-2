plugin = file_find_first("Plugins/*.spy", 0)

if plugin == ""
{
    print("No Plugins found")
}
else
{
    while plugin != ""
    {
        execute_file("Plugins/"+string(plugin))
        print("Loaded "+string_copy(string(plugin), 0, string_length(string(plugin))-4)+" plugin successfully.")
        plugin = file_find_next()
    }
}
