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
