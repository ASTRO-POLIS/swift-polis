//===----------------------------------------------------------------------===//
//  PolisMediaSource.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2026 Tuparev Technologies and the ASTRO-POLIS project
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

/// A source for images related to a single item, such as an observing facility, a satellite, a telescope, or a camera.
///
/// A POLIS client can use a media source (image, audio, movie, PDF Document, etc) in many different ways—as a thumbnail, a full image, background audio,
/// a banner, etc. A `PolisIMediaSource`instance  could have multiple `MediaItem`s that fulfil the needs of the client application.
///
/// Each media item from the set defines its index within the set (used for sorting), and image attributes (source URL, description and accessibility description,
/// as well as information about the copyright holder and copyright type).
///
/// **Note:** Image, Document, and other media item's exact type should be determined by the filename extension, e.g. PDF, tiff, jpg, etc, and its `MediaType`.
///
/// **Important note:** POLIS providers should only use images that are either open source or have explicitly requested and received rights of use from the
/// copyright holder!
public struct PolisMediaSource: Identifiable, Equatable, Sendable, PolisObject {

    public enum MediaType: String, Codable, Equatable, Sendable {
        case image
        case movie
        case audio
        case document
        case unknown
    }

    /// A type defining the author's copyright claims on the image.
    public enum CopyrightHolderType: String, Codable, CaseIterable, Sendable {

        /// The POLIS contributor took the photo, made the recording, or the movie, etc.
       case polisContributor        = "polis_contributor"

        /// Most photos from Wikipedia etc.
        case creativeCommons        = "creative_commons"

        /// Open source image, like a photo of the observatory on the website of the facility/
      case openSource               = "open_source"

        /// In case the copyright holder gives an explicit permission to POLIS to use his or her image, the `copyrightHolderNote` property shall contain the
        ///  text of the message (e.g. email) that transfers the author's rights to POLIS to use the copyrighted material.
       case useWithOwnersPermission = "use_with_owners_permission"

        /// In case the copyright holder is still unknown or there is no explicit permission to use the media. Such image shall NOT be shown by clients or used in
        /// any other way!
        ///
        ///  In cases when publicly available images (e.g. from the observatory's website) images are not explicitly marked as open source or Creative Commons,
        ///  the team of POLIS maintainers shall ask the potential copyright owner to clarify the permission to use the media.
        case pendingInformation     = "pending_information"
    }

    /// `MediaItem` defines one of potentially multiple media instanced related to a Polis object (e.g. Site, Observatory, etc).
    ///
    /// In many cases a single Item may have multiple related representations. For instance, the same device having images with a different zoom factor or from
    /// different viewpoints, a panoramic image of an observatory in different seasons etc. These related `ImageItem`'s are combined in an
    /// `PolisMediaSource`.
    ///
    /// It is important to note that POLIS data may be viewed by kids. Therefore, all media items shall be verified before made public. The `lastUpdate` attribute
    /// can help the curator of the data set to verify new entries. If the POLIS service provider is used by educational applications, it is recommended, that a local
    /// cache of verified images is maintained..
    public struct MediaItem: Identifiable, Equatable, Sendable {
        public enum MediaItemError: Error {
            case copyrightHolderReferenceMissing
            case copyrightHolderReferenceOrNoteMissing
            case copyrightPendingInformationMissing
        }

        public let id: UUID
        public var lastUpdateTime: Date
        
        public let mediaType: MediaType
        public var mediaFormat: String? // e.g. 2x2, header, full_image, 10k, ...
        public let originalSource: URL

        public let shortDescription:[String: String]?
        public let accessibilityDescription: [String: String]?

        public let copyrightHolderType: CopyrightHolderType
        public let copyrightHolderReference: String?
        public let copyrightHolderNote: String?
        public let author: String?

        public let hash: String? //TODO: Document for URLs

        public init(id: UUID                                   = UUID(),
                    lastUpdateTime: Date                       = Date.now,
                    mediaType: MediaType                       = .image,
                    mediaFormat: String?                       = nil,
                    originalSource: URL,
                    shortDescription: [String: String]?        = nil,
                    accessibilityDescription:[String: String]? = nil,
                    copyrightHolderType: CopyrightHolderType = .pendingInformation,
                    copyrightHolderReference: String?          = nil,
                    copyrightHolderNote: String?               = nil,
                    author: String?                            = nil,
                    hash: String?                              = nil) throws {
            self.id                       = id
            self.lastUpdateTime           = lastUpdateTime
            self.mediaType                = mediaType
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
                    if self.copyrightHolderReference == nil                                        { throw MediaItemError.copyrightHolderReferenceMissing }
                case .useWithOwnersPermission:
                    if (self.copyrightHolderReference == nil) || (self.copyrightHolderNote == nil) { throw MediaItemError.copyrightHolderReferenceOrNoteMissing }
                case .pendingInformation:
                    if self.copyrightHolderNote == nil                                             { throw MediaItemError.copyrightPendingInformationMissing }
            }
        }
    }

    public var id: UUID
    public var lastUpdateTime: Date
    public var facilityID: UUID

    /// The metadata of the images associated with this `PolisImageSource`.
    public var mediaItems = [MediaItem]()


    public init(id: UUID                 = UUID(),
                lastUpdateTime: Date     = Date.now,
                facilityID: UUID,
                mediaItems: [MediaItem]? = []) {
        self.id             = id
        self.lastUpdateTime = lastUpdateTime
        self.facilityID     = facilityID
        self.mediaItems     = mediaItems!
    }

    /// Add an image to this image source.
    /// - Parameter item: The `ImageItem` associated with the image to be added.
    public mutating func addItem(_ item: MediaItem) {
        for (index, mediaItem) in mediaItems.enumerated() {
            if mediaItem.id == item.id {
                if mediaItem.lastUpdateTime < item.lastUpdateTime {
                    mediaItems.remove(at: index)
                    mediaItems.append(item)
                    return
                }
                else { return }
            }
        }
        mediaItems.append(item)
    }

    /// Remove an image item from this image source.
    /// - Parameter id: The id of the `ImageItem`.
    public mutating func removeItemWith(id: UUID) {
        for (index, mediaItem) in mediaItems.enumerated() {
            if mediaItem.id == id {
                mediaItems.remove(at: index)
                break
            }
        }
    }

    public func polisDataType() -> PolisDataType { .mediaSource }
}

extension PolisMediaSource.MediaItem: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case lastUpdateTime           = "last_update_time"
        case mediaType                = "media_type"
        case mediaFormat              = "media_format"
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

extension PolisMediaSource: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case lastUpdateTime = "last_update_time"
        case facilityID     = "facility_id"
        case mediaItems     = "media_items"
    }
}
