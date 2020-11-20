import Foundation

public struct PolisStaticLinks {
    public static let defaultDomain = "polis.observer"
}

public struct PolisDirectory: Codable {
    public let lastUpdate: Date
    public var entries: [PolisDirectoryEntry]
}

public enum PolisDataFormatType: String, Codable {
    case xml
    case json
}

public enum PolisProviderType: String, Codable {
    case `public`  // default
    case `private`
    case mirror   //TODO: should be mirror(String), where the argument is the ID of the main service
    case experimental
}

public struct PolisDirectoryEntry: Codable {
    public let id: String      // Actually a UUID
    public let lastUpdate: Date
    public let supportedProtocolLevels: [UInt8]
    public let supportedAPIVersions: [String]
    public let supportedDataType: [PolisDataFormatType]
    public let providerType: PolisProviderType
}
