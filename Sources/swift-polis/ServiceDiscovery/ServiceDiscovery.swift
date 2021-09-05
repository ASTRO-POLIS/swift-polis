//
//  ServiceDiscovery.swift
//
//
//  Created by Georg Tuparev on 18/11/2020.
//

// This file defines types related to the POLIS provider discovery and few reusable types that are building blocks of
// other POLIS types.
//
// **Note for Swift developers:** COURAGEOUS and IMPORTANT ASSUMPTION - types defined in this file and in
// `ObservatorySiteDirectory.swift` should not have incompatible coding/decoding and API changes in future versions of
// the standard! All other types could (and will) evolve. And yes, I know this would be too good to be true 😂

import Foundation

/// Complete list of all supported versions.
///
/// A POLIS provider can support some or all listed versions. Only major and minor version numbers are supported.
/// Concrete implementations can ignore `patch numbers` and alfa / beta modifiers.
/// Versions prior `1.0` could be ignored by production-ready implementations. It will be assumed, that they are
/// experimental.
public let supportedPolisAPIVersions = [
    "0.1",    // Initial experimental version. Should not be used for production neither for API compatibility testing.
]

//MARK: - POLIS Item Attributes -

/// `PolisLifecycleStatus` defines the current status of the POLIS items (their readiness to be used in different
/// environments)
///
/// Each POLIS type (Provider, Observing Site, Observatory, etc.) should include `PolisLifecycleStatus` (as part of
/// ``PolisItemAttributes``).
///
/// `PolisLifecycleStatus` will determine the syncing policy, as well as visibility of the POLIS items within
/// client implementations. Implementations should adopt following behaviours:
/// - `inactive`  - do not sync, but continue monitoring
/// - `active`    - must be synced and monitored
/// - `deleted`   - sync the `PolisItemAttributes` only to prevent new propagation of the record and to block the UUID
/// - `suspended` - sync the `PolisItemAttributes` only of the main records
/// - `unknown`   - do not sync, but continue monitoring
public enum PolisLifecycleStatus: String, Codable {
    
    /// `inactive` indicates new, being edited, or in process of upgrade providers.
    case inactive
    
    /// `active` indicates a production provider that is publicly accessible.
    case active
    
    /// `deleted` is needed to prevent reappearance of disabled providers.
    case deleted
    
    /// `suspended` marks providers violating the standard (temporary or permanently).
    case suspended
    
    /// `unknown` marks a provider with unknown status, and is mostly useful when observing site or instrument has
    /// unknown status.
    case unknown
}


/// `PolisItemAttributes` uniquely identifies and defines the status of almost every POLIS item and defines external
/// relationships to other items (or POLIS objects).
///
/// The idea of POLIS Attributes comes from analogous type that could be found in the `RTML` standard. The
/// RTML attributes  turned out to be extremely useful for relating items within one RTML document and linking RTML
/// documents to each other.
///
/// `PolisItemAttributes` are an essential part of (almost) every POLIS type. They are needed to uniquely identify and
/// describe each item (object) and establish parent-child relationships between them, as well as provide enough
/// informationIn for the syncing of polis providers.
///
/// If XML encoding / decoding is used, it is recommended to implements the `PolisItemAttributes` as attributes of the
/// corresponding type (Element).
public struct PolisItemAttributes: Codable, Identifiable {
    
    /// Globally unique identifier (UUID version 4) (ID in XML). The `id` is needed for `Identifiable` protocol
    /// conformance.
    public let id: UUID
    
    /// Establishing parent-child relationship.
    public let parentID: String?
    
    /// Pointer to externally defined item (IDREF in XML).
    public let referenceID: String?
    
    /// Determines the current status of the POLIS item (object).
    public var status: PolisLifecycleStatus
    
    /// Latest update time. Used primarily for syncing.
    public var lastUpdate: Date
    
    /// Human readable name of the item (object). It is recommended to be unique to avoid potential confusions.
    public var name: String
    
    /// Short optional item (object) description. In XML schema should be max 256 characters for RTML interoperability.
    public var shortDescription: String?
    
    /// Designated initialiser.
    ///
    /// Only the `name` parameter is required. All other parameters have reasonable default values.
    public init(id: UUID =  UUID(),
                parentIdentifier: String?    = nil,
                referenceIdentifier: String? = nil,
                status: PolisLifecycleStatus = PolisLifecycleStatus.unknown,
                lastUpdate: Date             = Date(),
                name: String,
                shortDescription: String?    = nil) {
        self.id               = id
        self.parentID         = parentIdentifier
        self.referenceID      = referenceIdentifier
        self.status           = status
        self.lastUpdate       = lastUpdate
        self.name             = name
        self.shortDescription = shortDescription
    }
}


//MARK: - POLIS Contact -
// Many POLIS types have reference to contact people (owners of sites, admins, project managers). Later we need to add
// Institutions too and care about the nasty business of handling addresses, countries, languages, phone numbers and
// other developer's horror. Perhaps the best is to rely on external implementation for the address management. For now
// just a simple contact to be able to communicate with POLIS providers site admins is enough.


/// `PolisCommunication` defines different types of communication channels in addition to the default email address and
/// mobile number.
///
/// The current list includes just few popular communication channels. Emerging apps like Signal and Telegram are not
/// currently included, nor local Chinese and Russian social media communication channels. If someone needs these channels,
/// please submit a pool request.
///
/// The type implements the `Codable` protocol
public enum PolisCommunication {
    
    /// Twitter user id, e.g. @AstroPolis "@" is expected to be part of the id
    case twitter(userName: String)
    
    /// Phone number used by WhatsApp. The phone number should include the country code, start with "+", and contain no
    /// spaces, brackets, or other formatting characters. No validation is provided.
    case whatsApp(phone: String)
    
    /// The Facebook user id is only the part of the URL after "www.facebooc.com/".
    case facebook(id: String)
    
    /// Instagram user id, e.g. @AstroPolis "@" is expected to be part of the id
    case instagram(userName: String)
    
    /// Skype user id
    case skype(id: String)
}


/// `PolisAdminContact` defines a simple way to contact a provider admin, an observing site owner, or an observatory admin.
///
/// It is important to be able to contact the admin of POLIS service provider or the admin or the owner of observing
/// site. But one should not forget that all POLIS data are publicly available and therefore they should expose as
/// little as possible private information. It is preferred not to expose private email addresses, phone numbers, or
/// twitter accounts, but only publicly available organisation contacts.
///
/// The type implements the `Codable` protocol
public struct PolisAdminContact {
    
    /// Admin's name. It is recommended to be either omitted, or to describe admin's role, e.g. "The managing director
    /// of Rozhen observatory"
    public var name: String?
    
    /// Email is the most reliable and widely adopted communication channel, and therefore a valid email address is
    /// required. To protect private information, it is recommended that the email address is assigned to the
    /// institution, e.g. "office@mountain-observatory.org"
    public var email: String
    
    /// Consider giving only institution phone numbers - not private once. The phone number should include the
    /// country code, start with "+", and contain no spaces, brackets, or other formatting characters. No validation is
    /// provided.
    public var mobilePhone: String?
    
    /// Possibly empty list (array) of additional communication channels of type ``Communicating``.
    public var additionalCommunicationChannels: [PolisCommunication]
    
    /// `notes` can contain additional contact info, e.g. "The admin could be contacted only during office hours"
    public var notes: String?
    
    /// Designated initialiser
    ///
    /// Only the `email` is a required parameter. It must contain well formatted email address and implementations
    /// can implement additional validation if the address is a real one and expect confirmation response. If the email
    /// is not valid, `nil` will be returned.
    public init?(name:                           String?,
                email:                           String,
                mobilePhone:                     String?,
                additionalCommunicationChannels: [PolisCommunication] = [PolisCommunication](),
                notes:                           String?) {
        self.name                            = name
        //TODO: Check the validity (format) of the email address!
        self.email                           = email
        self.mobilePhone                     = mobilePhone
        self.additionalCommunicationChannels = additionalCommunicationChannels
        self.notes                           = notes
    }
}

//TODO: Add also Institution (like in RTML). Discuss dependance to external framework.


//MARK: - POLIS Directory Entry -

/// POLIS APIs are encoded either in XML or in JSON format. For reasons stated elsewhere in the documentation XML APIs are
/// preferred for production code. In contrast, JSON is often easier to be used for new development (no need of schema
/// implementation) and often is easier to be used within a mobile or a web applications. But because of its fragility it
/// should be avoided in stable production systems.
///
/// The type implements the `Equatable` protocol
///
/// **Note:** Perhaps later we might need also `plist` format for Apple specific implementations
public enum PolisDataFormat: String, Codable {
    /// The provider implements XML APIs
    case xml

    /// The provider implements JSON APIs
    case json
}


/// `PolisProviderType` defines different types of POLIS providers.
///
/// The type implements the `Codable` and `CustomStringConvertible` protocols
public enum PolisProviderType {
    /// Only `public` provider should be used in production or by publicly available client apps or websites. Public
    /// providers should run on server with enough bandwidth and computational power capable of accommodating multiple
    /// parallel client requests every second.
    case `public`

    /// `private` provider's main purpose is to act as a local cache for larger organisations and should not be accessed
    /// from outside. They might require user authentication.
    case `private`

    /// `local` could be used for clients running on mobile devices or desktop apps
    case local

    /// `experimental` providers are sandboxes for new developments, and might require authentication.
    case experimental

    /// Only when a `public` server is unreachable, its `mirror` (if available) should be accessed while the main server
    /// is down.
    case mirror(id: String) // The `id` of the service provider being mirrored.
}

/// `PolisDirectoryEntry` encapsulates all information needed to identify a site as a POLIS provider
///
/// `PolisDirectoryEntry` is used to define the Polis provider itself, as well as as an entry in the list of known Polis
/// providers.
///
/// The type implements the `Codable` and `Identifiable` protocols
public struct PolisDirectoryEntry: Identifiable {
    public var attributes: PolisItemAttributes
    public var url: String                          // Fully qualified, e.g. https://polis.observer
    public var supportedProtocolLevels: [UInt8]     // Allowed values: 1...3
    public var supportedAPIVersions: [String]       // Formatted as a SemanticVersion, see https://semver.org
    public var supportedFormats: [PolisDataFormat]  // Currently JSON and XML
    public var providerType: PolisProviderType      // e.g. public, experimental, mirror, ...
    public var contact: PolisAdminContact           // Should not expose private information!

    public var id: UUID { attributes.id }           // To make the type `Identifiable`
    
    public init(attributes:              PolisItemAttributes,
                url:                     String,
                providerDescription:     String?,
                supportedProtocolLevels: [UInt8],
                supportedAPIVersions:    [String],
                supportedFormats:        [PolisDataFormat],
                providerType:            PolisProviderType,
                contact:                 PolisAdminContact) {
        self.attributes              = attributes
        self.url                     = url
        self.supportedProtocolLevels = supportedProtocolLevels
        self.supportedAPIVersions    = supportedAPIVersions
        self.supportedFormats        = supportedFormats
        self.providerType            = providerType
        self.contact                 = contact
    }
}


/// `PolisDirectory` is the list of all known Polis providers.
///
/// The type implements the `Codable` protocol.
public struct PolisDirectory  {
    public var lastUpdate: Date                // Used for syncing
    public var entries: [PolisDirectoryEntry]  // List of all known providers
    
    public init(lastUpdate: Date = Date(),
                entries: [PolisDirectoryEntry]) {
        self.lastUpdate = lastUpdate
        self.entries    = entries
    }
}


//MARK: - Making types Codable and CustomStringConvertible -

//MARK: PolisProviderType
extension PolisProviderType: Codable, CustomStringConvertible {
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
                self = .mirror(id: mirrorParams.id)
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            case .public:       try container.encode(ProviderType.public,       forKey: .providerType)
            case .private:      try container.encode(ProviderType.private,      forKey: .providerType)
            case .local:        try container.encode(ProviderType.local,        forKey: .providerType)
            case .experimental: try container.encode(ProviderType.experimental, forKey: .providerType)
            case .mirror(let id):
                try container.encode(ProviderType.mirror, forKey: .providerType)
                try container.encode(MirrorParams(id: id), forKey: .mirrorParams)
        }
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
    
    private enum CodingKeys: String, CodingKey {
        case providerType = "provider_type"
        case mirrorParams = "mirror_params"
    }
    
    private enum ProviderType: String, Codable { case `public`, `private`, local, experimental, mirror }
    
    private struct MirrorParams: Codable { let id: String }
    
}

//MARK: - ContactType
extension PolisCommunication: Codable, CustomStringConvertible {
    
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
    
    private struct TwitterParams: Codable   { let userName: String }
    private struct WhatsAppParams: Codable  { let phone: String }
    private struct FacebookParams: Codable  { let id: String }
    private struct InstagramParams: Codable { let userName: String }
    private struct SkypeParams: Codable     { let id: String }
    
    public var description: String {
        switch self {
            case .twitter:   return "Twitter"
            case .whatsApp:  return "WhatsApp"
            case .facebook:  return "Facebook"
            case .instagram: return "Instagram"
            case .skype:     return "Skype"
        }
    }
}

//MARK: - PolisContact
extension PolisAdminContact: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case mobilePhone                     = "mobile_phone"
        case additionalCommunicationChannels = "additional_communication_channels"
        case notes
    }
}

//MARK: - PolisDirectoryEntry
extension PolisDirectoryEntry: Codable {
    private enum CodingKeys: String, CodingKey {
        case attributes
        case url
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
