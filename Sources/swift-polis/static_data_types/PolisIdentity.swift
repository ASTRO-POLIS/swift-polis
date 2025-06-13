//===----------------------------------------------------------------------===//
//  PolisIdentity.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2025 Tuparev Technologies and the ASTRO-POLIS project
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

/// `PolisIdentity` uniquely identifies and defines the status of almost every POLIS object and defines
/// external relationships to other objects of any type
///
/// The idea of `PolisIdentity` comes from the analogous type that could be found in the `RTML` standard.
/// The `RTML` references turned out to be extremely useful for relating objects within one `RTML` document
/// and linking `RTML` documents to each other.
///
/// `PolisIdentity` is an essential a part of nearly every POLIS type. Identities are needed to uniquely
/// identify and describe each item (object) and to establish parent-child relationships between objects, as well
/// as provide enough information for the syncing of POLIS Providers by defining last modification timestamps
/// and versions, supported by the Provider.
public struct PolisIdentity: Codable, Identifiable, Equatable {

    /// Globally unique identifier (UUID version 4) (ID in XML). The `id` is also needed for `Identifiable`
    /// protocol conformance.
    public let id: UUID

    /// Pointers to externally defined items (IDREF in XML). It is recommended that the references are URLs (e.g.
    /// https://monet.org/instruments/12345 or https://telescope.observer/instriment123456 )
    public var externalReferences: [String]?

    /// Latest update timestamp. Used primarily for syncing.
    public var lastUpdateTime: Date

    /// Human readable name of the object. It is recommended to assign a unique English name describing the
    /// object as close as possible (e.g. "Alta-123_CCD").
    public var name: String?

    /// Human readable name of the object in a local script and language.
    public var localName: String?

    /// Abbreviations are widely used for searching items, as well as device, instrument, and  project names.
    /// If present it is recommended to assign a unique abbreviation  (within the observatory or the observing site)
    /// in order to avoid potential confusions.
    public var abbreviation: String?

    /// Short optional object (object) description.
    public var shortDescription: String?

    /// The time when the  POLIS objects began its existence, e.g. first light of a telescope
    public var startTime: Date?

    /// The time when the  POLIS object ended its existence, e.g. a device was decommissioned
    public var endTime: Date?

    /// The time of initial POLIS registration of the object
    public var polisRegistrationTime: Date?


    /// Designated initialiser.
    ///
    /// Only the `name` parameter is required. All other parameters have reasonable default values.
    public init(id: UUID                      = UUID(),
                externalReferences: [String]? = nil,
                lastUpdateTime: Date          = Date.now,
                name: String?                 = nil,
                localName: String?            = nil,
                abbreviation: String?         = nil,
                shortDescription: String?     = nil,
                startTime: Date?              = nil,
                endTime: Date?                = nil,
                polisRegistrationTime: Date?  = nil) {
        self.id                    = id
        self.externalReferences    = externalReferences
        self.lastUpdateTime        = lastUpdateTime
        self.name                  = name
        self.localName             = localName
        self.abbreviation          = abbreviation
        self.shortDescription      = shortDescription
        self.startTime             = startTime
        self.endTime               = endTime
        self.polisRegistrationTime = polisRegistrationTime
   }
}

extension PolisIdentity {
    enum CodingKeys: String, CodingKey {
        case id
        case externalReferences    = "external_references"
        case lastUpdateTime        = "last_update_time"
        case name
        case localName             = "local_name"
        case abbreviation
        case shortDescription      = "short_description"
        case startTime             = "start_time"
        case endTime               = "end_time"
        case polisRegistrationTime = "polis_registration_time"
    }
}

