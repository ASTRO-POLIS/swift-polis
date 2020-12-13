//
//  ServiceDiscovery.swift
//
//
//  Created by Georg Tuparev on 18/11/2020.
//

/// This file defines types related to the POLIS provider discovery. The exact process is described in different documents.
/// Later versions might implement a reference implementation of the discovery process, but every provider is free to
/// implement its own procedures.
///
/// **Note for Swift developers:** Before releasing version 1.0 of this package all types will implement `Codable` to
/// allow easy marshalling first from JSON and later from XML data.

import Foundation

/// POLIS APIs are either in XML or in JSON format. For reasons stated elsewhere in the documentation XML APIs are
/// preferred for production code. In contrast, JSON is often easier to be used for new development (no need of schema
/// implementation) and often easier to be used from mobile and web applications. But because its fragility it should be
/// avoided in stable production systems.
/// **Note:** Perhaps later we might need also `plist` format?
public enum PolisDataFormat: String, Codable, CaseIterable {  // CustomStringConvertible, Equatable
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
public enum PolisProvider {         // Codable
    case `public`                   // Should be the default
    case `private`
    case experimental
    case mirror(identifier: String) // The uid of the service provider being mirrored.
}

public enum ContactType {
    case twitter(userName: String)
    case whatsApp(phone: String)
    case facebook(id: String)
    case instagram(userName: String)
    case skype(id: String)
}

public struct PolisCommunicationContact {
    public let name: String            // Organisation or user name
    public let email: String           // Required valid email address (will be checked for validity)
    public let additionalContacts: [ContactType]?
}


/// All the information needed to identify a site as a POLIS provider
public struct PolisDirectoryEntry {                 // Codable
    public let identifier: String                   // Globally unique ID (UUID version 4)
    public let name: String                         // Should be unique to avoid errors, but not a requirement
    public let lastUpdate: Date
    public let domain: String                       // Fully qualified, e.g. https://polis.observer
    public let providerDescription: String?
    public let supportedProtocolLevels: [UInt8]     // Allowed values: 1...3
    public let supportedAPIVersions: [String]       // Formatted as a SemanticVersion, see https://semver.org
    public let supportedFormats: [PolisDataFormat]  // Currently JSON and XML
    public let providerType: PolisProvider
}

/// A list of known
public struct PolisDirectory  {   // Codable, CustomStringConvertible
    public let lastUpdate: Date
    public var entries: [PolisDirectoryEntry]
}


//MARK: - Making types Codable -
extension PolisProvider: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base      = try container.decode(ProviderType.self, forKey: .providerType)

        switch base {
            case .public:       self = .public
            case .private:      self = .private
            case .experimental: self = .experimental
            case .mirror:
                let mirrorParams = try container.decode(MirrorParams.self, forKey: .mirrorParams)
                self = .mirror(identifier: mirrorParams.identifier)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
            case .public:       try container.encode(ProviderType.public,       forKey: .providerType)
            case .private:      try container.encode(ProviderType.private,      forKey: .providerType)
            case .experimental: try container.encode(ProviderType.experimental, forKey: .providerType)
            case .mirror(let identifier):
                try container.encode(ProviderType.mirror, forKey: .providerType)
                try container.encode(MirrorParams(identifier: identifier), forKey: .mirrorParams)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case providerType, mirrorParams
    }

    private enum ProviderType: String, Codable {
        case `public`, `private`, experimental, mirror
    }

    private struct MirrorParams: Codable {
        let identifier: String
    }
}

extension PolisDirectoryEntry: Codable {
    private enum CodingKeys: String, CodingKey {
        case identifier              = "uid"
        case name
        case lastUpdate              = "last_updated"
        case domain
        case providerDescription     = "description"
        case supportedProtocolLevels = "supported_protocol_levels"
        case supportedAPIVersions    = "supported_api_versions"
        case supportedFormats        = "supported_formats"
        case providerType            = "provider_type"
    }
}

extension PolisDirectory: Codable {
    private enum CodingKeys: String, CodingKey {
        case lastUpdate = "last_updated"
        case entries
   }
}

//MARK: - Making types CustomStringConvertible -
extension PolisDataFormat: CustomStringConvertible {
    public var description: String {
        switch self {
            case .xml:  return "xml"
            case .json: return "json"
        }
    }
}
