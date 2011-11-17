// Takes user input and tries to guess what it is.
// argument0 = user input string

// First step: Parse the arguments
var numOfCommands, parseString, pos;
numOfCommands = 0;
input = 0;
parseString = argument0;

while string_count("-", parseString) > 0
{
    pos = string_pos("-", parseString)-2;// -1 for the space before the '-'

    input[numOfCommands] = string_copy(parseString, 0, pos);
    numOfCommands += 1;

    parseString = string_copy(parseString, pos+3, string_length(parseString));
}
input[numOfCommands] = parseString// For the last argument, there's no '-' left.
numOfCommands += 1

while numOfCommands <= 10// Fill up until 10 arguments, that way there are no errors.
{
    input[numOfCommands] = ""
    numOfCommands += 1
}

if string_copy(input[0], 0, 5) == "help "
{
    input[1] = string_copy(input[0], 6, string_length(input[0]));
    input[0] = "help"
}


// Second step: Find out what command it is and execute it.

if ds_map_exists(global.commandDict, input[0])
{
    execute_string(ds_map_find_value(global.commandDict, input[0]));
}
else
{
    print("Unknown command; type help for a list of them.")
    print("Remember to add arguments with a '-' in front, like 'kick -254'.")
}

print('');
