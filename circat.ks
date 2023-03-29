RUNONCEPATH("0:/lib/lib_safe.ks").
parameter reference.
if reference = "p" {
    set reference_time to eta:periapsis.
    set reference_point to periapsis.
} else {
    set reference_time to eta:APOAPSIS.
    set reference_point to apoapsis.
}

SAFE_TAKEOVER().
clearscreen.
print "**************************************************".
print "**                                              **".
print "**            Circularization                   **".
print "**            Node creator                      **".
print "**            v0.1                              **".
print "**                                              **".
print "**            (c)       2023                    **".
print "**            License: GPLv3                    **".
print "**                                              **".
print "**                                              **".
print "**************************************************".
print " ".
print " ".
if not hasnode {
    set v0 to velocityat(SHIP,TIME:SECONDS + reference_time):ORBIT:MAG.
    set v1 to sqrt(BODY:MU/(BODY:RADIUS + reference_point)).
    set CIRCULARIZE to node(TIME:SECONDS + reference_time, 0, 0, v1 - v0).
    add CIRCULARIZE.
}
clearscreen.
print "**************************************************".
print "**                                              **".
print "**            Circularization                   **".
print "**            Node creator                      **".
print "**            v0.1                              **".
print "**                                              **".
print "**            (c)       2023                    **".
print "**            License: GPLv3                    **".
print "**                                              **".
print "**                                              **".
print "**************************************************".
print " ".
print " ".
print "Created node at *" + reference + "*".
print "Time to node  : " + round(reference_time) + "s".
print "Node Apoapsis : " + round((orbitat(SHIP, TIME:SECONDS + reference_time):apoapsis) / 1000, 2) + "km".
print "Node Periapsis: " + round((orbitat(SHIP, TIME:SECONDS + reference_time):periapsis) / 1000, 2) + "km".
print " ".
SAFE_QUIT().