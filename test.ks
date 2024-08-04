Clearguis().
set poll_inverval to 3.

set sync_finished to false.
LOCAL sync_gui IS GUI(200).
set sync_gui:y to 600.
set sync_gui:x to 850.

LOCAL poll_interval_label TO sync_gui:ADDLABEL("Poll interval:").
LOCAL poll_interval_textfield TO sync_gui:ADDTEXTFIELD(poll_interval:tostring).
LOCAL back_to_menu TO sync_gui:ADDBUTTON("Back to menu").
sync_gui:SHOW().
set poll_interval_textfield:ONCHANGE to {
    parameter str.
    print str.
    print str:tostring.
    if (str:length = 0) {
        print "no".
    } else {
        print str:toscalar.
    }
}.
SET back_to_menu:ONCLICK TO {set sync_finished to true.}.

if (hasTarget) {
    until sync_finished {

        wait poll_interval.
    }
} else {
    print "You do not have a target. Please select a target before using this tool.".
    print "Returning to main menu...".
    wait 3.
}

sync_gui:HIDE().
sync_gui:DISPOSE().
clearscreen.
print "Returning to main menu...".
wait 3.
reboot.
