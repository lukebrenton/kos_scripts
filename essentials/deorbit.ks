//Deorbit & landing script for SSTO spaceplanes, specifically the Ascension.
//File: deorbit.ks  From: https://github.com/lordcirth/kOS-Public

RUNONCEPATH("0:/lib/lib_safe.ks").
RUNONCEPATH("0:/lib/lib_text.ks").
RUNONCEPATH("0:/lib/lib_engines.ks", "all").
RUNONCEPATH("0:/lib/lib_pid").
// de-orbit
SET burn_longitude TO 93.
SET runway_longitude TO 285.275833129883.
SET runway_latitude TO -0.048591406236738.
set deorbit_periapsis to -45000.

// re-entry
set destination_longitude to runway_longitude-0.05.
set destination_altitude to 100.
set reentry_pitch to 8.
set initial_reentry_heading to 90.
set glide_slope_cruise_speed to 350.

// deOrbit(
//     burn_longitude,
//     runway_longitude,
//     runway_latitude,
//     deorbit_periapsis
// ).
// wait 3.
reEntry(
    reentry_pitch,
    initial_reentry_heading,
    glide_slope_cruise_speed,
    destination_longitude,
    destination_altitude
).
wait 3.

function reEntry {
    parameter reentry_pitch.
    parameter initial_reentry_heading.
    parameter glide_slope_cruise_speed.
    parameter destination_longitude.
    parameter destination_altitude.

    // initial re-entry slope
    print "Preparing for re-entry. Please fasten your seatbelts.".
    wait 3.
    SAFE_TAKEOVER().
    INTAKES off.
    BRAKES on. // (includes air-brakes)
    lock STEERING to Heading(initial_reentry_heading, reentry_pitch).

    // when not on fire
    wait until SHIP:Velocity:Surface:MAG < 1000.
    INTAKES on.
    BRAKES off.
    RapierSet(true). // airbreathing mode
    EngineSet(rapiers, true).
    EngineSet(jets, true).
    print "Reentry complete.  Aiming for KSC.".
    LOCK direction_to_ksc TO 75/(runway_longitude - getShipLongitude())*(SHIP:Latitude - runway_latitude) + 90.
    lock STEERING to Heading(direction_to_ksc, reentry_pitch).

    // set up slope between current position and the destination
	set glideSlope to (destination_altitude - SHIP:Altitude) / (destination_longitude - getShipLongitude()).
	lock target_altitude to glideSlope * (getShipLongitude() - destination_longitude) + destination_altitude.

    // use pid to manage pitch
    set pid to PID_init(0.03,0.01,0.5,-25,25).
    lock ship_altitude to ship:altitude.
    until getShipLongitude() > destination_longitude {
        lock THROTTLE TO ((glide_slope_cruise_speed - Ship:Velocity:Surface:MAG) / 50).
        set pid_pitch to PID_seek (pid, target_altitude, SHIP:Altitude).
        lock STEERING to Heading(direction_to_ksc, pid_pitch).
        clearscreen.
        print "current longitude: " + ship_altitude.
        print ship_altitude < 1000.
        print "current longitude: " + getShipLongitude.
        Print "Lat Err:    " + round((SHIP:Latitude - runway_latitude),4).
        print "target pitch: " + pid_pitch.
        print "target altitude: " + target_altitude.
        print "altitude error: " + round((SHIP:Altitude - target_altitude),4).
        if ship_altitude < 5000 {
            autoBrake(200).
            set glide_slope_cruise_speed to 200.
        }
        if ship_altitude < 2000 {
            autoBrake(120).
            set glide_slope_cruise_speed to 120.
        }
        if ship_altitude < 1000 {
            break.
        }
        wait 0.1.
	}
    clearscreen.
    print "Glide complete. Controls released. Please land safely.".
    SAFE_QUIT().
}

function deOrbit {
    parameter burn_longitude.
    parameter runway_longitude.
    parameter runway_latitude.
    parameter deorbit_periapsis.
    
    print "Preparing to de-orbit. Make sure you have the correct engines activated.".
    wait 3.
    SAFE_TAKEOVER().

    if SHIP:ORBIT:Inclination > 0.5 { 
	    print "Ship inclination > 0.5. Aborting de-orbit. Make inclination lower before commencing de-orbit.".
    } else {
        set WARPMODE to "RAILS".
        set WARP to 3. //50X
        until runway_longitude - burn_longitude - getShipLongitude < 7.5  {
            clearscreen.
            print  "Deorbit in: " + round((runway_longitude - burn_longitude - getShipLongitude),2) + " degrees".
            wait 0.5.
        }

        set WARP to 0.
        lock STEERING to RETROGRADE.  
        until VAng(SHIP:Facing:Vector, Retrograde:Vector) < 0.2
        and runway_longitude - burn_longitude - getShipLongitude < 0.2 {
            clearscreen.
            Print  "Deorbit in: " + (runway_longitude - burn_longitude - getShipLongitude).
            WAIT 1.
        }
        Print  "Deorbiting at: " + round((runway_longitude -  getShipLongitude),2) + " degrees from runway".
        LOCK THROTTLE TO 1.
        wait until Periapsis < deorbit_periapsis.
        LOCK THROTTLE TO 0.
        LOCK STEERING TO Prograde.
        print "DE-ORBIT BURN COMPLETE".
        SAFE_QUIT().
    }
}

function autoBrake {
    parameter speed.
	if Ship:Velocity:Surface:MAG > speed {
        brakes on.
	} else {
        brakes off.
	}
}

function getShipLongitude {
    if Ship:Longitude < 0 {
        return ship:longitude + 360.
    } else {
        return ship:Longitude.
    }
}