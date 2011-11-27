///////////
//HEALING//
///////////

//CHECK CURRENT HEALING TARGET//

//out of sight or meet obstacle in the healing beam
if patient != -1
{
    if point_distance(object.x, object.y, patient.x, patient.y)>300
    or collision_line(object.x, object.y, patient.x, patient.y, Obstacle, true, true) > 0
    or patient.cloak
    {
        patient = -1;
    }
}

if patient != object.currentWeapon.healTarget and isHealing
{
    isHealing = 0
}

//target is dead
if patient == -1 and isHealing
{
    isHealing=0;
}
else if patient != -1 and !isHealing
{
    // You've just chosen a new target
    isHealing = 1
}

//FINDING BEST TARGET//

with Character
{
    if team == other.team and id!=other.object
    and distance_to_object(other.object) <= 300 //in range of healing
    and !cloak
    and (player.class != CLASS_MEDIC or hp < 40)
    and (!ubered or healer == other.id)
    and healer == -1//target is not healed, dont steal patient, it's not effective
    {
        if other.patient == -1//no target yet:pick one
        {
            other.patient = id;
            other.isHealing=0;
        }
        else
        {
            if ((hp/maxHp)*1.5 < (other.patient.hp/other.patient.maxHp)//i am more hurt (*1.5 to prevent switching target every step)
            or (other.patient.hp/other.patient.maxHp == 1 and hp < maxHp))//he/she is fully healed
            and collision_line(other.object.currentWeapon.x, other.object.currentWeapon.y, x, y, Obstacle, true, true) <= 0
            {
                other.patient = id;
                other.isHealing=0;
                exit;
            }
        }
    }
}

if patient != -1
{
    if isHealing// I'm supposed to heal
    {
        aimDirection = point_direction(object.x,object.y,patient.x,patient.y);
        LMB = 1;
    }
}

///////////////////
//MOVEMENT+COMBAT//
///////////////////

//NORMAL MOVING//

//i am not healing
if !isHealing
{
    //there are no targets
    if patient == -1
    {
        //Enemies:
        if nearestEnemy!=-1 and !object.currentWeapon.ubering
        {
            if (point_distance(object.x,object.y,nearestEnemy.x,nearestEnemy.y)<350 or object.hp<30)
            and !collision_line(object.x,object.y,nearestEnemy.x,nearestEnemy.y,Obstacle,true,true)//i can see him
            {
                if task != 'objective'
                {
                    //run away
                    if object.x > nearestEnemy.x
                        dir = 1;
                    if object.x < nearestEnemy.x
                        dir =- 1;
                }

                //shooting
                if point_distance(object.x,object.y,nearestEnemy.x,nearestEnemy.y)<300 and
                (collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,Obstacle,true,true)<0
                && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,TeamGate,true,true)<0
                && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,ControlPointSetupGate,true,true)<0
                && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,IntelGate,true,true)<0
                && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,BulletWall,true,true)<0)
                && !nearestEnemy.ubered
                {
                    RMB=1;
                }
            }
        }
    }
}

//FOLLOWING//
if patient != -1 and isHealing
{
    if point_distance(object.x, object.y, patient.x, patient.y) < 150// Pulled 150 out of the air, correct if necessary.
    {
        if task != 'objective'
        {
            //follow him
            if object.x > patient.x
                dir=-1;
            if object.x < patient.x
                dir=1;
        }
    }
    //oh wait,an enemy is nearer,run!
    if nearestEnemy != -1 and !object.currentWeapon.ubering
    {
        if point_distance(object.x,object.y,nearestEnemy.x,nearestEnemy.y)<=point_distance(object.x,object.y,patient.x,patient.y)+50
        {
            if task != 'objective'
            {
                //run away
                if object.x > nearestEnemy.x
                    dir = 1;
                if object.x < nearestEnemy.x
                    dir =- 1;
            }

            //shoot!(this make medic a bit too aggressive,maybe decrease 250 to 150? idk you choose) -Gangsterman
            // I think I see why you used the okToShoot, sorry that I removed it :/.
            // Also, gave a check of the patients current hp instead of not healing medics and spies. -Orpheon
            if point_distance(object.x,object.y,nearestEnemy.x,nearestEnemy.y)<250
            and patient.hp > 50
            and point_distance(object.x,object.y,nearestEnemy.x,nearestEnemy.y)<300
            && (collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,Obstacle,true,true)<0
            && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,TeamGate,true,true)<0
            && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,ControlPointSetupGate,true,true)<0
            && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,IntelGate,true,true)<0
            && collision_line(object.x,object.y,predictedEnemy_x,predictedEnemy_y,BulletWall,true,true)<0)
            && !nearestEnemy.ubered
            {
                RMB=1;
            }
        }
    }
}


////////
//UBER//
////////

//i am healing and not ubering and my ubercharge is ready and not being ubering
if !object.currentWeapon.ubering and object.currentWeapon.uberReady and !object.ubered
{
    //i am healing someone
    if isHealing
    {
        // Replaced percentages by absolute values for this, correct if necessary. -Orpheon
        if patient.hp < 30//my patient is going to die
        or object.hp < 30//or me
        {
            LMB=1;
            RMB=1;
        }
    }
    //or not...
    else
    {
        if object.hp < 25//i am really in danger
        {
            LMB=1;
            RMB=1;
        }
    }
}
