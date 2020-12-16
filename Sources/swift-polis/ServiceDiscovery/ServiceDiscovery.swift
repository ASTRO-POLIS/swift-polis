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
public enum PolisDataFormat: String, Codable {  // Equatable
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

/// `ContactType` defines different types of communication channels
public enum Communicating {              // Coding
    case twitter(userName: String)
    case whatsApp(phone: String)
    case facebook(id: String)
    case instagram(userName: String)
    case skype(id: String)
}

/// `PolisCommunicationContact` is the way to contact a provider, an observing site, or an observatory
public struct PolisContact {                        
    public let name: String                         // Organisation or user name
    public let email: String                        // Required valid email address (will be checked for validity)
    public let additionalContacts: [Communicating]?

    public init(name: String, email: String, additionalContacts: [Communicating]?) {
        self.name = name
        self.email = email
        self.additionalContacts = additionalContacts
    }

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
    public let contact: PolisContact

    public init(identifier: String, name: String, lastUpdate: Date, domain: String, providerDescription: String?, supportedProtocolLevels: [UInt8], supportedAPIVersions: [String], supportedFormats: [PolisDataFormat], providerType: PolisProvider, contact: PolisContact) {
        self.identifier = identifier
        self.name = name
        self.lastUpdate = lastUpdate
        self.domain = domain
        self.providerDescription = providerDescription
        self.supportedProtocolLevels = supportedProtocolLevels
        self.supportedAPIVersions = supportedAPIVersions
        self.supportedFormats = supportedFormats
        self.providerType = providerType
        self.contact = contact
    }
}

/// A list of known
public struct PolisDirectory  {   // Codable
    public let lastUpdate: Date
    public var entries: [PolisDirectoryEntry]
}


//MARK: - Making types Codable -

//MARK: PolisProvider
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

    private enum CodingKeys: String, CodingKey { case providerType, mirrorParams }

    private enum ProviderType: String, Codable { case `public`, `private`, experimental, mirror }

    private struct MirrorParams: Codable { let identifier: String }
}

//MARK: - ContactType
extension Communicating: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base      = try container.decode(CommunicationType.self, forKey: .communicationType)

        switch base {
            case .twitter:
                let twitterParams = try container.decodeIfPresent(TwitterParams.self, forKey: .twitterParams)
                self = .twitter(userName: twitterParams!.userName)
            case .whatsApp:
                let whatsAppParams = try container.decodeIfPresent(WhatsAppParams.self, forKey: .whatsAppParams)
                self = .whatsApp(phone: whatsAppParams!.phone)
            case .facebook:
                let facebookParams = try container.decodeIfPresent(FacebookParams.self, forKey: .facebookParams)
                self = .facebook(id: facebookParams!.id)
            case .instagram:
                let instagramParams = try container.decodeIfPresent(InstagramParams.self, forKey: .instagramParams)
                self = .instagram(userName: instagramParams!.userName)
            case .skype:
                let skypeParams = try container.decodeIfPresent(SkypeParams.self, forKey: .skypeParams)
                self = .skype(id: skypeParams!.id)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
            case .twitter(let username):
                try container.encode(CommunicationType.twitter, forKey: .communicationType)
                try container.encode(TwitterParams(userName: username), forKey: .twitterParams)
            case .whatsApp(let phone):
                try container.encode(CommunicationType.whatsApp, forKey: .communicationType)
                try container.encode(WhatsAppParams(phone: phone), forKey: .whatsAppParams)
            case .facebook(let id):
                try container.encode(CommunicationType.facebook, forKey: .communicationType)
                try container.encode(FacebookParams(id: id), forKey: .facebookParams)
            case .instagram(let username):
                try container.encode(CommunicationType.instagram, forKey: .communicationType)
                try container.encode(InstagramParams(userName: username), forKey: .instagramParams)
            case .skype(let id):
                try container.encode(CommunicationType.skype, forKey: .communicationType)
                try container.encode(SkypeParams(id: id), forKey: .skypeParams)
        }
    }

    public enum CodingKeys: String, CodingKey { case communicationType, twitterParams, whatsAppParams, facebookParams, instagramParams, skypeParams }

    private enum CommunicationType: String, Codable { case twitter, whatsApp, facebook, instagram, skype }

    private struct TwitterParams: Codable {  let userName: String }

    private struct WhatsAppParams: Codable { let phone: String }

    private struct FacebookParams: Codable { let id: String }

    private struct InstagramParams: Codable { let userName: String }

    private struct SkypeParams: Codable { let id: String }
}

//MARK: - PolisContact
extension PolisContact: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case additionalContacts = "additional_contacts"
    }
}

//MARK: - PolisDirectoryEntry
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
        case contact
    }
}

//MARK: - PolisDirectory
extension PolisDirectory: Codable {
    private enum CodingKeys: String, CodingKey {
        case lastUpdate = "last_updated"
        case entries
   }
}
