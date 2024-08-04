RUNONCEPATH("0:/lib/lib_safe.ks").
RUNONCEPATH("0:/lib/lib_text.ks").
RUNONCEPATH("0:/lib/lib_engines.ks", "all").
RUNONCEPATH("0:/lib/lib_pid").

SET runway_longitude TO -74.724166870117.
set destination_longitude to runway_longitude-0.05.
set destination_altitude to 100.
set reentry_pitch to 30.
set initial_reentry_heading to 90.
set glide_slope_cruise_speed to 350.
SET runway_latitude TO -0.048591406236738.

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

if ADDONS:TR:AVAILABLE {
    // set setupFinished to false.
    // showMessage("Degrees from runway to initiate deorbit burn burn set to: " + deg_from_runway + ". Press UP or DOWN arrow to adjust in degrees. Press RETURN to begin deorbit program.").
    // LOCAL setup_gui IS GUI(200).
    // set setup_gui:y to 600.
    // set setup_gui:x to 850.
    // LOCAL deg_label TO setup_gui:ADDLABEL("Degrees from runway:").
    // LOCAL deg_textfield TO setup_gui:ADDTEXTFIELD(deg_from_runway:tostring).
    // LOCAL confirm_button TO setup_gui:ADDBUTTON("CONFIRM").
    // setup_gui:SHOW().
    // set deg_textfield:ONCHANGE to {
    //     parameter str.
    //     set deg_from_runway to str:toscalar.
    //     showMessage("Degrees from runway: " + deg_from_runway).
    // }.
    // SET confirm_button:ONCLICK TO {set setupFinished to true.}.

    // wait until setupFinished.

    // setup_gui:HIDE().
    // setup_gui:DISPOSE().
    // clearscreen.
    // print("De-orbit program commencing...").
    // wait 3.

    reEntry(
        reentry_pitch,
        initial_reentry_heading,
        glide_slope_cruise_speed,
        destination_longitude,
        destination_altitude
    ).
    clearscreen.
    lock throttle to 0.
    unlock steering.
    unlock throttle.
    SAFE_QUIT().
    reboot.

} else {
    showMessage("Trajectories is not available. Returning to main menu.").
    lock throttle to 0.
    unlock steering.
    unlock throttle.
    SAFE_QUIT().
    wait 3.
    reboot.
}


// functions
function reEntry {
    parameter reentry_pitch.
    parameter initial_reentry_heading.
    parameter glide_slope_cruise_speed.
    parameter destination_longitude.
    parameter destination_altitude.

    // initial re-entry slope
    showMessage("Preparing for re-entry. Please fasten your seatbelts.").
    wait 3.
    SAFE_TAKEOVER().
    INTAKES off.
    BRAKES on. // (includes air-brakes)
    lock STEERING to Heading(initial_reentry_heading, reentry_pitch).

    set reentry_complete to false.
    LOCAL reentry_gui IS GUI(200).
    set reentry_gui:y to 600.
    set reentry_gui:x to 850.
    LOCAL pitch_up_button TO reentry_gui:ADDBUTTON("Pitch up").
    LOCAL pitch_down_button TO reentry_gui:ADDBUTTON("Pitch down").
    LOCAL end_program_button TO reentry_gui:ADDBUTTON("End program").
    reentry_gui:SHOW().
    SET pitch_up_button:ONCLICK TO {set reentry_pitch to reentry_pitch+1.}.
    SET pitch_down_button:ONCLICK TO {set reentry_pitch to reentry_pitch-1.}.
    SET end_program_button:ONCLICK TO {
        reboot.
    }.

    until reentry_complete {
        showMessage("Re-entry pitch set to: " + reentry_pitch).
        wait 0.5.
        if (SHIP:Velocity:Surface:MAG < 1000) {
            set reentry_complete to true.
        }.
    }

    reentry_gui:HIDE().
    reentry_gui:DISPOSE().
    clearscreen.
    print("Re-entry program complete. Entering glide-slope.").
    wait 2.







    // when not on fire
    
    INTAKES on.
    BRAKES off.
    RapierSet(true). // airbreathing mode
    EngineSet(rapiers, true).
    EngineSet(jets, true).
    showMessage("Reentry complete.  Aiming for KSC.").
    LOCK direction_to_ksc TO 75/(runway_longitude - ship:longitude)*(SHIP:Latitude - runway_latitude) + 90.
    lock STEERING to Heading(direction_to_ksc, reentry_pitch).

    // set up slope between current position and the destination
	set glideSlope to (destination_altitude - SHIP:Altitude) / (destination_longitude - ship:longitude).
	lock target_altitude to glideSlope * (ship:longitude - destination_longitude) + destination_altitude.

    // use pid to manage pitch
    // set pid to PID_init(0.03,0.01,0.5,-25,25).
    set pid to PID_init(0.10,0.016,0.15,-15,15).
    lock ship_altitude to ship:altitude.
    until ship:longitude > destination_longitude {
        lock THROTTLE TO ((glide_slope_cruise_speed - Ship:Velocity:Surface:MAG) / 50).
        set pid_pitch to PID_seek (pid, target_altitude, SHIP:Altitude).
        lock STEERING to Heading(direction_to_ksc, pid_pitch).
        clearscreen.
        print "current longitude: " + ship_altitude.
        print ship_altitude < 1000.
        print "current longitude: " + ship:longitude.
        Print "Lat Err:    " + round((SHIP:Latitude - runway_latitude),4).
        print "target pitch: " + pid_pitch.
        print "target altitude: " + target_altitude.
        print "altitude error: " + round((SHIP:Altitude - target_altitude),4).
        if ship_altitude < 5000 {
            autoBrake(200).
            set glide_slope_cruise_speed to 200.
        }
        if ship_altitude < 2000 {
            autoBrake(120).
            set glide_slope_cruise_speed to 120.
        }
        if ship_altitude < 1000 {
            break.
        }
        wait 0.1.
	}
    clearscreen.
    showMessage("Glide complete. Controls released. Please land safely.").
    lock throttle to 0.
    unlock steering.
    unlock throttle.
    SAFE_QUIT().
    reboot.
}

function showmessage {
  parameter message.
  clearscreen.
  print "**************************************************".
  print "**                                              **".
  print "**                                              **".
  print "**            SSTO Re-entry Program v0.1        **".
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

function autoBrake {
    parameter speed.
	if Ship:Velocity:Surface:MAG > speed {
        brakes on.
	} else {
        brakes off.
	}
}

function showInstructions {
    clearscreen.
    print "**************************************************".
    print "**                                              **".
    print "**                                              **".
    print "**            SSTO Re-entry Program v0.1        **".
    print "**                                              **".
    print "**                                              **".
    print "**               (c)        2021                **".
    print "**                License: GPLv3                **".
    print "**                                              **".
    print "**                                              **".
    print "**************************************************".
    print " ".
    print "Please make sure you have the Trajectories addon.".

}