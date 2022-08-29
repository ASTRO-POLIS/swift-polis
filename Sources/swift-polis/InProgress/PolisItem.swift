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

//MARK: - Ownership -

public struct PolisItemOwner: Codable, Identifiable {

    public let identification: PolisIdentification
    public let name: String?
    public let type: PolisOwnershipType
    public let url: URL?
    public let shortDescription: String?

    public var id: UUID { identification.id }
}



//public struct PolisItem: Codable, Identifiable {
//    public var attributes: PolisIdentification
//    public var parentID: UUID?
//    public var manufacturer: PolisManufacturer?
//    public var owners: [PolisItemOwner]?
//    public var imageLinks: [URL]?
//
//    public var id: UUID { attributes.id }
//
//    public init(attributes: PolisIdentification, manufacturer: PolisManufacturer? = nil, owners: [PolisItemOwner]? = nil, imageLinks: [URL]? = nil) {
//        self.attributes   = attributes
//        self.manufacturer = manufacturer
//        self.owners       = owners
//        self.imageLinks   = imageLinks
//    }
//}
//
//MARK: - Type Extensions -




//public extension PolisItem {
//    enum CodingKeys: String, CodingKey {
//        case attributes
//        case parentID   = "parent_id"
//        case manufacturer
//        case owners
//        case imageLinks   = "image_links"
//    }
//}

public extension PolisItemOwner {
    enum CodingKeys: String, CodingKey {
        case identification
        case name
        case type
        case url
        case shortDescription = "short_description"
    }
}

