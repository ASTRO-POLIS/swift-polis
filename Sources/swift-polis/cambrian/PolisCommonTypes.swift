//===----------------------------------------------------------------------===//
//  PolisCommonTypes.swift
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

/// The `PolisVisitingHours` struct is used to define periods of time when an ``PolisObservingSite`` could be visited, or the
/// working hours of the personnel.
///
/// Note that some sites might only be open during part of the year (e.g. because of difficult winter conditions) or may only be visited during
/// school vacations.
///
/// The first version of the the POLIS standard defines only an optional `note` string.  Future versions will add more structured types
/// expressing numerical periods like:
///    Mo-Fr: 16:00-18:00h or
///    June - September
/// Currently this more natural representation could be achieved by formatting `note` using `\n` (new lines) and tabs.
public struct PolisVisitingHours: Codable {
    public var note: String?

    public init(note: String? = nil) {
        self.note = note
    }
}

//MARK: - Property Values -
// Basic idea - value is always a string that is converted (if possible) to a typed value.
/// An object that represents a value a value with an accompanying unit.
///
/// Examples include telescope apertures, instrument wavelengths, etc. POLIS only defines the means of recording measurements. Client applications
/// using POLIS should implement unit conversions (if needed). Currently, a POLIS provider is not expected to make any conversions, but it might
/// check if the units are allowed.
///
/// Apple's Units types are not used here on purpose because of the lack of scientific accuracy and profound misunderstanding of how science works.
///
/// **Note:** This Measurement implementation is very rudimentary. It is a placeholder type. In future implementations, it will be replaced by external
/// implementations, capable of measurement computations and conversions.
public struct PolisPropertyValue: Codable, Equatable {

    public enum ValueKind: String, Codable {
        case string
        case int
        case float
        case double
    }

    //TODO: Make this Equitable and String CustomStringConvertible!

    public var valueKind: ValueKind

    /// The value of the measurement represented as a `String`
    public var value: String

    /// Unit of the measurement.
    ///
    /// The unit is expected to be in a format that is accepted by the astronomical community (as defined by the IAU, FITS Standard, etc).
    ///
    /// In the case that no unit is defined, the measurement has no dimension (e.g. counter).
    ///
    /// Examples:
    /// - "m"
    /// - "km"
    /// - "in"
    /// - "m^2"
    /// - "µm"
    /// - "solMass"
    /// - "eV"
    public var unit: String

    public init(valueKind: ValueKind, value: String,  unit: String) {
        self.valueKind  = valueKind
        self.value      = value
        self.unit       = unit
    }

    public func stringValue()  -> String? { value }
    public func intValue()     -> Int?    { Int(value) }
    public func floatValue()   -> Float?  { Float(value) }
    public func doubleValue()  -> Double? { Double(value) }

}

//MARK: - Directions -

/// `PolisDirection` is used to represent either a rough direction (of 16 possibilities) or exact direction in degree
/// represented as a double number (e.g. 57.349)
///
/// Directions are used to describe information such as dominant wind direction of observing site, or direction of doors of
/// different types of enclosures.
public struct PolisDirection: Codable {

    /// A list of 16 rough directions.
    ///
    /// These 16 directions are comprised of the 4 cardinal directions (north, east, south, west), the 4
    /// ordinal (also known as inter-cardinal) directions (northeast, northwest, southeast, southwest), and
    /// the 8 additional secondary inter cardinal directions (ex. ENE, SSW, WSW).
    ///
    /// Rough direction could be used when it is not important to know or impossible to measure the exact direction.
    /// Examples include the wind direction, or the orientations of the doors of a clamshell enclosure.
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

        public func direction() -> Double {
            switch self {
                case .north:          return 0.0
                case .northNorthEast: return 22.5
                case .northEast:      return 45.0
                case .eastNorthEast:  return 67.5
                case .east:           return 90.0
                case .eastSouthEast:  return 112.5
                case .southEast:      return 135.0
                case .southSouthEast: return 157.5
                case .south:          return 180.0
                case .southSouthWest: return 202.5
                case .southWest:      return 225.0
                case .westSouthWest:  return 247.5
                case .west:           return 270.0
                case .westNorthWest:  return 292.5
                case .northWest:      return 315.0
                case .northNorthWest: return 337.5
            }
        }
    }

    public enum DirectionError: Error {
        case bothPropertiesCannotBeNilError
        case bothPropertiesCannotBeNotNilError
    }

    public var roughDirection: RoughDirection? {
        didSet {
            if roughDirection != nil                              { exactDirection = nil }
            if (roughDirection == nil) && (exactDirection == nil) { roughDirection = oldValue }
        }
    }

    public var exactDirection: Double? {  // Clockwise e.g. 157.12
        didSet {
            if exactDirection != nil                              { roughDirection = nil }
            if (exactDirection == nil) && (roughDirection == nil) { exactDirection = oldValue }
        }
    }

    public init(roughDirection: RoughDirection? = nil, exactDirection: Double? = nil) throws {
        if (roughDirection == nil) && (exactDirection == nil) { throw DirectionError.bothPropertiesCannotBeNilError }
        if (roughDirection != nil) && (exactDirection != nil) { throw DirectionError.bothPropertiesCannotBeNotNilError }

        self.roughDirection = roughDirection
        self.exactDirection = exactDirection
    }

    // Clockwise e.g. 157.12
    public func direction() -> Double {
        if exactDirection != nil { return exactDirection! }
        else                     { return roughDirection!.direction() }
    }
}

//MARK: - POLIS Identity related types -

/// `PolisIdentity` uniquely identifies and defines the status of almost every POLIS item and defines external relationships to other items
/// (or POLIS objects of any type).
///
/// The idea of `PolisIdentity` comes from the analogous type that could be found in the `RTML` standard. The `RTML` references turned
/// out to be extremely useful for relating items within one `RTML` document and linking `RTML` documents to each other.
///
/// `PolisIdentity` is an essential a part of nearly every POLIS type. Identities are needed to uniquely identify and describe each item (object)
/// and to establish parent-child relationships between items, as well as provide enough information for the syncing of POLIS Providers.
///
/// If and when XML encoding and decoding is used, it is strongly recommended to implement the `PolisIdentity` as attributes of the
/// corresponding type (Element).
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
    /// https://monet.org/instruments/12345 or https://telescope.observer/instriment123456 )
    public var externalReferences: [String]?

    /// Determines the current status of the POLIS item (object).
    public var lifecycleStatus: LifecycleStatus

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
    public init(id: UUID                         = UUID(),
                externalReferences: [String]?    = nil,
                lifecycleStatus: LifecycleStatus = LifecycleStatus.unknown,
                lastUpdate: Date                 = Date(),
                name: String,
                abbreviation: String?            = nil,
                automationLabel: String?         = nil,
                shortDescription: String?        = nil) {
        self.id                 = id
        self.externalReferences = externalReferences
        self.lifecycleStatus    = lifecycleStatus
        self.lastUpdate         = lastUpdate
        self.name               = name
        self.abbreviation       = abbreviation
        self.automationLabel    = automationLabel
        self.shortDescription   = shortDescription
    }
}

//MARK: - POLIS Item -

/// `PolisItem` uniquely identifies almost every POLIS object and defines the hierarchies and references between different objects
///
/// Any `[[PolisDevice]]`,  Observing Source (site, mobile platform, Collaboration, Network, ...), or Resource (e.g. a manufacturer of astronomy related
/// hardware) must have a `PolisItem` to uniquely identify the object and build the logical and spacial hierarchy between them.
public struct PolisItem: Codable, Identifiable {


    /// `ModeOfOperation` ....
    public enum ModeOfOperation: String, Codable {
        case manual
        case manualWithAutomatedDetector              = "manual_with_automated_detector"
        case manualWithAutomatedDetectorAndScheduling = "manual_with_automated_detector_and_scheduling"
        case autonomous
        case remote
        case mixed                                       // e.g. in case of Network
        case other
        case unknown
    }

    public var identity: PolisIdentity
    public var modeOfOperation: ModeOfOperation?
    public var manufacturerID: UUID?
    public var owners: [PolisItemOwner]?

    public var imageSources: [PolisImageSource]?

    public var id: UUID { identity.id }

    public init(identity: PolisIdentity,
                modeOfOperation: ModeOfOperation  = .unknown,
                manufacturerID: UUID?             = nil,
                owners: [PolisItemOwner]?         = nil,
                imageSources: [PolisImageSource]? = nil ) {
        self.identity          = identity
        self.modeOfOperation   = modeOfOperation
        self.manufacturerID    = manufacturerID
        self.owners            = owners
        self.imageSources      = imageSources
    }
}

//MARK: - Item Ownership -

/// A type that defines the owner of an observing site or a device.
///
/// Files containing an owner's information are in general stored within the static file hierarchy of the observing site (or equivalent).
/// For performance reasons, it is recommended (but not required by the standard) that the service provider supports a directory of owners
/// (as this framework does). Such a cache of owners would of course have performance and data maintenance implications as well.
public struct PolisItemOwner: Codable {

    /// A type that describes the different kinds of owners of a POLIS item.
    ///
    /// `OwnershipType` is used to identify the ownership type of POLIS items (or devices) such as observing sites, telescopes,
    /// CCD cameras, weather stations, etc. Different cases should be self-explanatory. The `private` type should be utilised by
    /// amateurs and hobbyists.
    public enum OwnershipType: String, Codable {
        case university
        case research
        case commercial
        case school
        case network
        case government
        case ngo
        case club
        case consortium
        case cooperative
        case collaboration
        case `private`
        case other
    }

    public let ownershipType: OwnershipType
    public var adminContact: PolisAdminContact?
    public let abbreviation: String?   // e.g. MIT. MONET, BAO, ...

    public init(ownershipType: OwnershipType, abbreviation: String?, adminContact: PolisAdminContact? = nil) {
        self.ownershipType = ownershipType
        self.abbreviation  = abbreviation
        self.adminContact  = adminContact
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
    public struct Communication: Codable {

        /// Twitter user id, e.g. @AstroPolis. "@" is expected to be part of the id.
        public var twitterIDs: [String]?

        /// Phone number used by WhatsApp. The phone number should include the country code, starting with "+", and contain no
        /// spaces, brackets, or other formatting characters. Currently no validation is provided.
        public var whatsappPhoneNumbers: [String]?

        /// The Facebook user id is only the part of the URL after "www.facebook.com/".
        public var facebookIDs: [String]?

        /// Instagram user id, e.g. @AstroPolis. "@" is expected to be part of the id.
        public var instagramIDs: [String]?

        /// Skype user id
        public var skypeIDs: [String]?

        public init(twitterIDs: [String]?     = nil,
             whatsappPhoneNumbers: [String]?  = nil,
             facebookIDs: [String]?           = nil,
             instagramIDs: [String]?          = nil,
             skypeIDs: [String]?              = nil) {
            self.twitterIDs           = twitterIDs
            self.whatsappPhoneNumbers = whatsappPhoneNumbers
            self.facebookIDs          = facebookIDs
            self.instagramIDs         = instagramIDs
            self.skypeIDs             = skypeIDs
        }
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
    public var emailAddress: String

    /// The admin's phone number.
    ///
    /// Consider giving only institution phone numbers - not private ones. The phone number should include the country
    /// code, starting with "+", and should contain no spaces, brackets, or other formatting characters. No validation
    /// is provided.
    public var phoneNumber: String?

    /// An array of additional communication channels for contacting the admin, if applicable.
    public var additionalCommunication: Communication?

    /// Miscellaneous information that doesn't fit in any other property.
    ///
    /// Notes can contain additional information on how to contact the admin, such as "The admin could be contacted only during office hours," or "The admin is
    /// on vacation from 01/12 to 20/12."
    public var note: String?

    /// Designated initialiser.
    ///
    /// Only the `email` is a required parameter. It must contain well formatted email addresses. If the email is not a
    /// valid one, `nil` will be returned.
    public init?(id:                              UUID     = UUID(),
                 name:                            String?,
                 emailAddress:                    String,
                 phoneNumber:                     String?  = nil,
                 additionalCommunication: Communication?   = nil,
                 note:                           String?   = nil) {
        guard emailAddress.isValidEmailAddress() else { return nil }

        self.id                      = id
        self.name                    = name
        self.emailAddress            = emailAddress
        self.phoneNumber             = phoneNumber
        self.additionalCommunication = additionalCommunication
        self.note                    = note
    }
}

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
public struct PolisImageSource: Identifiable {

    //TODO: We need comprehensive documentation! How are we going to use all this stuff?

    /// A type defining the author's copyright claims on the image.
    public enum CopyrightHolderType: String, Codable {

        /// The POLIS contributor took the photo
        case polisContributor        = "polis_contributor"

        /// Someone at Tuparev Technologies' StarCluster team took the photo, and therefore it is public domain.
        case starClusterImage        = "star_cluster_image"

        /// Most photos from Wikipedia etc.
        case creativeCommons         = "creative_commons"

        /// Explicit permission of the copyright holder
        case openSource              = "open_source"

        /// POLIS can use such images only with the explicit permission of the copyright holder.
        case useWithOwnersPermission = "use_with_owners_permission"

        /// In case the copyright holder is still unknown, this image could NOT be shown in clients or used in any other way!
        case pendingInformation      = "pending_information"
    }

    // TODO: Clarify this documentation. It's unclear what ImageItem is.
    /// `ImageItem` defines one of potentially multiple images of the same item.
    ///
    /// It is important to note that POLIS data may be viewed by kids. Therefore, all images must be verified before made public. The `lastUpdate` attribute
    /// can help the curator of the data set verify new entries.
    //TODO: Do we need to know the image size and aspect ratio?
    public struct ImageItem: Identifiable {
        public enum ImageItemError: Error {
            case copyrightHolderReferenceMissing
            case copyrightHolderReferenceOrNoteMissing
        }

        public let id: UUID
        public var lastUpdate: Date
        public let originalSource: URL

        public let shortDescription: String?
        public let accessibilityDescription: String?

        public let copyrightHolderType: CopyrightHolderType
        public let copyrightHolderReference: String?
        public let copyrightHolderNote: String?

        public init(id: UUID                                 = UUID(),
                    lastUpdate: Date                         = Date.now,
                    originalSource: URL,
                    shortDescription: String?                = nil,
                    accessibilityDescription: String?        = nil,
                    copyrightHolderType: CopyrightHolderType = .pendingInformation,
                    copyrightHolderReference: String?        = nil,
                    copyrightHolderNote: String?             = nil) throws {
            self.id                       = id
            self.lastUpdate               = lastUpdate
            self.originalSource           = originalSource
            self.shortDescription         = shortDescription
            self.accessibilityDescription = accessibilityDescription
            self.copyrightHolderType      = copyrightHolderType
            self.copyrightHolderReference = copyrightHolderReference
            self.copyrightHolderNote      = copyrightHolderNote

            switch self.copyrightHolderType {
                case .polisContributor, .creativeCommons, .openSource:
                    if self.copyrightHolderReference == nil                                        { throw ImageItemError.copyrightHolderReferenceMissing }
                case .useWithOwnersPermission:
                    if (self.copyrightHolderReference == nil) || (self.copyrightHolderNote == nil) { throw ImageItemError.copyrightHolderReferenceOrNoteMissing }
                case .starClusterImage, .pendingInformation:
                    break
            }
        }
    }

    public let id: UUID

    /// The metadata of the images associated with this `PolisImageSource`.
    public var imageItems = [ImageItem]()

    public init(id: UUID = UUID()) { self.id = id }

    /// Add an image to this image source.
    /// - Parameter item: The `ImageItem` associated with the image to be added.
    public mutating func addImage(_ item: ImageItem) {
        for (index, imageItem) in imageItems.enumerated() {
            if imageItem.id == item.id {
                if imageItem.lastUpdate < item.lastUpdate {
                    imageItems.remove(at: index)
                    imageItems.append(item)
                    return
                }
                else { return }
            }
        }
        imageItems.append(item)
  }

    /// Remove an image item from this image source.
    /// - Parameter id: The id of the `ImageItem`.
    public mutating func removeImageWith(id: UUID) {
        for (index, imageItem) in imageItems.enumerated() {
            if imageItem.id == id {
                imageItems.remove(at: index)
                break
            }
        }
    }
}


//MARK: - Type extensions -


//MARK: - Property Value
public extension PolisPropertyValue {
    enum CodingKeys: String, CodingKey {
        case valueKind = "value_kind"
        case value
        case unit
    }
}

//MARK: - Directions
public extension PolisDirection {
    enum CodingKeys: String, CodingKey {
        case roughDirection = "rough_direction"
        case exactDirection = "exact_direction"
    }
}

//MARK: - Identity
public extension PolisIdentity {
    enum CodingKeys: String, CodingKey {
        case id
        case externalReferences = "external_references"
        case lifecycleStatus    = "lifecycle_status"
        case lastUpdate         = "last_update"
        case name
        case abbreviation
        case automationLabel    = "automation_label"
        case shortDescription   = "short_description"
    }
}

//MARK: - Item Owner
public extension PolisItemOwner {
    enum CodingKeys: String, CodingKey {
        case ownershipType = "ownership_type"
        case abbreviation
        case adminContact  = "admin_contact"
    }
}

//MARK: - Item
public extension PolisItem {
    enum CodingKeys: String, CodingKey {
        case identity
        case modeOfOperation   = "mode_of_operation"
        case manufacturerID    = "manufacturer_id"
        case owners
        case imageSources      = "image_sources"
    }
}

//MARK: - Communication related types
extension PolisAdminContact.Communication {
    public enum CodingKeys: String, CodingKey {
        case twitterIDs           = "twitter_ids"
        case whatsappPhoneNumbers = "whatsapp_phone_numbers"
        case facebookIDs          = "facebook_ids"
        case instagramIDs         = "instagram_ids"
        case skypeIDs             = "skype_ids"
    }
}

extension PolisAdminContact: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case emailAddress            = "email_address"
        case phoneNumber             = "phone_number"
        case additionalCommunication = "additional_communication"
        case note
    }
}

//MARK: Images
extension PolisImageSource.ImageItem: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case lastUpdate               = "last_update"
        case originalSource           = "original_source"
        case shortDescription         = "short_description"
        case accessibilityDescription = "accessibility_description"
        case copyrightHolderType      = "copyright_holder_type"
        case copyrightHolderReference = "copyright_holder_reference"
        case copyrightHolderNote      = "copyright_holder_note"
    }
}

extension PolisImageSource: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case imageItems = "image_items"
    }
}
