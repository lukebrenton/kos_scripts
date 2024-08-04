//Deorbit & landing script for SSTO spaceplanes, specifically the Ascension.
//File: deorbit.ks  From: https://github.com/lordcirth/kOS-Public

RUNONCEPATH("0:/lib/lib_safe.ks").
RUNONCEPATH("0:/lib/lib_text.ks").
RUNONCEPATH("0:/lib/lib_engines.ks", "all").
RUNONCEPATH("0:/lib/lib_pid").
// de-orbit
SET deg_from_runway TO 100. //93 // degrees from the runway to initiate the burn
SET runway_longitude TO -74.724166870117.
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
    set setupFinished to false.
    showMessage("Degrees from runway to initiate deorbit burn burn set to: " + deg_from_runway + ". Press UP or DOWN arrow to adjust in degrees. Press RETURN to begin deorbit program.").
    LOCAL setup_gui IS GUI(200).
    set setup_gui:y to 600.
    set setup_gui:x to 850.
    LOCAL deg_label TO setup_gui:ADDLABEL("Degrees from runway:").
    LOCAL deg_textfield TO setup_gui:ADDTEXTFIELD(deg_from_runway:tostring).
    LOCAL confirm_button TO setup_gui:ADDBUTTON("CONFIRM").
    setup_gui:SHOW().
    set deg_textfield:ONCHANGE to {
        parameter str.
        set deg_from_runway to str:toscalar.
        showMessage("Degrees from runway: " + deg_from_runway).
    }.
    SET confirm_button:ONCLICK TO {set setupFinished to true.}.

    wait until setupFinished.

    setup_gui:HIDE().
    setup_gui:DISPOSE().
    clearscreen.
    print("De-orbit program commencing...").
    wait 3.

    SET burn_longitude TO runway_longitude - deg_from_runway.
    if burn_longitude < -180 {
        set burn_longitude to burn_longitude + 360.
    }
    if SHIP:ORBIT:Inclination > 0.5 { 
	    showMessage("Ship inclination > 0.5. Aborting de-orbit. Make inclination lower before commencing de-orbit. Returning to main menu.").
        wait 3.
        reboot.
    } else {
        deOrbit(
            burn_longitude,
            runway_longitude,
            runway_latitude
        ).
        clearscreen.
        showMessage("De-orbit burn complete. Returning to main menu...").
        wait 3.
        reboot.
    }

} else {
    showMessage("Trajectories is not available. Returning to main menu.").
    wait 3.
    reboot.
}



// functions
function deOrbit {
    parameter burn_longitude.
    parameter runway_longitude.
    parameter runway_latitude.
    
    showMessage("Preparing to de-orbit. Make sure you have the correct engines activated.").
    wait 3.
    SAFE_TAKEOVER().
    set WARPMODE to "RAILS".
    set WARP to 3. //50X
    until abs(degreesToBurn()) < 7.5  {
        clearscreen.
        showMessage("Deorbit in: " + round(degreesToBurn(), 2) + " degrees").
        wait 0.5.
    }

    set WARP to 0.
    lock STEERING to RETROGRADE.  
    until VAng(SHIP:Facing:Vector, Retrograde:Vector) < 0.2
    and abs(degreesToBurn()) < 0.2 {
        clearscreen.
        showMessage("Deorbit in: " + round(degreesToBurn(), 2) + " degrees").
        WAIT 1.
    }

    clearscreen.
    showMessage("Deorbiting at: " + round((runway_longitude - ship:longitude),2) + " degrees from runway").
    LOCK THROTTLE TO 1.
    set landing_lng_correct to false.
    until landing_lng_correct {
        if ADDONS:TR:HASIMPACT {
            showMessage("Landing LNG: " + ADDONS:TR:IMPACTPOS:LNG).
            if (ADDONS:TR:IMPACTPOS:LNG < (runway_longitude-15)) {
                set landing_lng_correct to true.
            }
        } else {
            showMessage("No landing prediction.").
        }
        wait 0.5.
    }
    LOCK THROTTLE TO 0.
    UNLOCK STEERING.
    SAFE_QUIT().
}

function degreesToBurn {
    set currentLon to ship:longitude.
    set difference to burn_longitude - currentLon.
    // Adjust for wraparound
    if difference > 180 {
        set difference to difference - 360.
    } else if difference < -180 {
        set difference to difference + 360.
    }
    return difference.
}

function showmessage {
  parameter message.
  clearscreen.
  print "**************************************************".
  print "**                                              **".
  print "**                                              **".
  print "**            SSTO De-orbit Program v0.1        **".
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

function showInstructions {
    clearscreen.
    print "**************************************************".
    print "**                                              **".
    print "**                                              **".
    print "**            SSTO De-orbit Program v0.1        **".
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