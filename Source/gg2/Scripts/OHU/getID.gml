// Returns a free player ID; no arguments.
var number, foundNumber;
number = round(random(1000));
foundNumber = 0;

while !foundNumber
{
    foundNumber = 1
    with Player
    {
        if real(ID) == number
        {
            number = round(random(1000));
            foundNumber = 0
            break
        }
    }
}

if number < 10
{
    return "00"+string(number);
}
else if number < 100
{
    return "0"+string(number);
}
else
{
    return string(number);
}
