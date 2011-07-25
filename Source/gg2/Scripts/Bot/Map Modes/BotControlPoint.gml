target = instance_nearest(object.x, object.y, ControlPoint);

if (target.locked)
{
    if (ControlPoint1.locked==0) {target=ControlPoint1}
    else if (target=ControlPoint1 && ControlPoint2.locked==0) {target=ControlPoint2}
    else if (target=ControlPoint2 && ControlPoint3.locked==0) {target=ControlPoint3}
    else if (target=ControlPoint3 && ControlPoint4.locked==0) {target=ControlPoint4}
    else if (target=ControlPoint4 && ControlPoint5.locked==0) {target=ControlPoint5}
}


//if (target.locked == 1){target = ControlPoint1;}
//if (target.locked == 1){target = ControlPoint2;}
//if (target.locked == 1){target = ControlPoint3;}
//if (target.locked == 1){target = ControlPoint4;}
//if (target.locked == 1){target = ControlPoint5;}
