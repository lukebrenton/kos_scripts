function getResource {
    parameter resource_string.
    // e.g.
    // ElectricCharge
    // XenonGas
	FOR resource IN ship:resources {
        if resource:name:contains(resource_string) {
            return resource.
        }
    }.
}

function getResourcePercentage {
    parameter resource_string.
    set resource to getResource(resource_string).
    return (resource:amount / resource:capacity) * 100.
}
