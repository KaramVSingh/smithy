$version: "2"

metadata suppressions = [
    { id: "UnstableTrait", namespace: "smithy.test.divergentshape" }
    { id: "MemberShouldReferenceResource", namespace: "smithy.test.divergentshape" }
]

namespace smithy.test.divergentshape

// --- Shapes for the SSE pattern: List<String> in create input, List<Structure> in property ---

list SseRegionDetails {
    member: SseRegionDetail
}

structure SseRegionDetail {
    regionName: String
    peerHealthStatus: String
}

list RegionNames {
    member: String
}

// The property type intentionally diverges from the create input member type;
// the multi-select hash in the lifecycle binding performs the reshape. The standard
// ResourceOperationInputOutput check sees the property is not directly used in the
// operation's input/output, which is expected for a property bound through a
// transforming JMESPath expression.
resource SseConnect {
    identifiers: { connectId: String }
    properties: { sseRegions: SseRegionDetails }
}

// The create operation takes a list of region name strings, but the resource
// property is a list of structures. The multi-select hash `{regionName: @}`
// maps each string element to a structure with the string as one field.
@createsResources([{
    resource: SseConnect
    identifiers: { connectId: { path: "connectId" } }
    properties: { sseRegions: { path: "sseRegions[].{regionName: @}" } }
}])
operation CreateSseConnect {
    input := {
        sseRegions: RegionNames
    }
    output := {
        connectId: String
    }
}
