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

/// A value type that uniquely identifies and describes the state of nearly every POLIS object,
/// while also capturing metadata used for synchronisation and cross‑system linking.
///
/// The concept of `PolisIdentity` originates from a similar type found in the `RTML` standard. The `RTML`
/// references proved incredibly useful for relating objects within a single `RTML` document and linking
/// `RTML` documents together.
///
/// Overview
/// - PolisIdentity is intended to be embedded in most POLIS model types to:
///   - Provide a stable, globally unique identifier (UUID v4) for the object.
///   - Record lifecycle and readiness information via PolisLifecycleStatus.
///   - Track modification timestamps to enable efficient sync across POLIS Providers.
///   - Carry human‑readable naming and descriptive metadata for display and search.
///   - Maintain external references (e.g., URLs, DOIs, or foreign IDs) to related objects in other systems.
///
/// Conformance
/// - Codable: Encodes/decodes to external representations (e.g., JSON).
/// - Identifiable: Exposes `id` for SwiftUI lists and identity semantics.
/// - Equatable: Supports equality checks, useful in diffing and state management.
///
/// Key Properties
/// - id: UUID v4 that uniquely identifies the object globally.
/// - externalReferences: Optional collection of external IDs or URLs linking to related systems.
/// - lastUpdateTime: Timestamp of the most recent modification, used primarily for sync.
/// - lifecycleStatus: Current readiness/status of the object. Client apps should treat `.deleted` as hidden.
/// - name/localName: Human‑readable names (English preferred for `name`; localised script in `localName`).
/// - abbreviation: Short token used commonly for search and display (e.g., device/project short codes).
/// - shortDescription: Optional description summarising the object.
/// - startTime/endTime: Temporal bounds of the object’s operational lifetime (e.g., first light / decommissioned).
/// - polisRegistrationTime: Timestamp when the object was initially registered in POLIS.
///
/// Usage Notes
/// - Prefer setting `name` to a unique, descriptive English label (e.g., "Alta-123_CCD").
/// - Use `externalReferences` for durable cross‑system links (e.g., "https://monet.org/instruments/12345").
/// - Update `lastUpdateTime` whenever any meaningful property changes to support incremental sync.
/// - Respect `lifecycleStatus` when presenting or filtering objects; hide `.deleted` from user interfaces.
///
/// Coding and Interoperability
/// - The encoded keys use snake_case to match POLIS data exchange conventions:
///   - external_references, last_update_time, lifecycle_status, local_name, short_description,
///     start_time, end_time, polis_registration_time.
/// - Date encoding/decoding should use a consistent strategy (e.g., ISO‑8601) at the encoder/decoder level.
///
/// Related Types
/// - PolisLifecycleStatus: Enumerates object readiness and lifecycle states used by POLIS.
public struct PolisIdentity: Codable, Identifiable, Equatable, Sendable, PolisObject {

    /// Globally unique identifier (UUID version 4) (ID in XML). The `id` is also needed for `Identifiable`
    /// protocol conformance.
    public let id: UUID

    /// Pointers to externally defined items (IDREF in XML). It is recommended that the references are URLs (e.g.
    /// https://monet.org/instruments/12345 or https://telescope.observer/instriment123456 ),
    /// or unique IDs (e.g. to publications, XML IDs. etc).
    public var externalReferences: [String]?

    /// Latest update timestamp. Used primarily for syncing.
    public var lastUpdateTime: Date

    /// The current status of the POLIS item (object) and its readiness to be used in different environments
    ///
    /// **Note:** Client apps should not show `.deleted` objects
    public var lifecycleStatus: PolisLifecycleStatus

    /// Human readable name of the object.
    ///
    /// It is recommended to assign a unique English name describing the
    /// object as close as possible (e.g. "Alta-123_CCD").
    public var name: String?

    /// Provides a human-readable name for the object in the local script and language.
    public var localName: String?

    /// Abbreviations are widely used for searching items, as well as device, instrument, and  project names.
    ///
    /// If present it is recommended to assign a unique abbreviation  (within the observatory or the observing site)
    /// in order to avoid potential confusions.
    public var abbreviation: String?

    /// Short optional object (object) description.
    ///
    /// It is recommended that English is used.
    public var shortDescription: String?

    /// The time when the POLIS objects began their existence, such as the first light of a telescope.
    public var startTime: Date?

    /// The time when the  POLIS object ended its existence, e.g. a device was decommissioned
    public var endTime: Date?

    /// The time of initial POLIS registration of the object
    public var polisRegistrationTime: Date?


    /// Designated initialiser.
    public init(id: UUID                              = UUID(),
                externalReferences: [String]?         = nil,
                lastUpdateTime: Date                  = Date.now,
                lifecycleStatus: PolisLifecycleStatus = .unknown,
                name: String?                         = nil,
                localName: String?                    = nil,
                abbreviation: String?                 = nil,
                shortDescription: String?             = nil,
                startTime: Date?                      = nil,
                endTime: Date?                        = nil,
                polisRegistrationTime: Date?          = nil) {
        self.id                    = id
        self.externalReferences    = externalReferences
        self.lastUpdateTime        = lastUpdateTime
        self.lifecycleStatus       = lifecycleStatus
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
        case lifecycleStatus       = "lifecycle_status"
        case name
        case localName             = "local_name"
        case abbreviation
        case shortDescription      = "short_description"
        case startTime             = "start_time"
        case endTime               = "end_time"
        case polisRegistrationTime = "polis_registration_time"
    }
}

