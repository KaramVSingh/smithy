$version: "2"

metadata suppressions = [
    { id: "UnstableTrait", namespace: "smithy.test.divergentshape" }
    { id: "MemberShouldReferenceResource", namespace: "smithy.test.divergentshape" }
]

namespace smithy.test.divergentshape

list RegionNames {
    member: String
}

list RegionDetails {
    member: RegionDetail
}

structure RegionDetail {
    regionName: String
}

resource SseConnect {
    identifiers: { connectId: String }
    properties: { sseRegions: RegionDetails }
}

// Multi-select hash is allowed, but a function call inside it is not.
@createsResources([{
    resource: SseConnect
    identifiers: { connectId: { path: "connectId" } }
    properties: { sseRegions: { path: "sseRegions[].{regionName: length(@)}" } }
}])
operation CreateSseConnect {
    input := {
        sseRegions: RegionNames
    }
    output := {
        connectId: String
    }
}
