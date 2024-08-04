CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
clearscreen.
print "**************************************************".
print "**                                              **".
print "**                                              **".
print "**            SSTO Script Updater v0.1          **".
print "**                                              **".
print "**                                              **".
print "**               (c)        2024                **".
print "**                License: GPLv3                **".
print "**                                              **".
print "**                                              **".
print "**************************************************".
print " ".
print " ".

if addons:available("RT") {
  lock has_ksc_connection to ADDONS:RT:HASKSCCONNECTION(SHIP).
  lock has_relay_connection to ADDONS:RT:HASCONNECTION(SHIP).
  if has_ksc_connection <> true and has_relay_connection <> true {
    print "No connection to KSC. Cannot copy scripts.".
  } else {
    copypath("0:/boot/sstoinit.ks", "1:/sstoinit.ks").
    copypath("0:/sstomenu.ks", "1:/sstomenu.ks").
    copypath("0:/sstotakeoff.ks", "1:/sstotakeoff.ks").
    copypath("0:/sstoreentry.ks", "1:/sstoreentry.ks").
    copypath("0:/sstodeorbit.ks", "1:/sstodeorbit.ks").
    copypath("0:/boot/autoconnect.ks", "1:/autoconnect.ks").
    copypath("0:/sstoautoconnectboot.ks", "1:/sstoautoconnectboot.ks").
    copypath("0:/setautoconnectboot.ks", "1:/setautoconnectboot.ks").
    copypath("0:/alignplane.ks", "1:/alignplane.ks").
    copypath("0:/sync.ks", "1:/sync.ks").
    copypath("0:/dock.ks", "1:/dock.ks").

    print "KSC connection established.".
    print "Delay: " + round(ADDONS:RT:KSCDELAY(ship),2) + " seconds.".
    print "SSTO scripts written to drive '1:' successfully.".
    set core:bootfilename to "sstomenu.ks".
    print "Update bootfile.".
    wait 1.
    print "Rebooting...".
    wait 2.
    reboot.
  }
} else {
    print("Remote tech addon not available.").
    print("Rebooting...").
    reboot.
}

