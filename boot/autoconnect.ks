CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
if addons:available("RT") {
  set rt to addons:rt.
  lock has_ksc_connection to ADDONS:RT:HASKSCCONNECTION(SHIP).
  lock has_relay_connection to ADDONS:RT:HASCONNECTION(SHIP).
  SET primary_dish TO SHIP:PARTSDUBBED("primarydish")[0].
  SET rt_antenna to primary_dish:GETMODULE("ModuleRTAntenna").

  showMessage("Checking for connection...").
  wait 2.

  // Check for active connection...
  //
  if has_ksc_connection <> true and has_relay_connection <> true {
    rt_antenna:SETFIELD("target", "no-target").
    showMessage("Not connected to KSC.").
    wait 2.
    showMessage("Trying to establish connection...").
    wait 2.
    showMessage("Checking primary dish...").
    wait 2.
    if rt_antenna:getfield("status") = "Off" {
        showMessage("Primary dish is OFF, activating...").
        wait 2.
        rt_antenna:DOEVENT("activate").
        showMessage("Primary dish activated.").
        wait 2.
    } else {
        showMessage("Primary dish is already activated.").
        wait 2.
    }


    // Find available targets
    //
    showMessage("Searching for targets...").
    wait 2.
    set exclude_types to List("SpaceObject", "EVA", "Debris", "Flag").
    set valid_targets to list().
    valid_targets:add("Mission Control").
    LIST targets IN targlist.
    for targ in targlist {
      if exclude_types:indexof(targ:type) = -1 {
        valid_targets:add(targ).
      }
    }
    // Loop through the available targets checking for connections
    //
    showMessage("Testing available connections...").
    wait 2.
    until has_ksc_connection = true or has_relay_connection = true {
        for targ in valid_targets {
            if targ = "Mission Control" {
              showMessage("Testing connection via Mission Control").
              rt_antenna:SETFIELD("target", targ).
            } else {
              showMessage("Testing connection via " + targ:name).
              rt_antenna:SETFIELD("target", targ).
            }
            wait 3.
            if has_ksc_connection = true or has_relay_connection = true {
                break.
            }
        }
    }
    showMessage("Successfully established connection").
    showDelay().

  } else {
    showMessage("KSC connection established.").
    showDelay().
  }
  
  function showDelay {
    print "Delay: " + round(rt:KSCDELAY(ship),2) + " seconds.".
  }

} else {
    print("Remote tech addon not available").
}

function showmessage {
  parameter message.
  clearscreen.
  print "**************************************************".
  print "**                                              **".
  print "**                                              **".
  print "**            Auto connect                      **".
  print "**            Safe Boot script                  **".
  print "**            v0.1                              **".
  print "**                                              **".
  print "**            (c)       2023                    **".
  print "**            License: GPLv3                    **".
  print "**                                              **".
  print "**                                              **".
  print "**************************************************".
  print " ".
  print " ".
  print message.
  print " ".
}