
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
clearGuis().
if addons:available("RT") {
  set rt to addons:rt.
  lock has_ksc_connection to rt:HASKSCCONNECTION(SHIP).
  lock has_relay_connection to rt:HASCONNECTION(SHIP).
  SET primary_dish TO SHIP:PARTSDUBBED("primarydish")[0].
  SET rt_antenna to primary_dish:GETMODULE("ModuleRTAntenna").
  set hasChosenOption to false.
  set currentOption to 0.

  print "Booting SSTO Menu...".
  wait 1.

  drawMenu().

  LOCAL my_gui IS GUI(200).
  set my_gui:y to 600.
  set my_gui:x to 850.
  LOCAL up_button TO my_gui:ADDBUTTON("UP").
  LOCAL dn_button TO my_gui:ADDBUTTON("DOWN").
  LOCAL select_button TO my_gui:ADDBUTTON("SELECT").
  my_gui:SHOW().
  SET up_button:ONCLICK TO goUp@.
  SET dn_button:ONCLICK TO goDown@.
  SET select_button:ONCLICK TO select@.

  wait until hasChosenOption.

  executeOption(options[currentOption][1]).


  // Functions
  function drawMenu {
    set has_any_connection to (has_ksc_connection = true or has_relay_connection = true).
    set options to List().
    options:ADD(LIST("Take off.", "1:/sstotakeoff.ks")).
    options:ADD(LIST("Align plane.", "1:/alignplane.ks")).
    options:ADD(LIST("Sync orbit.", "1:/sync.ks")).
    options:ADD(LIST("Dock.", "1:/dock.ks")).
    options:ADD(LIST("De-orbit.", "1:/sstodeorbit.ks")).
    options:ADD(LIST("Re-entry.", "1:/sstoreentry.ks")).
    options:ADD(LIST("Set bootfile: Auto-connect comms", "1:/sstoautoconnectboot.ks")).
    if has_any_connection {
      // connected
      options:ADD(LIST("Firmware update [AVAILABLE].", "0:/boot/sstoinit.ks")).
    } else {
      // no connection
      options:ADD(LIST("Firmware update [UNAVAILABLE].", "0:/boot/sstoinit.ks")).
    }

    clearscreen.
    print "**************************************************".
    print "**                                              **".
    print "**                                              **".
    print "**            SSTO Initialization v0.1          **".
    print "**                                              **".
    print "**                                              **".
    print "**               (c)        2024                **".
    print "**                License: GPLv3                **".
    print "**                                              **".
    print "**************************************************".
    print " ".
    print " ".
    if (has_any_connection) {
      print "Connection status: [CONNECTED]".
    } else {
      print "Connection status: [NOT CONNECTED]".
    }
    print "Welcome commander!".
    print "Please select an option below:".
    print "--------------------------------------------------".
    print " ".
    for option in options {
        if (option = options[currentOption]) {
          print ">   " + option[0].
        } else {
          print "    " + option[0].
        }
        
    }
  }
  function executeOption {
    parameter path.
    RUNPATH(path).
  }

  function goUp {
    if (currentOption > 0) {
      set currentOption to currentOption-1.
      drawMenu().
    }
  }
  function goDown {
    if (currentOption < (options:LENGTH-1)) {
      set currentOption to currentOption+1.
      drawMenu().
    }
  }
  function select {
      my_gui:HIDE().
      set hasChosenOption to true.
  }
} else {
    print("Remote tech addon not available. Please install it to use this suite.").
}