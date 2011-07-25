build = 0 //This is to record the Engineer building sentries.

BotGetTarget() //Aim

BotFollowHuman() //Get the nearest friendly human

if reverse_alarm!=0
{
    reverse_alarm -= 1
}

if nearestTarget == -1 and BotFighting
{
    BotFighting = 0
    BotInit()
}

if BotFighting == 1 or class == CLASS_SPY
{
    if random(7)<2
    {
        jump = 1
    }

    if class == CLASS_SCOUT or class == CLASS_SOLDIER or class == CLASS_HEAVY or class == CLASS_ENGINEER
    {
        BotFight()
    }
    else if class == CLASS_PYRO
    {
        PyroFight()
    }
    else if class == CLASS_SNIPER
    {
        SniperFight()
    }
    
    if BotFighting and target_in_sight and class == CLASS_ENGINEER and object.nutsNBolts >= 100 and collision_circle(object.x, object.y, 50, Sentry, false, true) < 0
    {
        //Create Sentry. This is a bit complicated to simulate because the menu is what registers the key. So I'm sending the bytes manually.
        //See BotPlayer user event 14
        
        //Destroy it first
        if sentry != -1
        {
            build = -1
        }
        else
        {
            build = 1
        }
    }
}
else if followingHuman == 1
{
    if nearestFriend.hspeed > 0
    {
        direction_ = 'right'
    }
    else if nearestFriend.hspeed < 0
    {
        direction_ = 'left'
    }
    else
    {
        if sign(object.x-nearestFriend.x) == 1
        {
            direction_ = 'left'
        }
        else
        {
            direction_ = 'right'
        }
    }
    reverse = 0
    
    if nearestFriend.vspeed < -5 //If the human is jumping; jump as well.
    {
        jump = 1
    }
}
else
{
/*    if instance_exists(ControlPoint) //We're on a cp map.
    {
        BotControlPoint()
    }

    else*/ if instance_exists(IntelligenceBaseBlue) //We're on a ctf map. Why Blu? Random.
    {
        BotIntel()
    }
    
    else if instance_exists(GeneratorHUD) // Gen map
    {
        BotGen()
    }
    
    else if instance_exists(ArenaHUD)
    {
        BotArena()
    }
    
    else //unknown map mode: just go to the enemy and kill stuff
    {
        if team == TEAM_RED
        {
            target = SpawnPointBlue
        }
        else
        {
            target = SpawnPointRed
        }
    }
    
    if target.x > object.x and bot_decide_first_time = 1 //direction is referring to the direction I want to go. Red wants to go right.
    {
        direction_ = "right"
        bot_decide_first_time = 0 //This checks that it only chooses the direction once at spawn and that's it.
        if global.currentMap == "ctf_2dfort"
        {
            ctf_2dfort_n() //Get nodes. Later on this will find out which map and go there.
        }
    }
    else if bot_decide_first_time = 1
    {
        direction_ = "left"
        bot_decide_first_time = 0
        if global.currentMap == "ctf_2dfort"
        {
            ctf_2dfort_n() //Get nodes. Later on this will find out which map and go there.
        }
    }

    if variable_local_exists("nodes_red")
    {
        BotMove()
    }
}

if reverse_alarm!=0
{
    reverse_alarm -= 1
}

BotAutonomousMove()

if class == CLASS_PYRO// Airblasting
{
    with Rocket
    {
        if team == other.team //I only want to calculate enemy rockets.
        {
            continue;
        }
    
        if point_distance(x, y, other.object.x, other.object.y) < 150// 150=airblast range.
        {
            hs = other.object.x-x
            vs = other.object.y-y
            distance = sqrt(power(hs, 2)+power(vs, 2));

            factor = 13/distance //13=rocket_speed;
        
            hs *= factor //normalize the rocket-me vector, multiply it with 13 to make it the same length as the rocket speed, and compare the hspeed and vspeed.
            vs *= factor
        
            if distance > 42 and abs(hs-hspeed) < 5 and abs(vs-vspeed) < 5 //42=flamethrower_length; And I couldn't come up with something better to test whether the rocket is going to hit you.
            {
                //airblast
                other.RMB = 1
                aimDirection = point_direction(other.object.x, other.object.y, x, y)
                other.LMB = 0
            }
        }
    }
}

if (direction_ == "left" and reverse == 0) or (direction_ == "right" and reverse == 1)
{
    left = 1
    right = 0
}
else
{
    right = 1
    left = 0
}

last_x = object.x
last_y = object.y
