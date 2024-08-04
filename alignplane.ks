set poll_interval to 1.
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

set sync_finished to false.
LOCAL sync_gui IS GUI(200).
set sync_gui:y to 600.
set sync_gui:x to 850.
LOCAL back_to_menu TO sync_gui:ADDBUTTON("Back to menu").
sync_gui:SHOW().
SET back_to_menu:ONCLICK TO {set sync_finished to true.}.

if (hasTarget) {
    until sync_finished {
        showIncInfo(). 
        wait poll_interval.
    }
} else {
    clearscreen.
    print "You do not have a target. Please select a target.".
    print "Returning to main menu...".
    wait 3.
}

sync_gui:HIDE().
sync_gui:DISPOSE().
clearscreen.
print "Returning to main menu...".
wait 3.
reboot.


function showIncInfo {
    clearscreen.
    print "**************************************************".
    print "**                                              **".
    print "**                                              **".
    print "**            SSTO Align plane. v0.1            **".
    print "**                                              **".
    print "**                                              **".
    print "**               (c)        2021                **".
    print "**                License: GPLv3                **".
    print "**                                              **".
    print "**                                              **".
    print "**************************************************".
    print " ".
    print "TGT: " + target:name.
    print "R. Inc: [MALFUNCTION]".
    print "T. An:  [MALFUNCTION]".
    print "T. Dn:  [MALFUNCTION]".
    print "".
}

function showInstructions {
    clearscreen.
    print "**************************************************".
    print "**                                              **".
    print "**                                              **".
    print "**            SSTO Align plane. v0.1            **".
    print "**                                              **".
    print "**                                              **".
    print "**               (c)        2021                **".
    print "**                License: GPLv3                **".
    print "**                                              **".
    print "**                                              **".
    print "**************************************************".
    print " ".
    print "Use this tool to match your relative inclination".
    print "to the target.".

}
