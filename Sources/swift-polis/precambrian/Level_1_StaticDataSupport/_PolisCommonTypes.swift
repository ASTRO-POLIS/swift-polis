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



//MARK: - ContactType
extension PolisAdminContact.Communication: Codable, CustomStringConvertible {

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

