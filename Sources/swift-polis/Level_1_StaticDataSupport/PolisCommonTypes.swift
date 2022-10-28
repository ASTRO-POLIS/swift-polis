//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2022 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//


import Foundation

// This file contains several unrelated Swift types that are accessed from different and also mostly unrelated sources.

public struct PolisMeasurement: Codable {
    public let value: Double
    public let unit: String
    public let time: Date?

    public init(value: Double, unit: String, time: Date? = nil) {
        self.value = value
        self.unit  = unit
        self.time  = time
    }
}

public struct PolisImageSource: Codable, Identifiable {

    public enum CopyrightHolderType: Codable {
        case polisContributor(id: UUID)
        case starClusterImage
        case creativeCommons(source: URL)
        case openSource(source: URL)
        case useWithOwnersPermission(text: String, explanationNotes: String?)
    }

    public struct ImageItem: Codable {
        public let index: UInt
        public var lastUpdate: Date
        public let originalSource: URL
        public let description: String?
        public let accessibilityDescription: String?
        public let copyrightHolder: CopyrightHolderType
    }

    public enum ImageSourceError: Error {
        case duplicateIndex
        case indexNotFound
        case unaccessibleURL
    }

    public let id: UUID
    public var imageItems = [ImageItem]()

    public init(id: UUID) { self.id = id }

    public mutating func addImage(item: ImageItem) async throws {
        if indexSet.contains(item.index) { throw ImageSourceError.duplicateIndex }

        do {
            for try await _ in item.originalSource.resourceBytes { break }
        }
        catch { throw ImageSourceError.unaccessibleURL }

        indexSet.insert(item.index)
        imageItems.append(item)
    }

    public mutating func removeImage(at index: UInt) throws -> ImageItem? {
        if !indexSet.contains(index) { throw ImageSourceError.indexNotFound }
        var item: ImageItem?

        for anItem in imageItems {
            if anItem.index == index {
                item = anItem
                break
            }
        }
        return item
    }

    private var indexSet = Set<UInt>()
}
//MARK: - POLIS Identity related types -


/// `PolisIdentity` uniquely identifies and defines the status of almost every POLIS item and defines external
/// relationships to other items (or POLIS objects of any type).
///
/// The idea of POLIS Identity comes from analogous type that could be found in the `RTML` standard. The
/// RTML references  turned out to be extremely useful for relating items within one RTML document and linking RTML
/// documents to each other.
///
/// `PolisIdentity` is an essential part of (almost) every POLIS type. They are needed to uniquely identify and
/// describe each item (object) and establish parent-child relationships between them, as well as provide enough
/// informationIn for the syncing of POLIS Providers.
///
/// Parent - child relationship should be defined by nesting data structures.
///
/// If /when XML encoding and decoding is used, it is strongly recommended to implement the `PolisIdentity` as
/// attributes of the corresponding type (Element).
public struct PolisIdentity: Codable, Identifiable {

    /// `LifecycleStatus` defines the current status of the POLIS items (readiness to be used in different
    /// environments)
    ///
    /// Each POLIS type (Provider, Observing Site, Device, etc.) should include `LifecycleStatus` (as part of
    /// ``PolisIdentity``).
    ///
    /// `LifecycleStatus` will determine the syncing policy, as well as visibility of the POLIS items within client
    /// implementations. Implementations should adopt following behaviours:
    /// - `inactive`  - do not sync, but continue monitoring
    /// - `active`    - must be synced and monitored
    /// - `deleted`   - sync the `PolisItemAttributes` only to prevent secondary propagation of the record and to lock the
    /// UUID of the item
    /// - `delete`    - delete the item
    /// - `suspended` - sync the `PolisItemAttributes`, but do not use the service provider or the observing site. Suspended
    /// is used to mark that the item does not follow the POLIS standard, or violates community rules. Normally entities first
    /// will be warned, and if they continue to not follow standards and rules, they will be deleted.
    /// - `unknown`   - do not sync, but continue monitoring
    public enum LifecycleStatus: String, Codable {

        /// `inactive` indicates new, being edited, or in process of being upgraded providers.
        case inactive

        /// `active` indicates a production provider that is publicly accessible.
        case active

        /// `deleted` is needed to prevent reappearance of disabled providers or sites.
        case deleted

        /// After marking an item for deleted, wait for a year (check `lastUpdate`) and start marking the item as
        /// `delete`. After 6 months, remove the deleted items. It is assumed, that 1.5 year is enough for all provides
        /// to mark the corresponding item as deleted.
        case delete

        /// `suspended` marks providers violating the standard (temporary or permanently).
        case suspended

        /// `unknown` marks a provider with unknown status, and is mostly used when observing site or instrument has
        /// unknown status.
        case unknown
    }

    /// Globally unique identifier (UUID version 4) (ID in XML). The `id` is needed for `Identifiable` protocol
    /// conformance.
    public let id: UUID

    /// Pointers to externally defined item (IDREF in XML). It is recommended that the references are URIs (e.g.
    /// https://monet.org/instruments/12345 or telescope.observer://instriment123456)
    public var references: [String]?

    /// Determines the current status of the POLIS item (object).
    public var status: LifecycleStatus

    /// Latest update time. Used primarily for syncing.
    public var lastUpdate: Date

    /// Human readable name of the item (object). It is recommended to be unique to avoid potential confusions.
    public var name: String

    /// Human readable automationLabel of the item (object). If present it is recommended to be unique to avoid
    /// potential confusions.
    public var abbreviation: String?

    /// The purpose of the optional `automationLabel` is to act as a unique target for scripts and other software
    /// packages. As an example, the observatory control software could search for an instrument with such label and
    /// set its status or issue commands etc. This could be used to sync with ASCOM or INDI based systems.
    public var automationLabel: String? // For script etc. support (internal to the site use...)

    /// Short optional item (object) description. In XML schema should be max 256 characters for RTML interoperability.
    public var shortDescription: String?

    /// Designated initialiser.
    ///
    /// Only the `name` parameter is required. All other parameters have reasonable default values.
    public init(id: UUID                   = UUID(),
                references: [String]?      = nil,
                status: LifecycleStatus    = LifecycleStatus.unknown,
                lastUpdate: Date           = Date(),
                name: String,
                abbreviation: String?      = nil,
                automationLabel: String?   = nil,
                shortDescription: String?  = nil) {
        self.id               = id
        self.references       = references
        self.status           = status
        self.lastUpdate       = lastUpdate
        self.name             = name
        self.abbreviation     = abbreviation
        self.automationLabel  = automationLabel
        self.shortDescription = shortDescription
    }
}

//MARK: - Communication related types -

// Many POLIS types have reference to contact people (owners of sites, admins, project managers). Later we need to add
// Institutions as well and handle the messiness of addresses, countries, languages, phone numbers and other
// developer's nightmares. We think it's perhaps the best in the future to rely to external implementation for address
// management.
// On the other hand the implementation of contact (in order to allow to communicate with POLIS providers site admins)
// is simple enough task and therefore current implementation of POLIS includes contact-only related types.


/// `PolisAdminContact` defines a simple way to contact a provider admin, an observing site owner, or an observatory
/// admin.
///
/// It is important to be able to contact the admin of a POLIS service provider or the admin or the owner of an
/// observing site, however one should not forget that all POLIS data is publicly available and therefore should not
/// expose private information if possible. It is preferred not to expose private email addresses, phone numbers, or
/// twitter accounts, but only publicly available organisation contacts.
///
/// The type implements the `Codable` protocol
public struct PolisAdminContact: Identifiable {

    /// `Communication` defines different types of communication channels in addition to the default email address and
    /// mobile number.
    ///
    /// The current list includes just a handful of popular communication channels. Emerging apps like Signal and Telegram
    /// are not currently included, nor are local Chinese and Russian social media communication channels. If you need
    /// such channels, please submit a pool request.
    ///
    /// The type implements the `Codable` protocol
    public enum Communication {

        /// Twitter user id, e.g. @AstroPolis "@" is expected to be part of the id
        case twitter(username: String)

        /// Phone number used by WhatsApp. The phone number should include the country code, start with "+", and contain no
        /// spaces, brackets, or other formatting characters. Currently no validation is provided.
        case whatsApp(phone: String)

        /// The Facebook user id is only the part of the URL after "www.facebook.com/".
        case facebook(id: String)

        /// Instagram user id, e.g. @AstroPolis "@" is expected to be part of the id
        case instagram(username: String)

        /// Skype user id
        case skype(id: String)
    }

    /// Admin's ID is needed for defining login credentials and identifying sources of data changes and contributions
    public let id: UUID

    /// It is recommended that the admin's name is either omitted, or describes admin's role, e.g. "The managing
    /// director of Mountain Observatory"
    public var name: String?

    /// Email is the most reliable and widely adopted communication channel, and therefore a valid email address is
    /// required. To protect privacy, it is recommended that the email address is assigned to the institution,
    /// e.g. "office@mountain-observatory.org". It is expected the email to be valid.
    public var email: String

    /// Consider giving only institution phone numbers - not private ones. The phone number should include the country
    /// code, starting with "+", and should contain no spaces, brackets, or other formatting characters. No validation
    /// is provided.
    public var phone: String?

    /// Possibly empty list (array) of additional communication channels of type ``PolisCommunication``.
    public var additionalCommunicationChannels: [Communication]

    /// `notes` can contain additional contact info, e.g. "The admin could be contacted only during office hours"
    public var notes: String?

    /// Designated initialiser
    ///
    /// Only the `email` is a required parameter. It must contain well formatted email addresses. If the email is not a
    /// valid one, `nil` will be returned.
    public init?(id:                              UUID            = UUID(),
                 name:                            String?,
                 email:                           String,
                 phone:                           String?         = nil,
                 additionalCommunicationChannels: [Communication] = [Communication](),
                 notes:                           String?) {
        guard email.isValidEmailAddress() else { return nil }

        self.id                              = id
        self.name                            = name
        self.email                           = email
        self.phone                           = phone
        self.additionalCommunicationChannels = additionalCommunicationChannels
        self.notes                           = notes
    }
}




//MARK: - Directions -

/// `PolisDirection` is used to represent either a rough direction (of 16 possibilities) or exact direction in degree
/// represented as a double number (e.g. 57.349)
///
/// Directions are used to describe things like dominant wind direction of observing site, or direction of doors of
/// different types of enclosures.
public enum PolisDirection: Codable {

    /// A list of 16 rough directions
    ///
    /// Rough direction could be used when it is not important to know or impossible to measure the exact direction.
    /// Examples include the wind direction, or the orientations of the doors of clamshell enclosure.
    public enum RoughDirection: String, Codable {
        case north          = "N"
        case northNorthEast = "NNE"
        case northEast      = "NE"
        case eastNorthEast  = "ENE"

        case east           = "E"
        case eastSouthEast  = "ESE"
        case southEast      = "SE"
        case southSouthEast = "SSE"

        case south          = "S"
        case southSouthWest = "SSW"
        case southWest      = "SW"
        case westSouthWest  = "WSW"

        case west           = "W"
        case westNorthWest  = "WNW"
        case northWest      = "NW"
        case northNorthWest = "NNW"
    }

    case rough(direction: RoughDirection)
    case exact(degree: Double)                  //TODO: Clock or anticlockwise? e.g. 157.12
}



//MARK: - Type extensions -



//MARK: - Identity
public extension PolisIdentity {
    enum CodingKeys: String, CodingKey {
        case id
        case references
        case status
        case lastUpdate       = "last_update"
        case name
        case abbreviation
        case automationLabel  = "automation_label"
        case shortDescription = "short_description"
    }
}

//MARK: - ContactType
extension PolisAdminContact.Communication: Codable, CustomStringConvertible {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base      = try container.decode(CommunicationType.self, forKey: .communicationType)

        switch base {
            case .twitter:
                let twitterParams = try container.decodeIfPresent(TwitterParams.self, forKey: .twitterParams)
                self = .twitter(username: twitterParams!.username.mustStartWithAtSign())
            case .whatsApp:
                let whatsAppParams = try container.decodeIfPresent(WhatsAppParams.self, forKey: .whatsAppParams)
                self = .whatsApp(phone: whatsAppParams!.phone)
            case .facebook:
                let facebookParams = try container.decodeIfPresent(FacebookParams.self, forKey: .facebookParams)
                self = .facebook(id: facebookParams!.id)
            case .instagram:
                let instagramParams = try container.decodeIfPresent(InstagramParams.self, forKey: .instagramParams)
                self = .instagram(username: instagramParams!.username.mustStartWithAtSign())
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
                try container.encode(TwitterParams(username: username), forKey: .twitterParams)
            case .whatsApp(let phone):
                try container.encode(CommunicationType.whatsApp, forKey: .communicationType)
                try container.encode(WhatsAppParams(phone: phone), forKey: .whatsAppParams)
            case .facebook(let id):
                try container.encode(CommunicationType.facebook, forKey: .communicationType)
                try container.encode(FacebookParams(id: id), forKey: .facebookParams)
            case .instagram(let username):
                try container.encode(CommunicationType.instagram, forKey: .communicationType)
                try container.encode(InstagramParams(username: username), forKey: .instagramParams)
            case .skype(let id):
                try container.encode(CommunicationType.skype, forKey: .communicationType)
                try container.encode(SkypeParams(id: id), forKey: .skypeParams)
        }
    }

    public enum CodingKeys: String, CodingKey {
        case communicationType = "communication_type"
        case twitterParams     = "twitter"
        case whatsAppParams    = "whatsapp"
        case facebookParams    = "facebook"
        case instagramParams   = "instagram"
        case skypeParams       = "skype"
        case username          = "user_name"
    }

    private enum CommunicationType: String, Codable { case twitter, whatsApp, facebook, instagram, skype }

    private struct TwitterParams: Codable   { let username: String }
    private struct WhatsAppParams: Codable  { let phone: String }
    private struct FacebookParams: Codable  { let id: String }
    private struct InstagramParams: Codable { let username: String }
    private struct SkypeParams: Codable     { let id: String }

    public var description: String {
        switch self {
            case .twitter(let username):   return "Twitter: \(username)"
            case .whatsApp(let phone):     return "WhatsApp: \(phone)"
            case .facebook(let id):        return "Facebook: \(id)"
            case .instagram(let username): return "Instagram: \(username)"
            case .skype(let id):           return "Skype: \(id)"
        }
    }
}

//MARK: - PolisContact
extension PolisAdminContact: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case additionalCommunicationChannels = "additional_communication_channels"
        case notes
    }
}

