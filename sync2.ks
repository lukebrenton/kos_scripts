// Assuming `target` is the target vessel and `ship` is the current vessel

// Get orbital periods of both vessels
set targetPeriod to target:ORBIT:PERIOD.
set shipPeriod to SHIP:ORBIT:PERIOD.

// Initialize variables
set maxOrbits to 10.
set updateInterval to 0.1. // Interval in seconds

// Define a function for modulo operation
function mod {
    parameter a, b.
    return a - (floor(a / b) * b).
}

// Function to format numbers with leading zeros and fixed decimal places
function formatNumber {
    parameter number.
    set string_num to number:toString.
    set diff to 8 - (string_num:length-1).
    FROM {local x is diff.} UNTIL x = 0 STEP {set x to x-1.} DO {
        set string_num to " " + string_num.
    }
    return string_num.

}

// Function to calculate and print phase angles, relative positions, and closest approach
function calculateRendezvous {
    set orbits to List().
    FROM {local x is 0.} UNTIL x = maxOrbits STEP {set x to x+1.} DO {
        // Calculate the time for the i-th orbit in seconds
        set timeInSeconds to x * shipPeriod.

        // Calculate the true anomaly for both vessels at this time
        // Convert timeInSeconds to the fraction of the orbit period
        set targetAnomalyFraction to timeInSeconds / targetPeriod.
        set shipAnomalyFraction to timeInSeconds / shipPeriod.

        // Calculate the true anomaly for both vessels at this time
        set targetTrueAnomaly to mod(target:ORBIT:TRUEANOMALY + (360 * targetAnomalyFraction), 360).
        set shipTrueAnomaly to mod(SHIP:ORBIT:TRUEANOMALY + (360 * shipAnomalyFraction), 360).

        // Calculate the phase angle difference
        set phaseAngle to abs(targetTrueAnomaly - shipTrueAnomaly).
        if phaseAngle > 180 {
            set phaseAngle to 360 - phaseAngle.
        }
        set phaseAngleDeg to phaseAngle.

        // Determine if ship is ahead or behind
        if targetTrueAnomaly > shipTrueAnomaly {
            set relativePosition to "B".
            set instruction to "P".
        } else {
            set relativePosition to "A".
            set instruction to "R".
        }

        // Calculate closest approach distance
        set closestApproachDistance to round(abs((POSITIONAT(SHIP, timeInSeconds) - POSITIONAT(TARGET, timeInSeconds)):mag) / 1000, 2).

        orbits:ADD(formatNumber(x) + "|" + formatNumber(round(phaseAngleDeg, 2)) + "|" + formatNumber(round(closestApproachDistance, 2)) + "|       " + relativePosition + "| " + instruction).
    }
    return orbits.
}

function printresults {
    clearScreen. // Clear the screen for a clean output
    print "         | Phase   |         |Closest | Burn ".
    print "Orbit    | Angle   | Pos     |Approach| Dir  ".
    print "---------|---------|---------|--------|--------".
    for orbit in orbits {
          print orbit.
    }
}

// Main loop
until false {
    calculateRendezvous().
    printresults().
    wait 0.1.
}