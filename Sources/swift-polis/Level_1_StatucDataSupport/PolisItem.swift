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

//MARK: - POLIS Lifecycle -

/// `PolisLifecycleStatus` defines the current status of the POLIS items (readiness to be used in different
/// environments)
///
/// Each POLIS type (Provider, Observing Site, Observatory, etc.) should include `PolisLifecycleStatus` (as part of
/// ``PolisItemAttributes``).
///
/// `PolisLifecycleStatus` will determine the syncing policy, as well as visibility of the POLIS items within
/// client implementations. Implementations should adopt following behaviours:
/// - `inactive`  - do not sync, but continue monitoring
/// - `active`    - must be synced and monitored
/// - `deleted`   - sync the `PolisItemAttributes` only to prevent secondary propagation of the record and to lock the
/// UUID of the item
/// - `suspended` - sync the `PolisItemAttributes`, but do not use the service provider or the observing site. Suspended
/// is used to mark that the item does not follow the POLIS standard, or violates community rules. Normally entities first
/// will be worried, and if they continue to not follow standards and rules, they will be deleted.
/// - `unknown`   - do not sync, but continue monitoring
public enum PolisLifecycleStatus: String, Codable {

    /// `inactive` indicates new, being edited, or in process of being upgraded providers.
    case inactive

    /// `active` indicates a production provider that is publicly accessible.
    case active

    /// `deleted` is needed to prevent reappearance of disabled providers or sites.
    case deleted

    /// `suspended` marks providers violating the standard (temporary or permanently).
    case suspended

    /// `unknown` marks a provider with unknown status, and is mostly used when observing site or instrument has
    /// unknown status.
    case unknown
}


/// `PolisItemAttributes` uniquely identifies and defines the status of almost every POLIS item and defines external
/// relationships to other items (or POLIS objects).
///
/// The idea of POLIS Attributes comes from analogous type that could be found in the `RTML` standard. The
/// RTML attributes  turned out to be extremely useful for relating items within one RTML document and linking RTML
/// documents to each other.
///
/// `PolisItemAttributes` are an essential part of (almost) every POLIS type. They are needed to uniquely identify and
/// describe each item (object) and establish parent-child relationships between them, as well as provide enough
/// informationIn for the syncing of polis providers.
///
/// Parent - child relationship should be defined by nesting data structures.
///
/// If XML encoding / decoding is used, it is recommended to implement the `PolisItemAttributes` as attributes of the
/// corresponding type (Element).
public struct PolisItemAttributes: Codable, Identifiable {

    /// Globally unique identifier (UUID version 4) (ID in XML). The `id` is needed for `Identifiable` protocol
    /// conformance.
    public let id: UUID

    /// Pointers to externally defined item (IDREF in XML). It is recommended that the references are URIs (e.g.
    /// https://monet.org/instruments/12345 or telescope.observer://instriment123456)
    public var references: [String]?

    /// Determines the current status of the POLIS item (object).
    public var status: PolisLifecycleStatus

    /// Latest update time. Used primarily for syncing.
    public var lastUpdate: Date

    /// Human readable name of the item (object). It is recommended to be unique to avoid potential confusions.
    public var name: String

    /// Human readable automationLabel of the item (object). If present it is recommended to be unique to avoid
    /// potential confusions.
    public var abbreviation: String?

    /// The purpose of the optional `automationLabel` is to act as a unique target for scripts and other software
    /// packages. As an example, the observatory control software could search for an instrument with such label and
    /// set its status or issue commands etc.
    public var automationLabel: String? // For script etc. support (internal to the site use...)

    /// Short optional item (object) description. In XML schema should be max 256 characters for RTML interoperability.
    public var shortDescription: String?

    /// Designated initialiser.
    ///
    /// Only the `name` parameter is required. All other parameters have reasonable default values.
    public init(id: UUID =  UUID(),
                references: [String]?        = nil,
                status: PolisLifecycleStatus = PolisLifecycleStatus.unknown,
                lastUpdate: Date             = Date(),
                name: String,
                abbreviation: String?        = nil,
                automationLabel: String?     = nil,
                shortDescription: String?    = nil) {
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


public struct PolisItemOwner: Codable {
    public let name: String?
    public let type: PolisOwnershipType
    public let url: URL?
    public let shortDescription: String?
}


public struct PolisItem: Codable, Identifiable {
    public var attributes: PolisItemAttributes
    public var parentItem: UUID?
    public var manufacturer: PolisManufacturer?
    public var owners: [PolisItemOwner]?
    public var imageLinks: [URL]?

    public var id: UUID { attributes.id }

    public init(attributes: PolisItemAttributes, manufacturer: PolisManufacturer? = nil, owners: [PolisItemOwner]? = nil, imageLinks: [URL]? = nil) {
        self.attributes   = attributes
        self.manufacturer = manufacturer
        self.owners       = owners
        self.imageLinks   = imageLinks
    }
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


public extension PolisItemAttributes {
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


public extension PolisItem {
    enum CodingKeys: String, CodingKey {
        case attributes
        case parentItem   = "parent_item"
        case manufacturer
        case owners
        case imageLinks   = "image_links"
    }
}
