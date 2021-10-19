//
//  PolisCommonStaticTypes.swift
//  
//
//  Created by Georg Tuparev on 09/10/2021.
//

import Foundation
import SoftwareEtudes

//MARK: - POLIS Item Attributes -

/// `PolisLifecycleStatus` defines the current status of the POLIS items (readiness to be used in different
/// environments)
///
/// Each POLIS type (Provider, Observing Site, Observatory, etc.) should include `PolisLifecycleStatus` (as part of
/// ``PolisItemAttributes``).
///
/// `PolisLifecycleStatus` will determine the syncing policy, as well as visibility of the POLIS items within
/// client implementations. Implementations should adopt following behaviours:
/// - `inactive`  - do not sync, but continue monitoring
/// - `active`    - must be synced and monitored
/// - `deleted`   - sync the `PolisItemAttributes` only to prevent secondary propagation of the record and to lock the
/// UUID of the item
/// - `suspended` - sync the `PolisItemAttributes`, but do not use the service provider or the observing site. Suspended
/// is used to mark that the item does not follow the POLIS standard, or violates community rules. Normally entities first
/// will be worried, and if they continue to not follow standards and rules, they will be deleted.
/// - `unknown`   - do not sync, but continue monitoring
public enum PolisLifecycleStatus: String, Codable {

    /// `inactive` indicates new, being edited, or in process of being upgraded providers.
    case inactive

    /// `active` indicates a production provider that is publicly accessible.
    case active

    /// `deleted` is needed to prevent reappearance of disabled providers or sites.
    case deleted

    /// `suspended` marks providers violating the standard (temporary or permanently).
    case suspended

    /// `unknown` marks a provider with unknown status, and is mostly used when observing site or instrument has
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
/// If XML encoding / decoding is used, it is recommended to implement the `PolisItemAttributes` as attributes of the
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

// Many POLIS types have reference to contact people (owners of sites, admins, project managers). Later we need to add
// Institutions as well and handle the messiness of addresses, countries, languages, phone numbers and other
// developer's nightmares. We think it's perhaps the best in the future to rely to external implementation for address
// management.
// On the other hand the implementation of contact (in order to allow to communicate with POLIS providers site admins) is
// simple enough task and therefore current implementation of POLIS includes contact-only related types.

/// `PolisCommunication` defines different types of communication channels in addition to the default email address and
/// mobile number.
///
/// The current list includes just a handful of popular communication channels. Emerging apps like Signal and Telegram
/// are not currently included, nor are local Chinese and Russian social media communication channels. If you need
/// such channels, please submit a pool request.
///
/// The type implements the `Codable` protocol
public enum PolisCommunication {

    /// Twitter user id, e.g. @AstroPolis "@" is expected to be part of the id
    case twitter(userName: String)

    /// Phone number used by WhatsApp. The phone number should include the country code, start with "+", and contain no
    /// spaces, brackets, or other formatting characters. No validation is provided.
    case whatsApp(phone: String)

    /// The Facebook user id is only the part of the URL after "www.facebook.com/".
    case facebook(id: String)

    /// Instagram user id, e.g. @AstroPolis "@" is expected to be part of the id
    case instagram(userName: String)

    /// Skype user id
    case skype(id: String)
}

/// `PolisAdminContact` defines a simple way to contact a provider admin, an observing site owner, or an observatory admin.
///
/// It is important to be able to contact the admin of a POLIS service provider or the admin or the owner of an observing
/// site, however one should not forget that all POLIS data is publicly available and therefore should expose possible
/// private information as little as possible. It is preferred not to expose private email addresses, phone numbers, or
/// twitter accounts, but only publicly available organisation contacts.
///
/// The type implements the `Codable` protocol
public struct PolisAdminContact {

    /// It is recommended that the admin's name is either omitted, or describes admin's role, e.g. "The managing director
    /// of Mountain Observatory"
    public var name: String?

    /// Email is the most reliable and widely adopted communication channel, and therefore a valid email address is
    /// required. To protect privacy, it is recommended that the email address is assigned to the institution,
    /// e.g. "office@mountain-observatory.org"
    public var email: String

    /// Consider giving only institution phone numbers - not private ones. The phone number should include the country
    /// code, starting with "+", and should contain no spaces, brackets, or other formatting characters. No validation
    /// is provided.
    public var mobilePhone: String?

    /// Possibly empty list (array) of additional communication channels of type ``Communicating``.
    public var additionalCommunicationChannels: [PolisCommunication]

    /// `notes` can contain additional contact info, e.g. "The admin could be contacted only during office hours"
    public var notes: String?

    /// Designated initialiser
    ///
    /// Only the `email` is a required parameter. It must contain well formatted email addresses. If the email is not a
    /// valid one, `nil` will be returned.
    public init?(name:                            String?,
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

//MARK: - POLIS Directory Entry -
/// `PolisProviderType` defines different types of POLIS providers.
///
/// The type implements the `Codable` and `CustomStringConvertible` protocols
public enum PolisProviderType {
    /// Only `public` provider should be used in production or by publicly available client apps or websites. Public
    /// providers should run on servers with enough bandwidth and computational power capable of accommodating multiple
    /// parallel client requests every second.
    case `public`

    /// `private` provider's main purpose is to act as a local cache for larger organisations and should not be accessed
    /// from outside. They might require user authentication.
    case `private`

    /// `local` could be used for clients running on mobile devices or desktop apps. It is a disposable local (often
    /// offline) cache.
    case local

    /// `experimental` providers are sandboxes for new developments, and might require authentication for access. They
    /// are allowed to be non-compliant with the POLIS standard.
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

    /// `attributes` encapsulate entries unique identification and status.
    ///
    /// `attributes` are marked with "private(set)" on purpose. Only the framework should change the attributes and
    /// potential changes should be done only at specific moments of the lifespan of the entry. Otherwise syncing could
    /// be badly broken.
    public private(set) var attributes: PolisItemAttributes

    /// The fully qualified URL of the service provider, e.g. https://polis.observer
    public              var url: String

    /// An array of supported POLIS protocol levels
    ///
    /// Possible values are 1, 2, and 3. If level 2 is supported, level 1 is also expected to be supported, etc. Currently
    /// only this framework supports only level 1.
    public              var supportedProtocolLevels: [UInt8]

    /// An array of supported POLIS standard's versions
    ///
    /// The versions should comply to the [Semantic Version](https://semver.org) specification. In order to avoid
    /// complexity it is recommended to support limited number of versions.
    public              var supportedAPIVersions: [SemanticVersion]

    /// Defines the type of the POLIS service provider e.g. public, experimental, mirror, ...
    public              var providerType: PolisProviderType

    /// POLIS service provider's admin contact
    ///
    /// It is recommended that the contact information exposes no or very limited personal information
    public              var contact: PolisAdminContact

    /// `id` is needed to make the structure `Identifiable`
    ///
    /// `id` refers to attributes UUID and should never be changed.
    public              var id: UUID { attributes.id }

    /// Designated initialiser.
    public init(attributes:              PolisItemAttributes,
                url:                     String,
                providerDescription:     String?,
                supportedProtocolLevels: [UInt8],
                supportedAPIVersions:    [SemanticVersion],
                providerType:            PolisProviderType,
                contact:                 PolisAdminContact) {
        self.attributes              = attributes
        self.url                     = url
        self.supportedProtocolLevels = supportedProtocolLevels
        self.supportedAPIVersions    = supportedAPIVersions
        self.providerType            = providerType
        self.contact                 = contact
    }
}

/// `PolisDirectory` is the list of all known Polis providers.
///
/// To avoid confusion (and potential syncing errors) it is recommended that the directory does not contain the POLIS
/// service provider entry that serves the directory list.
/// The type implements the `Codable` protocol.
public struct PolisDirectory  {
    public var lastUpdate: Date                // Used for syncing
    public var entries: [PolisDirectoryEntry]  // List of all known providers

    /// Designated initialiser.
    /// - Parameters:
    ///   - lastUpdate: if omitted, the current date and time will be used
    ///   - entries: possibly empty list of known POSIL service providers
    public init(lastUpdate: Date = Date(),
                entries: [PolisDirectoryEntry]) {
        self.lastUpdate = lastUpdate
        self.entries    = entries
    }
}



//MARK: - Making types Codable and CustomStringConvertible -

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
            case .public:         return "public"
            case .private:        return "private"
            case .local:          return "local"
            case .experimental:   return "experimental"
            case .mirror(let id): return "mirror(id: \(id)"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case providerType = "provider_type"
        case mirrorParams = "mirror_params"
    }

    private enum ProviderType: String, Codable { case `public`, `private`, local, experimental, mirror }

    private struct MirrorParams: Codable { let id: String }

}

//MARK: - PolisDirectoryEntry
extension PolisDirectoryEntry: Codable {
    private enum CodingKeys: String, CodingKey {
        case attributes
        case url
        case supportedProtocolLevels = "supported_protocol_levels"
        case supportedAPIVersions    = "supported_api_versions"
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
