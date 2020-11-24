//
//  ServiceDiscovery.swift
//
//
//  Created by Georg Tuparev on 18/11/2020.
//

import Foundation

public struct PolisDirectory: Codable {
    public let lastUpdate: Date
    public var entries: [PolisDirectoryEntry]
}

public enum PolisDataFormatType: String, Codable {
    case xml
    case json
}

public enum PolisProviderType {
    case `public`         // default
    case `private`
    case mirror(String)   // The uid of the service provider being mirrored.
    case experimental
}

public struct PolisDirectoryEntry: Codable {
    public let uid: String      // Globally unique ID (UUID version 4)
    public let name: String
    public let domain: String   // Fully qualified, e.g. https://polis.observer
    public let description: String?
    public let lastUpdate: Date
    public let supportedProtocolLevels: [UInt8]
    public let supportedAPIVersions: [String]
    public let supportedDataTypes: [PolisDataFormatType]
    public let providerType: PolisProviderType
}

public struct ObservingSiteReferenceDirectory {
    public let lastUpdate: Date
    public let sireReference: [ObservingSiteReference]
}
