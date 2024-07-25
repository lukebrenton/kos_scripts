CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
CLEARSCREEN.
print " ".
print "**************************************************".
print "**                                              **".
print "**                                              **".
print "**            SSTO Launch-script v0.1           **".
print "**                                              **".
print "**                                              **".
print "**               (c)        2021                **".
print "**                License: GPLv3                **".
print "**                                              **".
print "**                                              **".
print "**************************************************".
print " ".
print " ".
 
// ******************************************************************** //
// ********************** VARIABLE-DECLARATIONS *********************** //
// ******************************************************************** //
 
// Runway v1 in m/s - The speed beyond which takeoff should no longer be aborted
set v1_speed to 80.

// Runway takeoff in m/s - Safe takeoff speed
set v2_speed to 110.
 
// Takeoff pitch
set takeoff_pitch to 15.
 
// Initial ascent in pitch-degrees (0m - target_altitude) (must be greater than takeoff pitch)
set initial_pitch to 25.
 
// Target altitude in m to gain speed (must be above 1500m!)
set target_altitude to 10000.

// Speed gain pitch
set speed_gain_pitch to 12.

// Maximum target apoapsis height
set target_apoapsis to 100000.
 
// ******************************************************************** //
// *** SCRIPT - DO NOT MODIFY UNLESS YOU KNOW WHAT YOU ARE DOING ;) *** //
// ******************************************************************** //

 
print "Initiating launch.".
 
print " ".
 
set airborn to 100.
 
// Countdown
print "IGNITION IN... T-".
from {local countdown is 5.} until countdown = 0 step {set countdown to countdown - 1.} do {
    print countdown + " " at (17,16).
    wait 1.0.
}
print 0 + " " AT (17,16).
wait 0.2.
lock THROTTLE to 1.0.
print "*** IGNITION ***".
startRapiers().
 

// *** Runway & Take off ***
//
//
//
//
set initialPitch to 90 - vectorangle(UP:VECTOR, SHIP:FACING:FOREVECTOR).
lock STEERING to HEADING(90.42, initialPitch). // Runway seems to be a bit off 90 degrees
 
until SHIP:VELOCITY:SURFACE:MAG > v1_speed {
    wait 0.1.
}
print "V1.".
until SHIP:VELOCITY:SURFACE:MAG > v2_speed {
    wait 0.1.
}
print "V2.".
print "Rotate.".
lock STEERING to HEADING(90, takeoff_pitch).
until SHIP:ALTITUDE > airborn {
    wait 0.1.
}
print "Gear up.".
GEAR off.






// *** Initial climb ***
//
//
//
//
print "Setting initial climb pitch.".
lock STEERING to HEADING(90, initial_pitch).






// *** Speed gain ***
//
//
//
//

until SHIP:ALTITUDE > target_altitude {
    wait 0.1.
}
print "Pitching down for speed gain.".
lock STEERING to HEADING(90, speed_gain_pitch).





// *** Activate nukes or closed cycle rapiers ***
//
//
//
//
set nukes_active to false.
until (getTWR() < 0.5 and nukes_active) {
    wait 0.1.
	if (getTWR() < 0.5 and not nukes_active) {
	    activateNukes().
		set nukes_active to true.
	}
}
if (not nukes_active) {
	activateNukes().
	set nukes_active to True.
	wait 1.
}
print "Switching rapiers to closed cycle and closing air intakes.".
toogleRapierMode().
toggle INTAKES.
wait 1.


// *** Apoapsis reached ***
//
//
//
//
set apo_higher_than_50000 to false.
set oxidiser_out to false.
until (SHIP:APOAPSIS > target_apoapsis) {
	// *** Aim prograde to reach orbital velocity ***
	//
	//
	//
	if SHIP:APOAPSIS > 50000 {
		if (apo_higher_than_50000 = false) {
			lock STEERING to SHIP:PROGRADE.
			print "Pitching prograde.".
			set apo_higher_than_50000 to true.
		}
		
	}

	if SHIP:OXIDIZER = 0 {
		if (oxidiser_out = false) {
			print "All oxidizer consumed. Switching rapiers off.".
			shutdownRapiers().
			set oxidiser_out to true.
		}

	}
	wait 0.1.
}
lock throttle to 0.
print "Apoapsis reached. Preparing to circularize".
SET WARPMODE TO "RAILS".
SET WARP TO 3. //50X

// *** Topping up the apoapsis ***
//
//
//
//

until SHIP:altitude > 68000 {
    wait 0.1.
}
SET WARP TO 0. //50X
lock throttle to 0.5.
print "Topping up the apoapsis.".
until (SHIP:APOAPSIS > target_apoapsis) {
    wait 0.1.
}
lock throttle to 0.
print "Apoapsis topped up.".

// *** Circularize burn ***
// wait till you get out of the atmosphere 
// before creating the node
//
//

until SHIP:altitude > 70000 {
    wait 0.1.
}
if not hasnode {
    set m_time to TIME:SECONDS + ETA:APOAPSIS.
    set v0 to velocityat(SHIP,m_time):ORBIT:MAG.
    set v1 to sqrt(BODY:MU/(BODY:RADIUS + APOAPSIS)).
    set CIRCULARIZE to node(m_time, 0, 0, v1 - v0).
    add CIRCULARIZE.
}
lock max_acc to SHIP:MAXTHRUST / SHIP:MASS.
lock burn_duration to CIRCULARIZE:DELTAV:MAG / max_acc.

SET WARPMODE TO "RAILS".
SET WARP TO 3. //50X
wait until CIRCULARIZE:ETA < burn_duration * 2.
SET WARP TO 0. //50X
lock STEERING to CIRCULARIZE:DELTAV:DIRECTION.



// stage the burn down gradually to avoid under or over shooting
wait until CIRCULARIZE:ETA < burn_duration * 0.5.
lock throttle to 1.
wait until CIRCULARIZE:DELTAV:MAG < 10.
lock throttle to 0.5.
wait until CIRCULARIZE:DELTAV:MAG < 5.
lock throttle to 0.2.
wait until CIRCULARIZE:DELTAV:MAG < 2.
lock throttle to 0.1.

wait until CIRCULARIZE:DELTAV:MAG < 0.1.
lock throttle to 0.

remove CIRCULARIZE.

SAS ON.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
 
 
CLEARSCREEN.
print "**************************************************".
print "**                                              **".
print "**            >>> Orbit achieved <<<            **".
print "**           >>> Congratulations <<<            **".
print "**                                              **". 
print "**                                              **".
print "**                                              **".
print "**                                              **".
print "**           Transferring control back          **".
print "**                    V-_-                      **".
print "**                                              **".
print "**                                              **".
print "**                      _                       **".
print "**                     / \                      **".
print "**                    |.-.|                     **".
print "**                    |   |                     **".
print "**                    |   |                     **".
print "**                    | L |                     **".
print "**                  _ | E | _                   **".
print "**                 / \| O |/ \                  **".
print "**                |   | L |   |                 **".
print "**                |   | I |   |                 **".
print "**               ,'   | 6 |   '.                **".
print "**             ,' |   |   |   | `.              **".
print "**           .'___|___|_ _|___|___'.            **".
print "**                 /_\ /_\ /_\                  **".
print "**                  6   6   6                   **".
print "**                .'6   6   6'.                 **".
print "**              ;;; 6   6   6 ;;;               **".
print "**                                              **".
print "**                                              **".
print "**                                              **".
print "**************************************************".
print " ".
 
 
declare function getTWR
{
    set mth to SHIP:MAXTHRUST. // (depends on fixed kOS issue 940)
    set r to SHIP:ALTITUDE+SHIP:BODY:RADIUS.
    set w to SHIP:MASS * SHIP:BODY:MU / r / r.
	//print mth/w AT (1,1).
 
    return mth/w.
}
 
declare function activateNukes
{
    set count to 0.
	LIST ENGINES IN engines.
	FOR eng IN engines {
	    IF eng:Name:CONTAINS("nuclearEngine") {
		    eng:ACTIVATE().
			set count to count + 1.
		}
    }.
	IF count > 0 {
	    print "Activating nukes.".
	}
}
 
declare function deactivateNukes
{
    LIST ENGINES IN engines.
	FOR eng IN engines {
	    IF eng:Name:CONTAINS("nuclearEngine") {
		    eng:SHUTDOWN().
		}
    }.
}
 
declare function toogleRapierMode
{
    LIST ENGINES IN engines.
	FOR eng IN engines {
	    IF eng:Name:CONTAINS("RAPIER") {
		    eng:TOGGLEMODE().
		}
    }.
}

declare function startRapiers
{
    LIST ENGINES IN engines.
	FOR eng IN engines {
	    IF eng:Name:CONTAINS("RAPIER") {
			if eng:mode = "ClosedCycle" {
				eng:togglemode().
			}
		    eng:ACTIVATE().
		}
    }.
}

declare function shutdownRapiers
{
    LIST ENGINES IN engines.
	FOR eng IN engines {
	    IF eng:Name:CONTAINS("RAPIER") {
			if eng:mode = "AirBreathing" {
				eng:togglemode().
			}
		    eng:SHUTDOWN().
		}
    }.
}

declare function getOxidizerAmount {
    FOR resource IN SHIP:resources {
	    IF resource:Name:CONTAINS("oxidizer") {
		    print resource:amount.
		}
    }
}
 