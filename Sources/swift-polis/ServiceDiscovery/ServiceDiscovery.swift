//
//  ServiceDiscovery.swift
//
//
//  Created by Georg Tuparev on 18/11/2020.
//

/// This file defines types related to the POLIS provider discovery and few reusable types that are building blocks of
/// other POLIS types.
/// Later versions might implement a reference implementation of the discovery process discovery and maintenance, but
/// every provider is free to implement its own procedures.
///
/// **Note for Swift developers:** Before releasing version 1.0 of this package all types will implement `Codable` to
/// allow easy marshalling first from JSON and later from XML data.

import Foundation

//MARK: - POLIS Item Attributes -
/// POLIS Attributes uniquely identify and define the status of almost every POLIS item, and define external relationships
/// to other items.
/// The idea of POLIS Attributes comes from analogous type from the RTML standard, that turned to be extremely useful.

/// Each type (Provider, Observing Site, Observatory, etc.) should include Status (as part of `PolisItemAttributes`.
/// This will define the syncing policy, as well as visibility of the POLIS items within client implementations.
/// Possible values:
/// - `inactive`  - do not sync, but continue monitoring
/// - `active`    - sync as it is (new, or update, depending on the last update date)
/// - `deleted`   - sync the Attributes only to prevent new propagation of the record and to block the UUID
/// - `suspended` - sync the Attributes only, but not the rest of the item
/// - `unknown`   - do not sync, but continue monitoring
public enum Status: String, Codable {
    case inactive   // New, being edited, in process of upgrade
    case active     // in production
    case deleted    // we need this because otherwise in distributed system disappearing records will reappear.
    case suspended  // e.g., in cases the data is incorrect, or there are rule/standard violations.
    case unknown    // e.g. the entity exist, but the status is unknown.
}

/// `PolisItemAttributes` should be part of (almost) every POLIS type. When XML encoding is used, it is recommended to
/// present this type as attributes of the integrating type (Element).
public struct PolisItemAttributes: Codable {
    public let identifier: String            // Globally unique ID (UUID version 4) (ID in XML)
    public let parentIdentifier: String?     // ... to parent Item
    public let referenceIdentifier: String?  // ... pointer to externally defined item (IDREF in XML).
    public let status: Status                // Current status of the type
    public let lastUpdate: Date              // Last update time of the attributes and / or any of the Items content

    public init(identifier: String? = nil,
                parentIdentifier: String? = nil,
                referenceIdentifier: String? = nil,
                status: Status? = nil,
                lastUpdate: Date? = nil) {
        if let identifier = identifier { self.identifier = identifier}
        else                           { self.identifier = UUID().uuidString }

        self.parentIdentifier = parentIdentifier
        self.referenceIdentifier = referenceIdentifier

        if let status = status { self.status = status }
        else                   { self.status = Status.unknown }

        if let date = lastUpdate { self.lastUpdate = date }
        else                     { self.lastUpdate = Date() }
    }
}


//MARK: - POLIS Contact -
/// Many POLIS types have reference to contact people (owners of a site, admins, project managers). Later we need to add
/// Institutions too!
///

/// `ContactType` defines different types of communication channels
public enum Communicating {      // Codable
    case twitter(userName: String)    // Twitter user id, e.g. @AstroPolis
    case whatsApp(phone: String)      // Phone number
    case facebook(id: String)         // Facebook user id
    case instagram(userName: String)  // Instagram user id
    case skype(id: String)            // Skype user id
}

/// `PolisContact` is the way to contact a provider admin, an observing site owner, or an observatory admin.
/// - `name`                            - Person's name
/// - `email`                           - Implementations should guarantee well defined email format
/// - `mobilePhone`                     - we required **mobile** phone number, so that clients can send SMS
/// - `additionalCommunicationChannels` - optional list of additional contact channels like Twitter or Skype
public struct PolisContact {     // Codable
    public let name: String?                                      // Organisation or user name
    public let email: String?                                     // Required valid email address (will be checked for validity)
    public let mobilePhone: String?                               // Clients should implement smart handling of the phone number
    public let additionalCommunicationChannels: [Communicating]?  // Other ways communicate with the person

    public init(name: String?, email: String?, mobilePhone: String?, additionalCommunicationChannels: [Communicating]?) {
        self.name = name
        self.email = email
        self.additionalCommunicationChannels = additionalCommunicationChannels
        self.mobilePhone = mobilePhone
    }
}

//TODO: Add here also Institution (like in RTML)

//MARK: - POLIS Directory Entry -

/// POLIS APIs are encoded either in XML or in JSON format. For reasons stated elsewhere in the documentation XML APIs are
/// preferred for production code. In contrast, JSON is often easier to be used for new development (no need of schema
/// implementation) and often easier to be used from mobile and web applications. But because its fragility it should be
/// avoided in stable production systems.
/// **Note:** Perhaps later we might need also `plist` format for Apple specific implementations
public enum PolisDataFormat: String, Codable {  // Equatable
    case xml
    case json
}

/// `PolisProvider` defines different types of POLIS providers.
/// Only `public` provider should be used in production. Public providers should run on server with enough bandwidth and
/// computational power capable of accommodating multiple parallel client requests every second. Only when a `public`
/// server is unreachable, its `mirror` (if available) should be accessed until the main server is down.
/// `private` provider's main purpose is to act as a local cache for larger institutions and should be not accessed from
/// outside. They might require user authentication.
/// `local` could be used for clients running on mobile devices or desktop apps
/// `experimental` providers are sandboxes for new developments, and might require authentication.
public enum PolisProvider {         // Codable
    case `public`                   // Should be the default
    case `private`
    case local                      // To be used as local cache in mobile or desktop clients
    case experimental
    case mirror(identifier: String) // The uid of the service provider being mirrored.
}


/// All the information needed to identify a site as a POLIS provider
public struct PolisDirectoryEntry {                 // Codable
    public let attributes: PolisItemAttributes
    public let name: String                         // Should be unique to avoid errors, but not a requirement
    public let domain: String                       // Fully qualified, e.g. https://polis.observer
    public let providerDescription: String?
    public let supportedProtocolLevels: [UInt8]     // Allowed values: 1...3
    public let supportedAPIVersions: [String]       // Formatted as a SemanticVersion, see https://semver.org
    public let supportedFormats: [PolisDataFormat]  // Currently JSON and XML
    public let providerType: PolisProvider
    public let contact: PolisContact

    public init(attributes: PolisItemAttributes, name: String, domain: String, providerDescription: String?, supportedProtocolLevels: [UInt8], supportedAPIVersions: [String], supportedFormats: [PolisDataFormat], providerType: PolisProvider, contact: PolisContact) {
        self.attributes = attributes
        self.name = name
        self.domain = domain
        self.providerDescription = providerDescription
        self.supportedProtocolLevels = supportedProtocolLevels
        self.supportedAPIVersions = supportedAPIVersions
        self.supportedFormats = supportedFormats
        self.providerType = providerType
        self.contact = contact
    }
}

/// A list of known providers
public struct PolisDirectory  {   // Codable
    public let lastUpdate: Date
    public var entries: [PolisDirectoryEntry]

    public init(lastUpdate: Date, entries: [PolisDirectoryEntry]) {
        self.lastUpdate = lastUpdate
        self.entries = entries
    }
}


//MARK: - Making types Codable -

//MARK: PolisProvider
extension PolisProvider: Codable, CustomStringConvertible {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base      = try container.decode(ProviderType.self, forKey: .providerType)

        switch base {
            case .public:       self = .public
            case .private:      self = .private
            case .local:        self = .local
            case .experimental: self = .experimental
            case .mirror:
                let mirrorParams = try container.decode(MirrorParams.self, forKey: .mirrorParams)
                self = .mirror(identifier: mirrorParams.identifier)
        }

        public var description: String {
            switch self {
                case .public:       return "public"
                case .private:      return "private"
                case .local:        return "local"
                case .experimental: return "experimental"
                case .mirror:       return "mirror"
            }
        }


    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
            case .public:       try container.encode(ProviderType.public,       forKey: .providerType)
            case .private:      try container.encode(ProviderType.private,      forKey: .providerType)
            case .local:        try container.encode(ProviderType.local,        forKey: .providerType)
            case .experimental: try container.encode(ProviderType.experimental, forKey: .providerType)
            case .mirror(let identifier):
                try container.encode(ProviderType.mirror, forKey: .providerType)
                try container.encode(MirrorParams(identifier: identifier), forKey: .mirrorParams)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case providerType = "provider_type"
        case mirrorParams = "mirror_params"
    }

    private enum ProviderType: String, Codable { case `public`, `private`, local, experimental, mirror }

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

    public enum CodingKeys: String, CodingKey {
        case communicationType = "communication_type"
        case twitterParams     = "Twitter_params"
        case whatsAppParams    = "WhatsApp_params"
        case facebookParams    = "Facebook_params"
        case instagramParams   = "Instagram_params"
        case skypeParams       = "Skype_params"
    }

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
        case mobilePhone                     = "mobile_phone"
        case additionalCommunicationChannels = "additional_communication_channels"
    }
}

//MARK: - PolisDirectoryEntry
extension PolisDirectoryEntry: Codable {
    private enum CodingKeys: String, CodingKey {
        case attributes
        case name
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
