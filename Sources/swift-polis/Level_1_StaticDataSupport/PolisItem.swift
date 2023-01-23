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


/// `PolisItem` uniquely identifies almost every POLIS object and defines the hierarchies and references between different objects
///
/// Any `[[PolisDevice]]`,  Observing Source (site, mobile platform, Collaboration, Network, ...), or Resource (e.g. a manufacturer of astronomy related
/// hardware) must have a `PolisItem` to uniquely identify the object and build the logical and spacial hierarchy between them.
public struct PolisItem: Codable, Identifiable {
    public var identity: PolisIdentity
    public var manufacturer: PolisManufacturer?
    public var owners: [PolisItemOwner]?


    public var imageSources: [PolisImageSource]?

    public var id: UUID { identity.id }
    public var parentID: UUID?
    public var subItemIDs: [UUID]

    public init(identity: PolisIdentity,
                manufacturer: PolisManufacturer?   = nil,
                owners: [PolisItemOwner]?          = nil,
                imageSources: [PolisImageSource]?  = nil,
                parentID: UUID?                    = nil,
                subItemIDs: [UUID]                 = [UUID]()) {
        self.identity     = identity
        self.manufacturer = manufacturer
        self.owners       = owners
        self.imageSources = imageSources
        self.parentID     = parentID
        self.subItemIDs   = subItemIDs
    }
}

//MARK: - Type Extensions -

public extension PolisItem {
    enum CodingKeys: String, CodingKey {
        case identity
        case manufacturer
        case owners
        case imageSources = "image_sources"
        case parentID     = "parent_id"
        case subItemIDs   = "sub_item_ids"
    }
}
