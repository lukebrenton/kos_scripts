parameter orbit_iterations is 15.
parameter rendezvous_point is "p".
set poll_interval to 1.
clearguis().

showInstructions().
set instructions_read to false.
LOCAL confirm_gui IS GUI(200).
set confirm_gui:y to 600.
set confirm_gui:x to 850.
LOCAL confirm_button TO confirm_gui:ADDBUTTON("CONFIRM").
confirm_gui:SHOW().
SET confirm_button:ONCLICK TO {set instructions_read to true.}.

wait until instructions_read.
confirm_gui:HIDE().
confirm_gui:DISPOSE().
clearscreen.
print("Program commencing...").
wait 3.

set sync_finished to false.
LOCAL sync_gui IS GUI(200).
set sync_gui:y to 600.
set sync_gui:x to 850.
LOCAL change_rendezvous_point TO sync_gui:ADDBUTTON("Change rendezvous point").
LOCAL poll_interval_label TO sync_gui:ADDLABEL("Poll interval:").
LOCAL poll_interval_textfield TO sync_gui:ADDTEXTFIELD(poll_interval:tostring).
LOCAL orbit_iterations_label TO sync_gui:ADDLABEL("Orbit iterations:").
LOCAL orbit_iterations_textfield TO sync_gui:ADDTEXTFIELD(orbit_iterations:tostring).
LOCAL back_to_menu TO sync_gui:ADDBUTTON("Back to menu").
sync_gui:SHOW().
SET change_rendezvous_point:ONCLICK TO {
    if (rendezvous_point = "p") {
        set rendezvous_point to "a".
    } else {
        set rendezvous_point to "p".
    }
}.
set poll_interval_textfield:ONCHANGE to {
    parameter str.
    if (str:length > 0) {
        set poll_interval to str:toscalar.
    }
}.
set orbit_iterations_textfield:ONCHANGE to {
    parameter str.
    set orbit_iterations to str:toscalar.
}.
SET back_to_menu:ONCLICK TO {set sync_finished to true.}.

if (hasTarget) {
    until sync_finished {
        if rendezvous_point = "p" {
            set ship_reference_point to ship:ORBIT:ETA:PERIAPSIS.
        } else {
            set ship_reference_point to ship:ORBIT:ETA:APOAPSIS.
        }
        set orbits to getOrbits().
        set bestOrbit to getBestOrbit(orbits).
        clearscreen.
        showClosestOrbitInfo(bestOrbit).
        showAllOrbits(orbits). 
        wait poll_interval.
    }
} else {
    print "You do not have a target. Please select a target before using this tool.".
    print "Returning to main menu...".
    wait 3.
}

sync_gui:HIDE().
sync_gui:DISPOSE().
clearscreen.
print "Returning to main menu...".
wait 3.
reboot.

function formatTime {
    parameter totalSeconds.

    local secondsPerMinute is 60.
    local secondsPerHour is secondsPerMinute * 60.
    local secondsPerDay is secondsPerHour * kuniverse:hoursperday. // KSP days are 6 hours long

    // Calculate days, hours, minutes, and seconds
    local days is floor(totalSeconds / secondsPerDay).
    set totalSeconds to totalSeconds - (days * secondsPerDay).

    local hours is floor(totalSeconds / secondsPerHour).
    set totalSeconds to totalSeconds - (hours * secondsPerHour).

    local minutes is floor(totalSeconds / secondsPerMinute).
    set totalSeconds to totalSeconds - (minutes * secondsPerMinute).

    local seconds is totalSeconds.

    // Function to add leading zero if necessary
    function addLeadingZero {
        parameter num.
        if num < 10 {
            return "0" + num.
        } else {
            return num:toString().
        }
    }

    // Format the values with leading zeros
    local daysStr is addLeadingZero(days).
    local hoursStr is addLeadingZero(hours).
    local minutesStr is addLeadingZero(minutes).
    local secondsStr is addLeadingZero(seconds).

    // Combine into the final formatted string
    local formattedTime is daysStr + ":" + hoursStr + ":" + minutesStr + ":" + secondsStr.

    return formattedTime.
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

function showClosestOrbitInfo {
    parameter bestOrbit.
    clearscreen.
    print "**************************************************".
    print "**                                              **".
    print "**                                              **".
    print "**            SSTO Sync Orbit. v0.1             **".
    print "**                                              **".
    print "**                                              **".
    print "**               (c)        2021                **".
    print "**                License: GPLv3                **".
    print "**                                              **".
    print "**                                              **".
    print "**************************************************".
    print " ".
    print "TGT: " + target:name at (0, 11).
    if (rendezvous_point = "p") {
        print "RP: SHIP PERIAPSIS" at (32, 11).
    } else {
        print "RP: SHIP APOAPSIS" at (33, 11).
    }
    print ("Closest orbit: " + bestOrbit[0]) at (0, 12).
    print ("Separation: " + bestorbit[1] + "km") at (20, 12).
    print ("TTR: " + formatTime(round(bestorbit[2],0))) at (0, 13).
    print ("Distance: " + round(target:distance / 1000, 2) + "km") at (20, 13).
    // print "Rvel: " + round(TARGET:VELOCITY:ORBIT:mag - SHIP:VELOCITY:ORBIT:mag, 2).
    print "*************************" at (0, 14).
    print "".
    print "".
    print "".
}

function showInstructions {
    clearscreen.
    print "**************************************************".
    print "**                                              **".
    print "**                                              **".
    print "**            SSTO Sync Orbit. v0.1             **".
    print "**                                              **".
    print "**                                              **".
    print "**               (c)        2021                **".
    print "**                License: GPLv3                **".
    print "**                                              **".
    print "**                                              **".
    print "**************************************************".
    print " ".
    print "Set your Pe or Ap to the desired rendezvous".
    print "location. This is usually on the 'day' side of".
    print "the planet, matching the altitude of the target's".
    print "orbit".
    print " ".
    print "Then use this tool to calculate a 'good enough'".
    print "future orbit to rendezvous.".
    print " ".
    print "Use burns at the rendezvous location to tweak".
    print "the encounter.".

}

function showAllOrbits {
    parameter orbits.
    for oorbit in orbits {
        print (oorbit[0] + ": " + oorbit[1] + "km - " + round(oorbit[2], 0) + " seconds") at (0, 15+oorbit[0]).
    }
}

function getOrbits {
    set orbits to List().
    FROM {local x is 0.} UNTIL x = orbit_iterations STEP {set x to x+1.} DO {
        if x = 0 {
            set future_timestamp to TIME:SECONDS + ship_reference_point.
            set seconds_to_rendezvous to ship_reference_point.
        } else {
            set seconds to round(ship:obt:period * (x)).
            set future_timestamp to TIME:SECONDS + seconds + ship_reference_point.
            set seconds_to_rendezvous to seconds + ship_reference_point.
        }
        set future_target_position to POSITIONAT(TARGET, future_timestamp).
        set future_ship_position to POSITIONAT(SHIP, future_timestamp).



        // I can't work it out. shrug.
        // ///////////////////////////////////////////////////
        // // get the future orbit patches
        // set future_target_orbit to ORBITAT(TARGET, future_timestamp).
        // set future_ship_orbit to ORBITAT(SHIP, future_timestamp).

        // // Get the true anomalies
        // SET ship_true_anomaly TO future_ship_orbit:MEANANOMALYATEPOCH.
        // SET target_true_anomaly TO future_target_orbit:MEANANOMALYATEPOCH.

        // // Calculate the phase angle difference
        // set phase_angle to abs(target_true_anomaly - ship_true_anomaly).

        // ///////////////////////////////////////////

        
        set separation to round(abs((future_target_position - future_ship_position):mag) / 1000, 2).
        orbits:add(List(x, separation, seconds_to_rendezvous)).
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