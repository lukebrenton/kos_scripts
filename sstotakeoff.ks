CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
clearGuis().
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
// *************************************F******************************* //

function showmessage {
  parameter message.
  clearscreen.
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
  print message.
  print " ".
}

showMessage("Flight instructions and checklist here. Click confirm.").
set disclaimerRead to false.
LOCAL confirm_gui IS GUI(200).
set confirm_gui:y to 600.
set confirm_gui:x to 850.
LOCAL confirm_button TO confirm_gui:ADDBUTTON("CONFIRM").
confirm_gui:SHOW().
SET confirm_button:ONCLICK TO {set disclaimerRead to true.}.

wait until disclaimerRead.
confirm_gui:HIDE().
confirm_gui:DISPOSE().
print("Program commencing...").
wait 1.

set setupFinished to false.

showMessage("Initial pitch: " + initial_pitch + ". Target Apoapsis: " + target_apoapsis).

LOCAL takeoff_gui IS GUI(200).
set takeoff_gui:y to 600.
set takeoff_gui:x to 850.
LOCAL initial_pitch_label TO takeoff_gui:ADDLABEL("Initial pitch:").
LOCAL initial_pitch_textfield TO takeoff_gui:ADDTEXTFIELD(initial_pitch:tostring).
LOCAL target_apoapsis_label TO takeoff_gui:ADDLABEL("Target apoapsis:").
LOCAL target_apoapsis_textfield TO takeoff_gui:ADDTEXTFIELD(target_apoapsis:tostring).
LOCAL confirm_button TO takeoff_gui:ADDBUTTON("CONFIRM").
takeoff_gui:SHOW().
set initial_pitch_textfield:ONCHANGE to {
    parameter str.
    set initial_pitch to str:toscalar.
    showMessage("Initial pitch: " + initial_pitch + ". Target Apoapsis: " + target_apoapsis).
}.
set target_apoapsis_textfield:ONCHANGE to {
    parameter str.
    set target_apoapsis to str:toscalar.
    showMessage("Initial pitch: " + initial_pitch + ". Target Apoapsis: " + target_apoapsis).
}.
SET confirm_button:ONCLICK TO {set setupFinished to true.}.

wait until setupFinished.
takeoff_gui:HIDE().
takeoff_gui:DISPOSE().
print("Program commencing...").
wait 1.
 
showMessage("Initiating launch.").

set airborn to 100.
 
// Countdown
ShowMessage("IGNITION IN... T-").
from {local countdown is 5.} until countdown = 0 step {set countdown to countdown - 1.} do {
    showMessage(countdown).
    wait 1.0.
}
showMessage("0").
wait 0.2.
lock THROTTLE to 1.0.
showMessage("*** IGNITION ***").
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
showMessage("V1.").
until SHIP:VELOCITY:SURFACE:MAG > v2_speed {
    wait 0.1.
}
showMessage("Rotate").
lock STEERING to HEADING(90, takeoff_pitch).
until SHIP:ALTITUDE > airborn {
    wait 0.1.
}
showMessage("Gear up.").
GEAR off.






// *** Initial climb ***
//
//
//
//
showMessage("Setting initial climb pitch.").
lock STEERING to HEADING(90, initial_pitch).






// *** Speed gain ***
//
//
//
//

until SHIP:ALTITUDE > target_altitude {
    wait 0.1.
}
showMessage("Pitching down for speed gain.").
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
showMessage("Switching rapiers to closed cycle and closing air intakes.").
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
			showMessage("Pitching prograde.").
			set apo_higher_than_50000 to true.
		}
		
	}

	if SHIP:OXIDIZER = 0 {
		if (oxidiser_out = false) {
			showMessage("All oxidizer consumed. Switching rapiers off.").
			shutdownRapiers().
			set oxidiser_out to true.
		}

	}
	wait 0.1.
}
lock throttle to 0.
showMessage("Apoapsis reached. Preparing to circularize. DO NOT USE TIME SKIP.").
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
showMessage("Topping up the apoapsis.").
until (SHIP:APOAPSIS > target_apoapsis) {
    wait 0.1.
}
lock throttle to 0.
showMessage("Apoapsis topped up.").

// *** Circularize burn ***
// wait till you get out of the atmosphere 
// before creating the node
//
//

until SHIP:altitude > 69000 {
    wait 0.1.
}
if not hasnode {
    set m_time to TIME:SECONDS + ETA:APOAPSIS.
    set v0 to velocityat(SHIP,m_time):ORBIT:MAG.
    set v1 to sqrt(BODY:MU/(BODY:RADIUS + APOAPSIS)).
    set CIRCULARIZE to node(m_time, 0, 0, v1 - v0).
    add CIRCULARIZE.
}
wait 1.
lock max_acc to SHIP:MAXTHRUST / SHIP:MASS.
lock burn_duration to CIRCULARIZE:DELTAV:MAG / max_acc.
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
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.

SAS ON.
UNLOCK STEERING.
UNLOCK THROTTLE.
// make sure to unlock steering from the node before removing it
// it causes errors.
remove CIRCULARIZE.


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
wait 3.
reboot.
 
 
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
	    showMessage("Activating nukes.").
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
