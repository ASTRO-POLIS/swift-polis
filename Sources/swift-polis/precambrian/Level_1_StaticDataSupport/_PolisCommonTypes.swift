                                                                             //===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
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

// This file contains several unrelated Swift types that are used in different sources.


//MARK: - Images -
/// A source for images related to a single item, such as an observing site, a satellite, a telescope, or a camera.
///
/// A POLIS client can use an image in many different ways—as a thumbnail, a full image, a banner, etc. A `PolisImageSource` could have multiple `ImageItem`s
/// that fulfil the needs of the client application.
///
/// Each image from the set defines its index within the set (used for sorting), and image attributes (source URL, description and accessibility description, as well as
/// information about the copyright holder and copyright type).
///
/// **Important note:** POLIS providers should only use images that are either open source or have explicitly requested and received rights of use from the copyright holder!
public struct PolisImageSource: Codable, Identifiable {

    //TODO: We need comprehensive documentation! How are we going to use all this stuff?

    /// A type defining the author's copyright claims on the image.
    public enum CopyrightHolderType: Codable {

        public typealias RawValue = String


        /// The POLIS contributor took the photo
        case polisContributor(id: UUID)

        /// Someone at Tuparev Technologies' StarCluster team took the photo, and therefore it is public domain.
        case starClusterImage

        /// Most photos from Wikipedia etc.
        case creativeCommons(source: URL)

        /// Explicit permission of the copyright holder
        case openSource(source: URL)

        /// POLIS can use such images only with the explicit permission of the copyright holder.
        case useWithOwnersPermission(text: String, explanationNotes: String?)

        /// In case the copyright holder is still unknown, this image could NOT be shown in clients or used in any other way!
        case pendingInformation
    }
    
    // TODO: Clarify this documentation. It's unclear what ImageItem is.
    /// `ImageItem` defines one of potentially multiple images of the same item.
    ///
    /// It is important to note that POLIS data may be viewed by kids. Therefore, all images must be verified before made public. The `lastUpdate` attribute
    /// can help the curator of the data set verify new entries.
    //TODO: Do we need to know the image size and aspect ratio?
    public struct ImageItem: Codable {
        public let index: UInt
        public var lastUpdate: Date
        public let originalSource: URL
        public let description: String?
        public let accessibilityDescription: String?
        public let copyrightHolder: CopyrightHolderType

        public init(index: UInt,
                    lastUpdate: Date                     = Date.now,
                    originalSource: URL,
                    description: String?                 = nil,
                    accessibilityDescription: String?    = nil,
                    copyrightHolder: CopyrightHolderType = .pendingInformation) {
            self.index                    = index
            self.lastUpdate               = lastUpdate
            self.originalSource           = originalSource
            self.description              = description
            self.accessibilityDescription = accessibilityDescription
            self.copyrightHolder          = copyrightHolder
        }
    }

    public enum ImageSourceError: Error {
        case duplicateIndex
        case indexNotFound
        case unaccessibleURL
    }

    public let id: UUID
    
    /// The metadata of the images associated with this `PolisImageSource`.
    public var imageItems = [ImageItem]()

    public init(id: UUID) { self.id = id }
    
    /// Add an image to this image source.
    /// - Parameter item: The `ImageItem` associated with the image to be added.
    public mutating func addImage(_ item: ImageItem) async throws {
        if indexSet.contains(item.index) { throw ImageSourceError.duplicateIndex }

        do {
            for try await _ in item.originalSource.resourceBytes { break }
        }
        catch { throw ImageSourceError.unaccessibleURL }

        indexSet.insert(item.index)
        imageItems.append(item)
    }
    
    /// Remove an image from this image source.
    /// - Parameter index: The index of the image to be removed.
    /// - Returns: The removed image, if successful.
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

/// `PolisIdentity` uniquely identifies and defines the status of almost every POLIS item and defines external relationships to other items (or POLIS objects of any type).
///
/// The idea of `POLISIdentity` comes from the analogous type that could be found in the `RTML` standard. The RTML references turned out to be extremely
/// useful for relating items within one RTML document and linking RTML documents to each other.
///
/// `PolisIdentity` is an essential a part of nearly every POLIS type. They are needed to uniquely identify and describe each item (object) and to establish
/// parent-child relationships between them, as well as provide enough information for the syncing of POLIS Providers.
///
/// Parent - child relationships should be defined by nesting data structures.
///
/// If and when XML encoding and decoding is used, it is strongly recommended to implement the `PolisIdentity` as attributes of the corresponding type (Element).
public struct PolisIdentity: Codable, Identifiable {
    
    /// The current status of the POLIS item and its readiness to be used in different environments.
    ///
    /// Each POLIS type (Provider, Observing Site, Device, etc.) should include `LifecycleStatus` (as part of
    /// ``PolisIdentity``).
    ///
    /// `LifecycleStatus` will determine the syncing policy as well as the visibility of the POLIS items within client
    /// implementations. Implementations should adopt the following behaviours:
    /// - `inactive`  - do not sync, but continue monitoring
    /// - `active`    - must be synced and monitored
    /// - `deleted`   - sync the `PolisItemAttributes` only to prevent secondary propagation of the record and to lock the
    /// UUID of the item
    /// - `delete`    - delete the item
    /// - `suspended` - sync the `PolisItemAttributes`, but do not use the service provider or the observing site. Suspended
    /// is used to mark that the item does not follow the POLIS standard, or violates community rules. Normally entities
    /// will be warned first, and if they continue to break standards and rules, they will be deleted.
    /// - `unknown`   - do not sync, but continue monitoring
    public enum LifecycleStatus: String, Codable {

        /// `inactive` indicates new, being edited, or in process of being upgraded by the provider(s).
        case inactive

        /// `active` indicates a production provider that is publicly accessible.
        case active

        /// Item still exists and has historical value but is not operational.
        case historic

        /// `deleted` is needed to prevent reappearance of disabled providers or sites.
        case deleted

        /// After marking an item for deletion, wait for a year (check `lastUpdate`) and start marking the item as
        /// `delete`. After 18 months, remove the deleted items. It is assumed that 1.5 years is enough for all providers
        /// to mark the corresponding item as deleted.
        case delete

        /// `suspended` indicates providers violating the standard (temporary or permanently).
        case suspended

        /// `unknown` indicates a provider with unknown status, and is mostly used when the observing site or instrument has
        /// unknown status.
        case unknown
    }

    /// Globally unique identifier (UUID version 4) (ID in XML). The `id` is needed for `Identifiable` protocol
    /// conformance.
    public let id: UUID

    /// Pointers to externally defined items (IDREF in XML). It is recommended that the references are URLs (e.g.
    /// https://monet.org/instruments/12345 or telescope.observer://instriment123456)
    public var references: [String]?

    /// Determines the current status of the POLIS item (object).
    public var status: LifecycleStatus

    /// Latest update time. Used primarily for syncing.
    public var lastUpdate: Date

    /// Human readable name of the item (object). It is recommended to assign a unique name to avoid potential confusions.
    public var name: String

    /// Human readable automationLabel of the item (object). If present it is recommended to assign a unique label to avoid
    /// potential confusions.
    public var abbreviation: String?

    /// The purpose of the optional `automationLabel` is to act as a unique target for scripts and other software
    /// packages. As an example, the observatory control software could search for an instrument with a given label and
    /// set its status or issue commands etc. This could be used to sync with ASCOM or INDI based systems.
    public var automationLabel: String? // For script etc. support (internal to the site use...)

    /// Short optional item (object) description. In XML schema, this should be max 256 characters for RTML interoperability.
    public var shortDescription: String?

    /// Designated initialiser.
    ///
    /// Only the `name` parameter is required. All other parameters have reasonable default values.
    public init(id: UUID                  = UUID(),
                references: [String]?     = nil,
                status: LifecycleStatus   = LifecycleStatus.unknown,
                lastUpdate: Date          = Date(),
                name: String,
                abbreviation: String?     = nil,
                automationLabel: String?  = nil,
                shortDescription: String? = nil) {
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
// developer's nightmares. We think it's perhaps the best in the future to rely on an external implementation for address
// management.
// On the other hand the implementation of contact channels (in order to allow communication with POLIS providers site admins)
// is a simple enough task and therefore the current implementation of POLIS includes contact-only related types.


/// `PolisAdminContact` defines a simple way to contact a provider admin, an observing site owner, or an observatory
/// admin.
///
/// It is important to be able to contact the admin of a POLIS service provider or the admin or the owner of an
/// observing site, but one should not forget that all POLIS data is publicly available and therefore should not
/// expose private information if possible. It is preferable not to expose private email addresses, phone numbers, or
/// twitter accounts, but only publicly available organisation contacts or pages.
///
/// The type implements the `Codable` protocol.
public struct PolisAdminContact: Identifiable {

    /// `Communication` defines different types of communication channels in addition to the default email address and
    /// mobile number.
    ///
    /// The current list includes just a handful of popular communication channels. Emerging apps like Signal and Telegram
    /// are not currently included, nor are local Chinese and Russian social media communication channels. If you need
    /// such channels, please submit a pull request to the POLIS developers.
    ///
    /// The type implements the `Codable` protocol and is thus JSON-representable.
    public enum Communication {

        /// Twitter user id, e.g. @AstroPolis. "@" is expected to be part of the id.
        case twitter(username: String)

        /// Phone number used by WhatsApp. The phone number should include the country code, starting with "+", and contain no
        /// spaces, brackets, or other formatting characters. Currently no validation is provided.
        case whatsApp(phone: String)

        /// The Facebook user id is only the part of the URL after "www.facebook.com/".
        case facebook(id: String)

        /// Instagram user id, e.g. @AstroPolis. "@" is expected to be part of the id.
        case instagram(username: String)

        /// Skype user id
        case skype(id: String)
    }

    /// The admin's unique identifier.
    ///
    /// An administrator needs a unique identifier in order to define login credentials and identify sources of data changes and contributions.
    public let id: UUID

    /// The admin's name.
    ///
    /// It is recommended that an admin's name is either omitted or describes the admin's role, e.g. "Managing
    /// Director of Mountain Observatory"
    public var name: String?

    /// The admin's email address.
    ///
    /// Email is the most reliable and widely adopted communication channel, and therefore a valid email address is
    /// required. To protect privacy, it is recommended that the email address is assigned to the institution,
    /// e.g. "office@mountain-observatory.org". A valid email is expected.
    public var email: String

    /// The admin's phone number.
    ///
    /// Consider giving only institution phone numbers - not private ones. The phone number should include the country
    /// code, starting with "+", and should contain no spaces, brackets, or other formatting characters. No validation
    /// is provided.
    public var phone: String?

    /// An array of additional communication channels for contacting the admin, if applicable.
    public var additionalCommunicationChannels: [Communication]?

    /// Miscellaneous information that doesn't fit in any other property.
    ///
    /// Notes can contain additional information on how to contact the admin, such as "The admin could be contacted only during office hours," or "The admin is
    /// on vacation from 01/12 to 20/12."
    public var notes: String?

    /// Designated initialiser.
    ///
    /// Only the `email` is a required parameter. It must contain well formatted email addresses. If the email is not a
    /// valid one, `nil` will be returned.
    public init?(id:                              UUID             = UUID(),
                 name:                            String?,
                 email:                           String,
                 phone:                           String?          = nil,
                 additionalCommunicationChannels: [Communication]? = nil,
                 notes:                           String?          = nil) {
        guard email.isValidEmailAddress() else { return nil }

        self.id                              = id
        self.name                            = name
        self.email                           = email
        self.phone                           = phone
        self.additionalCommunicationChannels = additionalCommunicationChannels
        self.notes                           = notes
    }
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

//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let base      = try container.decode(CommunicationType.self, forKey: .communicationType)
//
//        switch base {
//            case .twitter:
//                let twitterParams = try container.decodeIfPresent(TwitterParams.self, forKey: .twitterParams)
//                self = .twitter(username: twitterParams!.username.mustStartWithAtSign())
//            case .whatsApp:
//                let whatsAppParams = try container.decodeIfPresent(WhatsAppParams.self, forKey: .whatsAppParams)
//                self = .whatsApp(phone: whatsAppParams!.phone)
//            case .facebook:
//                let facebookParams = try container.decodeIfPresent(FacebookParams.self, forKey: .facebookParams)
//                self = .facebook(id: facebookParams!.id)
//            case .instagram:
//                let instagramParams = try container.decodeIfPresent(InstagramParams.self, forKey: .instagramParams)
//                self = .instagram(username: instagramParams!.username.mustStartWithAtSign())
//            case .skype:
//                let skypeParams = try container.decodeIfPresent(SkypeParams.self, forKey: .skypeParams)
//                self = .skype(id: skypeParams!.id)
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        switch self {
//            case .twitter(let username):
//                try container.encode(CommunicationType.twitter, forKey: .communicationType)
//                try container.encode(TwitterParams(username: username), forKey: .twitterParams)
//            case .whatsApp(let phone):
//                try container.encode(CommunicationType.whatsApp, forKey: .communicationType)
//                try container.encode(WhatsAppParams(phone: phone), forKey: .whatsAppParams)
//            case .facebook(let id):
//                try container.encode(CommunicationType.facebook, forKey: .communicationType)
//                try container.encode(FacebookParams(id: id), forKey: .facebookParams)
//            case .instagram(let username):
//                try container.encode(CommunicationType.instagram, forKey: .communicationType)
//                try container.encode(InstagramParams(username: username), forKey: .instagramParams)
//            case .skype(let id):
//                try container.encode(CommunicationType.skype, forKey: .communicationType)
//                try container.encode(SkypeParams(id: id), forKey: .skypeParams)
//        }
//    }
//
//    public enum CodingKeys: String, CodingKey {
//        case communicationType = "communication_type"
//        case twitterParams     = "twitter"
//        case whatsAppParams    = "whatsapp"
//        case facebookParams    = "facebook"
//        case instagramParams   = "instagram"
//        case skypeParams       = "skype"
//        case username          = "user_name"
//    }
//
//    private enum CommunicationType: String, Codable { case twitter, whatsApp, facebook, instagram, skype }
//
//    private struct TwitterParams: Codable   { let username: String }
//    private struct WhatsAppParams: Codable  { let phone: String }
//    private struct FacebookParams: Codable  { let id: String }
//    private struct InstagramParams: Codable { let username: String }
//    private struct SkypeParams: Codable     { let id: String }
//
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

