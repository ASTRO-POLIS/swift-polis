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

//MARK: - Item Ownership -
public enum PolisOwnershipType: String, Codable {
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
    case `private`     // personal, amateur, ...
    case other
}

public struct PolisItemOwner: Codable {
    public let name: String?
    public let type: PolisOwnershipType
    public let url: URL?
    public let shortDescription: String?
}

/// The `Identifiable` compliance of `PolisItemIdentifiable` is guaranteed because of `attributes.id`
public protocol PolisItemIdentifiable: Codable {
    var attributes: PolisItemAttributes  { get set }
    var manufacturer: PolisManufacturer? { get set }
    var owners: [PolisItemOwner]?        { get set }
    var imageLinks: [URL]?               { get set }
}

public struct PolisItem: PolisItemIdentifiable {
    public var attributes: PolisItemAttributes
    public var manufacturer: PolisManufacturer?
    public var owners: [PolisItemOwner]?
    public var imageLinks: [URL]?
}

//MARK: - Type Extensions -

// This extension is needed for supporting a well formatted JSON API
public extension PolisItemOwner {
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case url
        case shortDescription = "short_description"
    }
}

public extension PolisItem {
    enum CodingKeys: String, CodingKey {
        case attributes
        case manufacturer
        case owners
        case imageLinks = "image_links"
    }
}
