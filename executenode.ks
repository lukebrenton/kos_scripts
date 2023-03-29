RUNONCEPATH("0:/lib/lib_safe.ks").
RUNONCEPATH("0:/lib/lib_engines.ks", "all").
RUNONCEPATH("0:/lib/lib_utils.ks").
parameter safe_mode.
// safe mode will turn off ion engines if electric charge gets below 10%.

SAFE_TAKEOVER().
showMessage("Preparing to execute node...").
if (hasNode) {
    global CIRCULARIZE to nextNode.
    lock max_acc to SHIP:MAXTHRUST / SHIP:MASS.
    lock burn_duration to CIRCULARIZE:DELTAV:MAG / max_acc.
    until CIRCULARIZE:ETA <= (burn_duration / 2) + 10 {
        showMessage("Aiming vessel to the node vector in " + round(CIRCULARIZE:ETA - (burn_duration / 2) - 10) + "s").
        wait 0.1.
    }
    
    lock STEERING to CIRCULARIZE:DELTAV:DIRECTION.

    until CIRCULARIZE:ETA <= (burn_duration / 2) {
        showMessage("Commencing burn: " + round(CIRCULARIZE:ETA - (burn_duration / 2)) + "s").
        wait 0.1.
    }

    wait until CIRCULARIZE:ETA <= burn_duration / 2.
    lock throttle to 1.
    until CIRCULARIZE:DELTAV:MAG < 0.1 {
        if getResourcePercentage("ElectricCharge") <= 10 and safe_mode = true {
            break.
        }
        showmessage("Burning: " + round(CIRCULARIZE:DELTAV:MAG, 2)).
        lock throttle to 1.
        if CIRCULARIZE:DELTAV:MAG < 10 {
            lock throttle to 0.5.
        }
        if CIRCULARIZE:DELTAV:MAG < 5 {
            lock throttle to 0.3.
        }
        if CIRCULARIZE:DELTAV:MAG < 2 {
            lock throttle to 0.1.
        }
        wait 0.1.
    }
    lock throttle to 0.
    
    clearscreen.
    print "**************************************************".
    print "**                                              **".
    print "**                                              **".
    print "**            Node executor                     **".
    print "**            v0.1                              **".
    print "**                                              **".
    print "**            (c)       2023                    **".
    print "**            License: GPLv3                    **".
    print "**                                              **".
    print "**                                              **".
    print "**************************************************".
    print " ".
    print " ".
    if CIRCULARIZE:DELTAV:MAG < 0.1 {
        print "Burn complete.".
    } else {
        print "*** BURN ABORTED ***".
        print "*** ELECTRIC CHARGE LOW ***".
    }
    remove CIRCULARIZE.
    print " ".
    print " ".
    print "New Apoapsis  : " + round((orbitat(SHIP, TIME:SECONDS + eta:apoapsis):apoapsis) / 1000, 2) + "km".
    print "New Periapsis : " + round((orbitat(SHIP, TIME:SECONDS + eta:periapsis):periapsis) / 1000, 2) + "km".
}

SAFE_QUIT().

function showmessage {
  parameter message.
  clearscreen.
  print "**************************************************".
  print "**                                              **".
  print "**                                              **".
  print "**            Node executor                     **".
  print "**            v0.1                              **".
  print "**                                              **".
  print "**            (c)       2023                    **".
  print "**            License: GPLv3                    **".
  print "**                                              **".
  print "**                                              **".
  print "**************************************************".
  print " ".
  if safe_mode {
    print "*** SAFE MODE ***".
  }
  print " ".
  print message.
  print " ".
}