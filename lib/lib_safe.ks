//Release control safely
function SAFE_QUIT {
    LOCK THROTTLE TO 0.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}

function SAFE_TAKEOVER {
    SAS OFF.
}