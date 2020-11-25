//
//  ServiceDiscovery.swift
//
//
//  Created by Georg Tuparev on 18/11/2020.
//

/// This file defines types related to the POLIS provider discovery. The exact process is described in other documents.
/// Later versions might implement a reference implementation of the discovery process, but every provider is free to
/// implement its own procedures.
///
/// **Note for Swift developers:** Before releasing version 1.0 of this package all types will implement `Codable` to
/// allow easy marshalling from JSON or XML data.

import Foundation

/// POLIS APIs are either in XML or in JSON. For reasons stated elsewhere in the documentation XML APIs are preferred
/// for production code. In contrast, JSON is often easier to be used for new development (no need of schema development)
/// and often easier to be used from mobile and web applications. But because its fragility it should be avoided.
public enum PolisDataFormatType: String, Codable {
    case xml
    case json
}

/// `PolisProviderType` defines different types of POLIS providers.
///
/// Only `public` provider should be used in production. Public providers should run on server with enough bandwidth and
/// computational power capable of accommodating multiple parallel client requests every second. Only when a `public`
/// server is unreachable, its `mirror` (if available) should be accessed until the main server is down.
/// `private` provider's main purpose is to act as a local cache for larger institutions and should be not accessed from
/// outside. They might require user authentication.
/// `experimental` providers are sandboxes for new developments, and might require authentication.
public enum PolisProviderType {
    case `public`         // default
    case `private`
    case mirror(String)   // The uid of the service provider being mirrored.
    case experimental
}

/// A list of known
public struct PolisDirectory {
    public let lastUpdate: Date
    public var entries: [PolisDirectoryEntry]
}

/// All the information needed to identify a site as a POLIS provider
public struct PolisDirectoryEntry {
    public let uid: String      // Globally unique ID (UUID version 4)
    public let name: String     // Should be unique to avoid errors, but not a requirement
    public let domain: String   // Fully qualified, e.g. https://polis.observer
    public let description: String?
    public let lastUpdate: Date
    public let supportedProtocolLevels: [UInt8]
    public let supportedAPIVersions: [String]
    public let supportedDataTypes: [PolisDataFormatType]
    public let providerType: PolisProviderType
}
