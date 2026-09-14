print " ".
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
clearscreen.
print "Checking for Connection ...".
print " ".
wait 2.
set KSC to ADDONS:RT:HASCONNECTION(SHIP).
 
 
SET p TO SHIP:PARTSDUBBED("primarydish")[0].
SET m to p:GETMODULE("ModuleRTAntenna").
 
// Do we have an active antenna 
if KSC <> True
{
print "Checking for a dish and activating".
if m:getfield("status") = "Off"
 {  m:DOEVENT("activate").}
}
 
// Finding targets
set TargListgd to list().
LIST TARGETS IN TargList.
// make list of only valid targets
For  Targ in TargList
 { if Targ:type <> "SpaceObject"
   { if Targ:type <> "EVA"
    { if Targ:type <> "Debris"
       {TargListgd:add (Targ).}
    }
   }
 }
print "all Targets".
print TargList.
print " ".
print " Good Targets".
TargListgd:add ("mission-control").
print TargListgd.
print " ".
 
// LOOP Pointing dish
set link to "no-target".  // default target
lock KSCON to ADDONS:RT:HASKSCCONNECTION(SHIP).
lock CON to ADDONS:RT:HASCONNECTION(SHIP).
set x to 0.
set y to TargListgd:length.
//
until KSC = true {
 print " ".
 print "Searching...".
 set targ to TargListgd[x].
 print " ".
 print "moving to " + Targ.
 m:SETFIELD("target",Targ).
 wait 3.
 print Targ + " is KSCconnected  " + KSCON.
 print Targ + " is CONconnected  " + CON.
 if CON = true or KSCON = true { set link to Targ. set KSC to true.}
 if x < y-1 {set x to x+1.} else {set x to 0.} 
wait 1.
}
//
print " ".
print "Trying to connect...".
 print " ".
if not KSC {m:SETFIELD("target",link).}
wait 1.
print " ".
set ESTB to  m:getfield("target").
print "Connection Established to " + ESTB.
print " ".
print "Ready ".