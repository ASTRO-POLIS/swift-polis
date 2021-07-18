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

/// This is a list of all supported versions. A POLIS provider can support some of them or all of them. Only major and
/// minor version numbers are supported. Concrete implementations can ignore `patch numbers` and alfa / beta modifiers.
/// Versions prior `1.0` could be ignored by production-ready implementations. It will be assumed, that they are
/// experimental.
public let supportedPolisAPIVersions = [
    "0.1",    // Initial experimental version. Should not be used for production neither for API compatibility testing.
]

//MARK: - POLIS Item Attributes -

/// Each POLIS type (Provider, Observing Site, Observatory, etc.) should include `LifecycleStatus` (as part of
/// ``PolisItemAttributes``).
///
/// `LifecycleStatus` will determine the syncing policy, as well as visibility of the POLIS items within
/// client implementations. Implementations should adopt following behaviours:
/// - `inactive`  - do not sync, but continue monitoring
/// - `active`    - must be synced and monitored
/// - `deleted`   - sync the `Attributes` only to prevent new propagation of the record and to block the UUID
/// - `suspended` - sync the `Attributes` only the main records
/// - `unknown`   - do not sync, but continue monitoring
public enum LifecycleStatus: String, Codable {
    
    /// New, being edited, in process of upgrade providers should be marked as `inactive`.
    case inactive
    
    /// `active` marks a production provider that is publicly accessible.
    case active
    
    /// `deleted` is needed to prevent reappearance of disabled providers.
    case deleted
    
    /// `suspended` in cases of software or hardware migrations, or violations of standard compliance.
    case suspended
    
    /// `unknown` marks a provider with unknown status, and is mostly just for completeness.
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
    
    /// Pointer to externally defined item (IDREF in XML). Used mostly by `local` providers
    public let referenceID: String?
    
    /// Determines the current status of the POLIS item (object).
    public var status: LifecycleStatus
    
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
                status: LifecycleStatus      = LifecycleStatus.unknown,
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
// just a simple contact to be able to communicate with site admins is enough.
//

/// `Communicating` defines different types of communication channels in addition to the default email and mobile number.
///
/// The current list includes just few popular communication channels. Emerging apps like Signal and Telegram are not
/// currently included, nor local Chinese and Russian social media communication channels. If someone needs these channels,
/// please submit a pool request.
///
/// The type implements the `Codable` protocol
public enum Communicating {
    
    /// Twitter user id, e.g. @AstroPolis "@" is expected to be part of the id
    case twitter(userName: String)
    
    /// Phone number used by WhatsApp. The phone number should include the country code, start with "+", and contain no
    /// spaces, brackets, or other formatting characters.
    case whatsApp(phone: String)
    
    /// TheFacebook user id is only the part of the URL after "www.facebooc.com/"!
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
    
    /// Email is the most reliable and widely addopted communication channel, and therefore a valid email address is
    /// required. To protect private information, it is recommended that the email address is assigned to the
    /// institution, e.g. "office@mountain-observatory.org"
    public var email: String
    
    /// Consider giving only institution phone numbers - not private once. The phone number should include the
    /// country code, start with "+", and contain no spaces, brackets, or other formatting characters.
    public var mobilePhone: String?
    
    /// Possibly empty list (array) of additional communication channels of type ``Communicating``.
    public var additionalCommunicationChannels: [Communicating]
    
    /// `notes` can contain additional contact info, e.g. "The admin could be contacted only during office hours"
    public var notes: String?
    
    /// Designated initialiser
    ///
    /// Only the `email` is a required parameter. It must contain well formatted email address and implementations
    /// can implement additional validation if the address is a real one and expect confirmation response.
    public init(name: String?, email: String, mobilePhone: String?, additionalCommunicationChannels: [Communicating] = [Communicating](), notes: String?) {
        self.name = name
        self.email = email
        self.mobilePhone = mobilePhone
        self.additionalCommunicationChannels = additionalCommunicationChannels
        self.notes = notes
    }
}

//TODO: Add here also Institution (like in RTML). Discuss dependance to external framework.


//MARK: - POLIS Directory Entry -

/// POLIS APIs are encoded either in XML or in JSON format. For reasons stated elsewhere in the documentation XML APIs are
/// preferred for production code. In contrast, JSON is often easier to be used for new development (no need of schema
/// implementation) and often easier to be used within a mobile and a web applications. But because its fragility it
/// should be avoided in stable production systems.
/// **Note:** Perhaps later we might need also `plist` format for Apple specific implementations
public enum PolisDataFormat: String, Codable {  // Equatable
    case xml
    case json
}

/// `PolisProvider` defines different types of POLIS providers.
/// Only `public` provider should be used in production. Public providers should run on server with enough bandwidth and
/// computational power capable of accommodating multiple parallel client requests every second. Only when a `public`
/// server is unreachable, its `mirror` (if available) should be accessed while the main server is down.
/// `private` provider's main purpose is to act as a local cache for larger institutions and should be not accessed from
/// outside. They might require user authentication.
/// `local` could be used for clients running on mobile devices or desktop apps
/// `experimental` providers are sandboxes for new developments, and might require authentication.
public enum PolisProvider { // Codable, CustomStringConvertible
    case `public`           // Should be the default
    case `private`
    case local              // To be used as local cache in mobile or desktop clients
    case experimental
    case mirror(id: String) // The `id` of the service provider being mirrored.
}


/// All the information needed to identify a site as a POLIS provider
public struct PolisDirectoryEntry: Identifiable {   // Codable, Identifiable
    public var attributes: PolisItemAttributes
    public var domain: String                       // Fully qualified, e.g. https://polis.observer
    public var supportedProtocolLevels: [UInt8]     // Allowed values: 1...3
    public var supportedAPIVersions: [String]       // Formatted as a SemanticVersion, see https://semver.org
    public var supportedFormats: [PolisDataFormat]  // Currently JSON and XML
    public var providerType: PolisProvider
    public var contact: PolisAdminContact
    
    public var id: UUID { attributes.id }           // To make the type `Identifiable`
    
    public init(attributes: PolisItemAttributes, domain: String, providerDescription: String?, supportedProtocolLevels: [UInt8], supportedAPIVersions: [String], supportedFormats: [PolisDataFormat], providerType: PolisProvider, contact: PolisAdminContact) {
        self.attributes              = attributes
        self.domain                  = domain
        self.supportedProtocolLevels = supportedProtocolLevels
        self.supportedAPIVersions    = supportedAPIVersions
        self.supportedFormats        = supportedFormats
        self.providerType            = providerType
        self.contact                 = contact
    }
}

/// A list of known providers
public struct PolisDirectory  {   // Codable
    public var lastUpdate: Date
    public var entries: [PolisDirectoryEntry]
    
    public init(lastUpdate: Date, entries: [PolisDirectoryEntry]) {
        self.lastUpdate = lastUpdate
        self.entries    = entries
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
extension Communicating: Codable, CustomStringConvertible {
    
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
        case domain
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
