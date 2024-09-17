import Foundation
import _NativeblocksCompilerCommon

struct SyncIntegrationResultModel: Codable {
    var id: String
    var name: String
}

struct SyncIntegrationResultRawModel: Codable {
    var syncIntegration: SyncIntegrationResultModel?
}

struct SyncIntegrationPropertiesInput: Encodable {
    var integrationId: String
    var organizationId: String
    var properties: [PropertyNativeMeta]
}

struct SyncIntegrationEventsInput: Encodable {
    var integrationId: String
    var organizationId: String
    var events: [EventNativeMeta]
}

struct SyncIntegrationDataInput: Encodable {
    var integrationId: String
    var organizationId: String
    var data: [DataNativeMeta]
}

struct SyncIntegrationSlotsInput: Encodable {
    var integrationId: String
    var organizationId: String
    var slots: [SlotNativeMeta]
}

struct EmptyResultModel: Codable {}
