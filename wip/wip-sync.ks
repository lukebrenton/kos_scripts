parameter apoapsis_reference_point.
parameter orbit_iterations.
if (hasTarget) {
    until false {
        if apoapsis_reference_point = "periapsis" {
            set ship_reference_point to ship:ORBIT:ETA:PERIAPSIS.
            set target_reference_point to target:ORBIT:ETA:PERIAPSIS.
        } else {
            set ship_reference_point to ship:ORBIT:ETA:APOAPSIS.
            set target_reference_point to target:ORBIT:ETA:APOAPSIS.
        }
        set distances to getDistances().
        set smallest to getSmallestDistance(distances).
        clearscreen.
        showClosestDistance(smallest).
        printInfo(smallest).
        showAllDistances(distances).
        wait 0.1.
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
        print "Dmin: " + round(abs(dtmin)).
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

    function showClosestDistance {
        parameter smallest.
        print "*************************".
        print "Closest orbit: " + smallest[0] + " at " + smallest[1] + "km separation.".
        print "Distance: " + round(target:distance, 2).
        // print "Target velocity: " + target:Velocity:orbit.
        // print "Ship velocity  : " + SHIP:Velocity:orbit.
        print "Rvel: " + round(TARGET:VELOCITY:ORBIT:mag - SHIP:VELOCITY:ORBIT:mag, 2).
        print "*************************".
    }

    function showAllDistances {
        parameter distances.
        for dist in distances {
            print dist[0] + ": " + dist[1] + "km".
        }
    }

    function getDistances {
        set distances to List().
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
            distances:add(List(x, separation, future_time)).
        }
        return distances.
    }

    function getSmallestDistance {
        parameter distances.
        set smallest to distances[0].
        FROM {local x is 0.} UNTIL x = distances:length STEP {set x to x+1.} DO {
            if distances[x][1] < smallest[1] {
                set smallest to distances[x].
            }
        }
        return smallest.
    }
} else {
    print "You do not have a target. Please select a target before using this tool.".
}