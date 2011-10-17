var foundCP;
foundCP = false// This is for A/D blu

with ControlPoint
{
    if !locked and team != other.team
    {
        other.target = id
        foundCP = true
        break;
    }
}

if !foundCP
{
    task = 'hunt'
    target = -1
}
