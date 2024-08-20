//===----------------------------------------------------------------------===//
//  PolisIdentity.swift
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

/// `PolisIdentity` uniquely identifies and defines the status of almost every POLIS item and defines external relationships to other items
/// (or POLIS objects of any type).
///
/// The idea of `PolisIdentity` comes from the analogous type that could be found in the `RTML` standard. The `RTML` references turned
/// out to be extremely useful for relating items within one `RTML` document and linking `RTML` documents to each other.
///
/// `PolisIdentity` is an essential a part of nearly every POLIS type. Identities are needed to uniquely identify and describe each item (object)
/// and to establish parent-child relationships between them, as well as provide enough information for the syncing of POLIS Providers by defining
/// last modification timestamps and versions (if applicable).
public struct PolisIdentity: Codable, Identifiable {

    /// Globally unique identifier (UUID version 4) (ID in XML). The `id` is needed for `Identifiable` protocol
    /// conformance.
    public let id: UUID

    /// Pointers to externally defined items (IDREF in XML). It is recommended that the references are URLs (e.g.
    /// https://monet.org/instruments/12345 or https://telescope.observer/instriment123456 )
    public var externalReferences: [String]?

    /// Latest update time. Used primarily for syncing.
    public var lastUpdate: Date

    /// Human readable name of the item (object). It is recommended to assign a unique name to avoid potential confusions.
    public var name: String

    /// Human readable name of the item in a local script.
    public var localName: String?

    /// Abbreviations are widely used for searching items, as well as device, instrument, and  project names. If present it is
    /// recommended to assign a unique label (within the observatory or the observing site) to avoid potential confusions.
    public var abbreviation: String?

    //TODO: Move to Item
    /// The purpose of the optional `automationLabel` is to act as a unique target for scripts and other software
    /// packages. As an example, the observatory control software could search for an instrument with a given label and
    /// set its status or issue commands etc. This could be used to sync with ASCOM or INDI based systems.
    public var automationLabel: String?

    /// Short optional item (object) description.
    public var shortDescription: String?

    /// The date that the corresponding POLIS item started its existence, e.g. first light of a telescope
    public var startDate: Date?

    /// The date that the corresponding POLIS item ended its existence, e.g. a device was decommissioned
    public var endDate: Date?

    /// The date of initial POLIS registration of the item
    public var polisRegistrationDate: Date?


    /// Designated initialiser.
    ///
    /// Only the `name` parameter is required. All other parameters have reasonable default values.
    public init(id: UUID                      = UUID(),
                externalReferences: [String]? = nil,
                lastUpdate: Date              = Date(),
                name: String,
                localName: String?            = nil,
                abbreviation: String?         = nil,
                automationLabel: String?      = nil,
                shortDescription: String?     = nil,
                startDate: Date?              = nil,
                endDate: Date?                = nil,
                polisRegistrationDate: Date?  = nil) {
        self.id                    = id
        self.externalReferences    = externalReferences
        self.lastUpdate            = lastUpdate
        self.name                  = name
        self.localName             = localName
        self.abbreviation          = abbreviation
        self.automationLabel       = automationLabel
        self.shortDescription      = shortDescription
        self.startDate             = startDate
        self.endDate               = endDate
        self.polisRegistrationDate = polisRegistrationDate
   }
}

public extension PolisIdentity {
    enum CodingKeys: String, CodingKey {
        case id
        case externalReferences    = "external_references"
        case lastUpdate            = "last_update"
        case name
        case localName             = "local_name"
        case abbreviation
        case automationLabel       = "automation_label"
        case shortDescription      = "short_description"
        case startDate             = "start_date"
        case endDate               = "end_date"
        case polisRegistrationDate = "polis_registration_date"
    }
}

