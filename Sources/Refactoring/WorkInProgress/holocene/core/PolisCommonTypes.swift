//===----------------------------------------------------------------------===//
//  PolisCommonTypes.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2024 Tuparev Technologies and the ASTRO-POLIS project
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

//MARK: - POLIS Identity related types -

//MARK: - POLIS Item -

/// `PolisItem` uniquely identifies almost every POLIS object and defines the hierarchies and references between different objects
///
/// Any `[[PolisDevice]]`,  Observing Source (e.g. various observing facilities) or Resource (e.g. a manufacturer of astronomy related
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

    public var imageSourceID: UUID?

    public var id: UUID { identity.id }

    public init(identity: PolisIdentity,
                modeOfOperation: ModeOfOperation  = .unknown,
                manufacturerID: UUID?             = nil,
                owners: [PolisItemOwner]?         = nil,
                imageSourceID: UUID?              = nil ) {
        self.identity          = identity
        self.modeOfOperation   = modeOfOperation
        self.manufacturerID    = manufacturerID
        self.owners            = owners
        self.imageSourceID     = imageSourceID
    }
}

//MARK: - Item Ownership -

/// A type that defines the owner of an observing facility or a device.
///
/// Files containing an owner's information are in general stored within the static file hierarchy of the observing facilities (or equivalent).
/// For performance reasons, it is recommended (but not required by the standard) that the service provider supports a directory of owners
/// (as this framework does). Such a cache of owners would of course have performance and data maintenance implications as well.
public struct PolisItemOwner: Codable {

//    /// A type that describes the different kinds of owners of a POLIS item.
//    ///
//    /// `OwnershipType` is used to identify the ownership type of POLIS items (or devices) such as observing facilities, telescopes,
//    /// CCD cameras, weather stations, etc. Different cases should be self-explanatory. The `private` type should be utilised by
//    /// amateurs and hobbyists.
//    public enum OwnershipType: String, Codable {
//        case university
//        case research
//        case commercial
//        case school
//        case network
//        case government
//        case ngo
//        case club
//        case consortium
//        case cooperative
//        case collaboration
//        case `private`
//        case other
//    }

    public let ownershipType: OwnershipType
    public var adminContact: PolisAdminContact?
    public let abbreviation: String?   // e.g. MIT. MONET, BAO, ...

    public init(ownershipType: OwnershipType, abbreviation: String?, adminContact: PolisAdminContact? = nil) {
        self.ownershipType = ownershipType
        self.abbreviation  = abbreviation
        self.adminContact  = adminContact
    }
}


//MARK: - Manufacturer information -

///// A type that encapsulates basic information about the manufacturer.
/////
///// Every provider is free to implement it's own handling of lists of manufacturers, but we highly recommend that all manufacturer information is managed in a single,
///// possibly manually maintained, cache. This will help client applications to display unique information and avoid "almost the same" information being found multiple
///// times. It is preferable and better for the community as a whole if manufacturers maintain their product catalogues themselves.
/////
///// It is important that POLIS Providers guarantee the uniqueness of manufacturers and their products. This is not required by the standard, but it is strongly
///// recommended and makes the experience better for everyone.
//public struct PolisManufacturer: Codable, Identifiable {
//    /// Makes `PolisManufacturer` uniquely identifiable.
//    public var identity: PolisIdentity
//
//    public var id: UUID { identity.id }
//
//    /// The fully qualified URL of the service provider, e.g. https://www.celestron.com
//    public var url: URL?
//
//    /// The point-of-contact for the manufacturer.
//    public var adminContact: PolisAdminContact?
//
//    public init(identity: PolisIdentity, url: URL? = nil, adminContact: PolisAdminContact? = nil) {
//        self.identity     = identity
//        self.url          = url
//        self.adminContact = adminContact
//    }
//}



//MARK: - Communication related types -

// Many POLIS types have reference to contact people (owners of observing facilities, admins, project managers). Later we need to add
// Institutions as well and handle the messiness of addresses, countries, languages, phone numbers and other
// developer's nightmares. We think it's perhaps the best in the future to rely on an external implementation for address
// management.
// On the other hand the implementation of contact channels (in order to allow communication with POLIS providers site admins)
// is a simple enough task and therefore the current implementation of POLIS includes contact-only related types.


/// `PolisAdminContact` defines a simple way to contact a provider admin, an observing facility owner, or an observatory
/// admin.
///
/// It is important to be able to contact the admin of a POLIS service provider or the admin or the owner of an
/// observing facility, but one should not forget that all POLIS data is publicly available and therefore should not
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
//    public struct Communication: Codable {
//
//        /// Twitter user id, e.g. @AstroPolis. "@" is expected to be part of the id.
//        public var twitterIDs: [String]?
//
//        /// Phone number used by WhatsApp. The phone number should include the country code, starting with "+", and contain no
//        /// spaces, brackets, or other formatting characters. Currently no validation is provided.
//        public var whatsappPhoneNumbers: [String]?
//
//        /// The Facebook user id is only the part of the URL after "www.facebook.com/".
//        public var facebookIDs: [String]?
//
//        /// Instagram user id, e.g. @AstroPolis. "@" is expected to be part of the id.
//        public var instagramIDs: [String]?
//
//        /// Skype user id
//        public var skypeIDs: [String]?
//
//        public init(twitterIDs: [String]?     = nil,
//             whatsappPhoneNumbers: [String]?  = nil,
//             facebookIDs: [String]?           = nil,
//             instagramIDs: [String]?          = nil,
//             skypeIDs: [String]?              = nil) {
//            self.twitterIDs           = twitterIDs
//            self.whatsappPhoneNumbers = whatsappPhoneNumbers
//            self.facebookIDs          = facebookIDs
//            self.instagramIDs         = instagramIDs
//            self.skypeIDs             = skypeIDs
//        }
//    }

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
/// A source for images related to a single item, such as an observing facility, a satellite, a telescope, or a camera.
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
        public let author: String?

        public init(id: UUID                                 = UUID(),
                    lastUpdate: Date                         = Date.now,
                    originalSource: URL,
                    shortDescription: String?                = nil,
                    accessibilityDescription: String?        = nil,
                    copyrightHolderType: CopyrightHolderType = .pendingInformation,
                    copyrightHolderReference: String?        = nil,
                    copyrightHolderNote: String?             = nil,
                    author: String?                          = nil) throws {
            self.id                       = id
            self.lastUpdate               = lastUpdate
            self.originalSource           = originalSource
            self.shortDescription         = shortDescription
            self.accessibilityDescription = accessibilityDescription
            self.copyrightHolderType      = copyrightHolderType
            self.copyrightHolderReference = copyrightHolderReference
            self.copyrightHolderNote      = copyrightHolderNote
            self.author                   = author

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


public enum PolisElectromagneticSpectrumCoverage: String, Codable {
    case gammaRay
    case xRay
    case ultraviolet
    case optical
    case infrared
    case subMillimeter
    case radio
    case other
    case unknown
}

//MARK: - Type extensions -

//MARK: - Identity
//MARK: - Item Owner
public extension PolisItemOwner {
    enum CodingKeys: String, CodingKey {
        case ownershipType = "ownership_type"
        case abbreviation
        case adminContact  = "admin_contact"
    }
}


////MARK: - Manufacturer information
//extension PolisManufacturer {
//    enum CodingKeys: String, CodingKey {
//        case identity
//        case url
//        case adminContact = "admin_contact"
//    }
//}

//MARK: - Item
public extension PolisItem {
    enum CodingKeys: String, CodingKey {
        case identity
        case modeOfOperation   = "mode_of_operation"
        case manufacturerID    = "manufacturer_id"
        case owners
        case imageSourceID     = "image_source_id"
    }
}

////MARK: - Communication related types
//extension PolisAdminContact.Communication {
//    public enum CodingKeys: String, CodingKey {
//        case twitterIDs           = "twitter_ids"
//        case whatsappPhoneNumbers = "whatsapp_phone_numbers"
//        case facebookIDs          = "facebook_ids"
//        case instagramIDs         = "instagram_ids"
//        case skypeIDs             = "skype_ids"
//    }
//}

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
        case author
    }
}

extension PolisImageSource: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case imageItems = "image_items"
    }
}

public extension PolisElectromagneticSpectrumCoverage {
    enum CodingKeys: String, CodingKey {
        case gammaRay      = "gamma_ray"
        case xRay          = "x_ray"
        case ultraviolet
        case optical
        case infrared
        case subMillimeter = "sub_millimeter"
        case radio
        case other
        case unknown
    }
}

