parameter apoapsis_reference_point.
parameter orbit_iterations.
global closest_approach_time to 9999999999.
if (hasTarget) {
    until false {
        if apoapsis_reference_point = "p" {
            set ship_reference_point to ship:ORBIT:ETA:PERIAPSIS.
            set target_reference_point to target:ORBIT:ETA:PERIAPSIS.
        } else {
            set ship_reference_point to ship:ORBIT:ETA:APOAPSIS.
            set target_reference_point to target:ORBIT:ETA:APOAPSIS.
        }
        set orbits to getOrbits().
        set bestOrbit to getBestOrbit(orbits).
        clearscreen.
        showClosestOrbitInfo(bestOrbit).
        printInfo(bestOrbit).
        showAllOrbits(orbits).
        // if bestOrbit[2] < closest_approach_time {
        //     set closest_approach_time to bestOrbit[2].
        //     wait 0.1.
        //     createNode(closest_approach_time).
        //     wait 0.1.
        //  }   
        wait 0.1.
    }
} else {
    print "You do not have a target. Please select a target before using this tool.".
}

function createNode {
    parameter timeToNode.
    if hasNode {
        set myNode to nextnode.
        remove myNode.
        wait 0.1.
    }
    if not hasnode {
        set v0 to velocityat(SHIP,timeToNode):ORBIT:MAG.
        set v1 to sqrt(BODY:MU/(BODY:RADIUS + APOAPSIS)).
        set CIRCULARIZE to node(timeToNode, 0, 0, v1 - v0).
        add CIRCULARIZE.
        wait 0.1.
    }
}

function printInfo {
    parameter smallest.
    set target_orbital_period to target:obt:period.
    set ship_orbital_period to ship:obt:period.
    // print smallest[0].
    // print target_orbital_period.
    // print ship_orbital_period.
    set tttr to TIME:SECONDS + (target_orbital_period * smallest[0]) + target_reference_point.
    set sttr to TIME:SECONDS + (ship_orbital_period * smallest[0]) + ship_reference_point.
    set dtMin to tttr - sttr.
    print "Target time to referece: " + round(tttr).
    print "Ship time to reference : " + round(sttr).
    print "Dmin: " + round(dtmin).
    print " ".


    // LOCAL s_pos IS positionat(SHIP, smallest[2]).
    // LOCAL t_pos IS positionat(TARGET, smallest[2]).

    // LOCAL s_normal IS VCRS(velocityAt(SHIP,smallest[2]):orbit,s_pos).
    // LOCAL s_t_cross IS VCRS(s_pos,t_pos).
    // LOCAL start_phi IS VANG(s_pos,t_pos).
    // IF VDOT(s_normal, s_t_cross) > 0 {
    //     SET start_phi TO 360 - start_phi.
    // }
    // print start_phi.
}

function showClosestOrbitInfo {
    parameter bestOrbit.
    print "*************************".
    print "Target: " + target:name.
    print "Closest orbit: " + bestorbit[0] + " at " + bestOrbit[1] + "km.".
    print "Current distace to target: " + round(target:distance / 1000, 2) + "km".
    // print "Rvel: " + round(TARGET:VELOCITY:ORBIT:mag - SHIP:VELOCITY:ORBIT:mag, 2).
    print "*************************".
}

function showAllOrbits {
    parameter orbits.
    for oorbit in orbits {
        print oorbit[0] + ": " + oorbit[1] + "km".
    }
}

function getOrbits {
    set orbits to List().
    FROM {local x is 0.} UNTIL x = orbit_iterations STEP {set x to x+1.} DO {
        if x = 0 {
            set future_time to TIME:SECONDS + ship_reference_point.
        } else {
            set seconds to round(ship:obt:period * (x)).
            set future_time to TIME:SECONDS + seconds + ship_reference_point.
        }
        set future_target_position to POSITIONAT(TARGET, future_time).
        set future_ship_position to POSITIONAT(SHIP, future_time).

        set separation to round(abs((future_target_position - future_ship_position):mag) / 1000, 2).
        orbits:add(List(x, separation, future_time)).
    }
    return orbits.
}

function getBestOrbit {
    parameter orbits.
    set bestOrbit to orbits[0].
    FROM {local x is 0.} UNTIL x = orbits:length STEP {set x to x+1.} DO {
        if orbits[x][1] < bestOrbit[1] {
            set bestOrbit to orbits[x].
        }
    }
    return bestOrbit.
}
function checkClosestApproachTime {
    parameter newNodeTime.
    parameter bestNodeTime.
    print newNodeTime.
    print bestNodeTime.
    print newNodeTime < bestNodeTime.
}