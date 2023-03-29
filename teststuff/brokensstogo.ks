CLEARSCREEN.
PRINT " ".
PRINT "**************************************************".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**            SSTO Launch-script v0.1           **".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**               (c)        2021                **".
PRINT "**                License: GPLv3                **".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**************************************************".
PRINT " ".
PRINT " ".
 
// ******************************************************************** //
// ********************** VARIABLE-DECLARATIONS *********************** //
// ******************************************************************** //
 
// Enable/Disable engine pre-heating
SET engine_preheating TO False.
 
// Enable/Disable auto-closing of air-intakes
SET toggle_intakes TO False.
 
// Runway takeoff in m/s
SET takeoff_speed TO 110.
 
// Takeoff pitch
SET takeoff_pitch TO 15.
 
// Initial ascent in pitch-degrees (0m - target_altitude) (must be greater than takeoff pitch)
SET initial_pitch TO 25.
 
// Target altitude in m to gain speed (must be above 1500m!)
SET target_altitude TO 10000.
 
// Target maximum speed in m/s at the altitude defined above
SET target_speed TO 1200.
 
// Final ascent in pitch-degrees (~target_altitude - 70k)
SET final_pitch TO 30.
 
// Maximum target apoapsis height
SET max_apoapsis TO 100000.
 
// Minimum target periapsis height
SET min_periapsis TO 71000.
 
// ******************************************************************** //
// *** SCRIPT - DO NOT MODIFY UNLESS YOU KNOW WHAT YOU ARE DOING ;) *** //
// ******************************************************************** //
 
 
PRINT "Initiating launch.".
 
PRINT " ".
 
SET airborn TO 100.
SET safe_alt TO 1500.
SET current_target_pitch TO 7.
 
IF engine_preheating {
    BRAKES ON.
}
 
// Countdown
PRINT "IGNITION IN... T-".
FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT countdown + " " AT (17,16).
    WAIT 1.0. // pauses the script here for 1 second.
}
PRINT 0 + " " AT (17,16).
WAIT 0.2.
 
// Let's roll
 
LOCK THROTTLE TO 1.0.
PRINT " ".
PRINT "*** IGNITION ***".
PRINT " ".
STAGE.
 
IF engine_preheating {
    // Pre-heating engines
    WAIT 10.
    BRAKES OFF.
} ELSE {
    BRAKES OFF.
}
 
set initialPitch to 90 - vectorangle(UP:VECTOR, SHIP:FACING:FOREVECTOR).
LOCK STEERING TO HEADING(90.42, initialPitch). // Runway seems to be a bit off 90 degrees
 
// Waiting for takeoff speed and configuring steering
UNTIL SHIP:VELOCITY:SURFACE:MAG > takeoff_speed {
    WAIT 0.1. // just trying not to fry your actual (physical) CPU
}
 
PRINT "Takeoff.".
//SET DEFAULT_PITCH TO North + R(30,90,-90).
SET DEFAULT_PITCH TO HEADING(90, 30).
 
// Trying to get off the runway
SET current_target_pitch TO takeoff_pitch.
LOCK STEERING TO HEADING(90, current_target_pitch).
 
 
UNTIL SHIP:ALTITUDE > airborn {
    WAIT 0.1. // just trying not to fry your actual (physical) CPU
}
GEAR OFF.
 
// Disable nukes
deactivateNukes().
 
PRINT "Starting to gradually adjust pitch from " + ROUND(takeoff_pitch, 1) + " to " + initial_pitch.
 
SET previous_target_pitch TO current_target_pitch.
SET start_alt TO SHIP:ALTITUDE.
SET target_pitch TO initial_pitch - takeoff_pitch.
UNTIL SHIP:ALTITUDE > safe_alt {
    SET distance_to_ground TO (SHIP:ALTITUDE - start_alt).
    SET temp TO distance_to_ground / (safe_alt - start_alt).
 
    SET current_target_pitch TO previous_target_pitch + (target_pitch * temp).
    LOCK STEERING TO HEADING(90, current_target_pitch).
    PRINT ROUND(current_target_pitch,1) AT (40,21).
    WAIT 0.1. // just trying not to fry your actual (physical) CPU
}
 
// Waiting until we reach our 'travel-altitude' and lock steering to horizon
UNTIL SHIP:APOAPSIS > target_altitude {
    WAIT 0.1. // just trying not to fry your actual (physical) CPU
}
PRINT " ".
PRINT "Target altitude of " + target_altitude + "m reached.".
PRINT "Pitching down to gain speed.".
PRINT "Please fasten your seatbelts!".
PRINT " ".
 
IF(SHIP:VELOCITY:SURFACE:MAG < 0.8 * target_speed) {
    // Wait until we reach the maximum athmospheric speed the SSTO can handle
    SET target_vertical_speed TO 10.
    UNTIL SHIP:VELOCITY:SURFACE:MAG > target_speed {
        // Allow a small drain of vertical speed (10% per tick)
        SET tmp_vertical_speed TO SHIP:VERTICALSPEED - (SHIP:VERTICALSPEED / 10).
        WAIT 0.1.
        IF (SHIP:VERTICALSPEED > target_vertical_speed AND tmp_vertical_speed < SHIP:VERTICALSPEED AND current_target_pitch > 5) {
            // Too fast going up - need to pitch further down
            //PRINT "Pitching down" + current_target_pitch AT (10,26).
            SET current_target_pitch TO current_target_pitch - 0.1.
            LOCK STEERING TO HEADING(90, current_target_pitch).
        } ELSE IF (SHIP:VERTICALSPEED < 0 AND tmp_vertical_speed > SHIP:VERTICALSPEED) {
            // Losing altitude - Jeb we gotta pitch up!
            //PRINT "Pitching up  " + current_target_pitch AT (10,26).
            SET current_target_pitch TO current_target_pitch + 0.1.
            LOCK STEERING TO HEADING(90, current_target_pitch).
        } ELSE {
            //PRINT "Waiting...  " + current_target_pitch AT (10,26).
        }
    }
    PRINT " ".
    PRINT "Target speed of " + target_speed + "m/s reached.".
    PRINT "Pitching back up.".
} ELSE {
    PRINT " ".
    PRINT "Ship is already going close to the target speed of " + target_speed + "m/s.".
    PRINT "Adjusting pitch for final ascent.".
 
    UNTIL (current_target_pitch < (final_pitch + 0.1)) {
        SET current_target_pitch TO current_target_pitch - 0.1.
        LOCK STEERING TO HEADING(90, current_target_pitch).
        WAIT 0.1.
    }
}
 
// After that we will slowly pitch back up...
// over the course of gaining 10000m altitude... this may not be the best idea as reference but it kinda works so... #dontCare (yet)
SET safe_alt TO SHIP:ALTITUDE + 10000.
SET start_alt TO SHIP:ALTITUDE.
SET new_target_pitch TO final_pitch.
SET target_pitch_diff TO new_target_pitch - current_target_pitch.
UNTIL SHIP:ALTITUDE > safe_alt OR current_target_pitch >= new_target_pitch  {
    SET distance_to_ground TO (SHIP:ALTITUDE - start_alt).
    SET temp TO distance_to_ground / (safe_alt - start_alt).
    SET current_target_pitch TO current_target_pitch + (target_pitch_diff * temp).
    LOCK STEERING TO HEADING(90, current_target_pitch).
    WAIT 0.1. // just trying not to fry your actual (physical) CPU
}
SET current_target_pitch TO new_target_pitch.
LOCK STEERING TO HEADING(90, current_target_pitch).
 
SET nukes_active TO False.
// Wait until we start losing speed and toggle engine modes (and close air intakes)
SET tmp_ground_speed TO SHIP:GROUNDSPEED.
UNTIL (getTWR() < 0.5 AND nukes_active) {
    SET tmp_ground_speed TO SHIP:GROUNDSPEED.
    WAIT 0.1. // just trying not to fry your actual (physical) CPU
	IF (getTWR() < 0.5 AND NOT nukes_active) {
	    activateNukes().
		SET nukes_active TO True.
	}
}
 
IF (NOT nukes_active) {
	activateNukes().
	SET nukes_active TO True.
	WAIT 1.
}
 
PRINT "Switching to closed cycle.".
toogleRapier().
WAIT 1.
 
IF toggle_intakes {
    PRINT "Closing air-intakes.".
    TOGGLE INTAKES.
}
 
// Wait until we are positive that we can make orbit - disable rocket engines
UNTIL SHIP:APOAPSIS > 65000 {
    WAIT 0.1. // just trying not to fry your actual (physical) CPU
}
 
// Switching the Rapier back to airbreathing. Since intakes are closed this effectively shuts them down
// If you can't make orbit move the 'TOGGLE AG3.' to line 156
// If you can't make orbit after moving the line below comment out the line 'LOCK STEERING TO SHIP:PROGRADE.' (or delete everything below and fly manual from here)
// This will be less efficient but gives you moar power and lets face it - efficeny is useless if we cant make orbit amirite?
//TOGGLE AG3.
 
PRINT " ".
PRINT "Suborbital trajectory almost established.".
PRINT "Pitching prograde.".
LOCK STEERING TO SHIP:PROGRADE.
 
// Wait until we are safely in orbit. Circularize is currently not supported... might add that later though
SET last_warp TO 0.
SET apo_peri_distance TO ETA:APOAPSIS - SHIP:PERIAPSIS.
//UNTIL (SHIP:APOAPSIS > 100000 OR apo_peri_distance < 500 OR (ETA:APOAPSIS - SHIP:PERIAPSIS > apo_peri_distance AND SHIP:PERIAPSIS > 72000) OR SHIP:CONTROL:PILOTMAINTHROTTLE = 0) {
UNTIL (SHIP:APOAPSIS > max_apoapsis OR SHIP:PERIAPSIS > min_periapsis) {
    SET tmp_eta_apoapsis TO ETA:APOAPSIS.
    SET apo_peri_distance TO ETA:APOAPSIS - SHIP:PERIAPSIS.
    WAIT 0.1. // just trying not to fry your actual (physical) CPU
    IF (SHIP:PERIAPSIS > min_periapsis AND ETA:APOAPSIS > 180 AND tmp_eta_apoapsis < ETA:APOAPSIS AND (last_warp = 0 OR last_warp < TIME - 30)) {
        AG4 OFF.
        WARPTO(ETA:APOAPSIS).
        AG4 ON.
    }
}
 
SAS ON.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
 
CLEARSCREEN.
 
PRINT "**************************************************".
PRINT "**                                              **".
IF SHIP:PERIAPSIS > 70000 {
    PRINT "**            >>> Orbit achieved <<<            **".
    //PRINT "**                                              **".
    IF apo_peri_distance > 1000 {
        PRINT "**          Please circularise on your own         **".
        //PRINT "**                                              **".
    }
    PRINT "**                                              **".
}
IF SHIP:APOAPSIS > max_apoapsis {
    PRINT "**       Target maximum apoapsis reached        **".
    //PRINT "**                                              **".
}
 
IF SHIP:PERIAPSIS < 70000 {
    PRINT "**                                              **".
    PRINT "**        >>> COULD NOT REACH ORBIT <<<         **".
    PRINT "**                                              **".
}
 
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**           Transferring control back          **".
PRINT "**                    V-_-                      **".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**                      _                       **".
PRINT "**                     / \                      **".
PRINT "**                    |.-.|                     **".
PRINT "**                    |   |                     **".
PRINT "**                    |   |                     **".
PRINT "**                    | L |                     **".
PRINT "**                  _ | E | _                   **".
PRINT "**                 / \| O |/ \                  **".
PRINT "**                |   | L |   |                 **".
PRINT "**                |   | I |   |                 **".
PRINT "**               ,'   | 6 |   '.                **".
PRINT "**             ,' |   |   |   | `.              **".
PRINT "**           .'___|___|_ _|___|___'.            **".
PRINT "**                 /_\ /_\ /_\                  **".
PRINT "**                  6   6   6                   **".
PRINT "**                .'6   6   6'.                 **".
PRINT "**              ;;; 6   6   6 ;;;               **".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**************************************************".
PRINT " ".
 
 
declare function getTWR
{
    set mth to SHIP:MAXTHRUST. // (depends on fixed kOS issue 940)
    set r to SHIP:ALTITUDE+SHIP:BODY:RADIUS.
    set w to SHIP:MASS * SHIP:BODY:MU / r / r.
	//PRINT mth/w AT (1,1).
 
    return mth/w.
}
 
declare function activateNukes
{
    SET count TO 0.
	LIST ENGINES IN engines.
	FOR eng IN engines {
	    IF eng:Name:CONTAINS("nuclearEngine") {
		    eng:ACTIVATE().
			SET count TO count + 1.
		}
    }.
	IF count > 0 {
	    PRINT " ".
	    PRINT "Activating nukes.".
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
 
declare function toogleRapier
{
    LIST ENGINES IN engines.
	FOR eng IN engines {
	    IF eng:Name:CONTAINS("RAPIER") {
		    eng:TOGGLEMODE().
		}
    }.
}
 