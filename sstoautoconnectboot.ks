RUNPATH("1:/setautoconnectboot.ks").
print "Press RETURN to reboot.".

set reboot to terminal:input:getchar().
if reboot = terminal:input:ENTER {
  print "Rebooting...".
  wait 1.
  reboot.
}