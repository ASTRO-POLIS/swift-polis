//===----------------------------------------------------------------------===//
//  PolisImageSource.swift
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

    /// A type defining the author's copyright claims on the image.
    public enum CopyrightHolderType: String, Codable {

        /// The POLIS contributor took the photo
        ///
        /// Client applications are free to use this media
       case polisContributor        = "polis_contributor"

        /// Most photos from Wikipedia etc.
        ///
        /// Client applications are free to use this media
        case creativeCommons         = "creative_commons"

        /// Open source image, like a photo of the observatory on the website of the facility/
        ///
        /// Client applications are free to use this media
      case openSource              = "open_source"

        /// In case the copyright holder gives an explicit permission to POLIS to use his or her image, the `copyrightHolderNote` property shall contain the
        ///  text of the message (e.g. email) that transfers the author's rights to POLIS to use the copyrighted material.
        ///
        /// Client applications are free to use this media
       case useWithOwnersPermission = "use_with_owners_permission"

        /// In case the copyright holder is still unknown or there is no explicit permission to use the media. Such image shall NOT be shown by clients or used in
        /// any other way!
        ///
        ///  In cases when publicly available images (e.g. from the observatory's website) images are not explicitly marked as open source or Creative Commons,
        ///  the team of POLIS maintainers shall ask the potential copyright owner to clarify the permission to use the media.
        case pendingInformation      = "pending_information"
    }

    /// `ImageItem` defines one of potentially multiple images of the same item.
    ///
    /// In many cases a single Item may have multiple related images. For instance, the same device having images with a different zoom factor or from different
    /// viewpoints, a panoramic image of an observatory in different seasons etc. These related images `ImageItem` are combined in an `PolisImageSource`.
    ///
    /// It is important to note that POLIS data may be viewed by kids. Therefore, all images shall be verified before made public. The `lastUpdate` attribute
    /// can help the curator of the data set to verify new entries. If the POLIS service provider is used by educational applications, it is recommended, that a local
    /// cache of verified images is maintained, or at least image hashes, that can guarantee, that the original image was unchanged.
    public struct ImageItem: Identifiable {
        public enum ImageItemError: Error {
            case copyrightHolderReferenceMissing
            case copyrightHolderReferenceOrNoteMissing
        }

        public let id: UUID
        public var lastUpdateDate: Date
        public let originalSource: URL

        public let shortDescription: String?
        public let accessibilityDescription: String?

        public let copyrightHolderType: CopyrightHolderType
        public let copyrightHolderReference: String?
        public let copyrightHolderNote: String?
        public let author: String?

        public let hash: String?

        public init(id: UUID                                 = UUID(),
                    lastUpdateDate: Date                     = Date.now,
                    originalSource: URL,
                    shortDescription: String?                = nil,
                    accessibilityDescription: String?        = nil,
                    copyrightHolderType: CopyrightHolderType = .pendingInformation,
                    copyrightHolderReference: String?        = nil,
                    copyrightHolderNote: String?             = nil,
                    author: String?                          = nil,
                    hash: String?                            = nil) throws {
            self.id                       = id
            self.lastUpdateDate           = lastUpdateDate
            self.originalSource           = originalSource
            self.shortDescription         = shortDescription
            self.accessibilityDescription = accessibilityDescription
            self.copyrightHolderType      = copyrightHolderType
            self.copyrightHolderReference = copyrightHolderReference
            self.copyrightHolderNote      = copyrightHolderNote
            self.author                   = author
            self.hash                     = hash

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
                if imageItem.lastUpdateDate < item.lastUpdateDate {
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

extension PolisImageSource.ImageItem: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case lastUpdateDate           = "last_update_date"
        case originalSource           = "original_source"
        case shortDescription         = "short_description"
        case accessibilityDescription = "accessibility_description"
        case copyrightHolderType      = "copyright_holder_type"
        case copyrightHolderReference = "copyright_holder_reference"
        case copyrightHolderNote      = "copyright_holder_note"
        case author
        case hash
    }
}

extension PolisImageSource: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case imageItems = "image_items"
    }
}
