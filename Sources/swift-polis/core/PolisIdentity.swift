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

    /// The current status of the POLIS item (object) and its readiness to be used in different environments.
    ///
    /// Each POLIS type (Provider, Observing Facility, Device, etc.) should include `LifecycleStatus` (as part of
    /// ``PolisIdentity``).
    ///
    /// `LifecycleStatus` will also determine the syncing policy as well as the visibility of the POLIS items within client
    /// implementations. Implementations should adopt the following behaviours:
    /// - `inactive`  - do not sync, but continue monitoring
    /// - `active`    - must be synced and monitored
    /// - `deleted`   - sync the `PolisItemAttributes` only to prevent secondary propagation of the item and to lock the
    /// UUID of the item
    ///  - `historic` - do not sync, but continue monitoring
    /// - `delete`    - delete the item
    /// - `suspended` - sync the `PolisItemAttributes`, but do not use the service provider or the observing facility. Suspended
    /// is used to mark that the item does not follow the POLIS standard, or violates community rules. Normally entities
    /// will be warned first, and if they continue to break standards and rules, they will be deleted.
    /// - `unknown`   - do not sync, but continue monitoring
    public enum LifecycleStatus: String, Codable {

        /// `inactive` indicates new, being edited, or in process of being upgraded by the provider(s).
        case inactive

        /// `active` indicates a production provider that is publicly accessible.
        case active

        /// Item still exists and has historical value but is not operational.
        case historic

        /// `deleted` is needed to prevent reappearance of disabled providers or facilities.
        case deleted

        /// After marking an item for deletion, wait for a year (check `lastUpdate`) and start marking the item as
        /// `delete`. After 18 months, remove the deleted items. It is assumed that 1.5 years is enough for all providers
        /// to mark the corresponding item as deleted.
        case delete

        /// `suspended` indicates providers violating the standard (temporary or permanently).
        case suspended

        /// `unknown` indicates a provider with unknown status, and is mostly used when the observing facility or instrument has
        /// unknown status.
        case unknown
    }

    /// Globally unique identifier (UUID version 4) (ID in XML). The `id` is needed for `Identifiable` protocol
    /// conformance.
    public let id: UUID

    /// Pointers to externally defined items (IDREF in XML). It is recommended that the references are URLs (e.g.
    /// https://monet.org/instruments/12345 or https://telescope.observer/instriment123456 )
    public var externalReferences: [String]?

    /// Determines the current status of the POLIS item (object).
    public var lifecycleStatus: LifecycleStatus

    /// Latest update time. Used primarily for syncing.
    public var lastUpdate: Date

    /// Human readable name of the item (object). It is recommended to assign a unique name to avoid potential confusions.
    public var name: String

    /// Human readable name of the item in a local script.
    public var localName: String?

    /// Abbreviations are widely used for searching items, as well as device, instrument, and  project names. If present it is
    /// recommended to assign a unique label (within the observatory or the observing site) to avoid potential confusions.
    public var abbreviation: String?

    /// The purpose of the optional `automationLabel` is to act as a unique target for scripts and other software
    /// packages. As an example, the observatory control software could search for an instrument with a given label and
    /// set its status or issue commands etc. This could be used to sync with ASCOM or INDI based systems.
    public var automationLabel: String?

    /// Short optional item (object) description.
    public var shortDescription: String?

    /// Designated initialiser.
    ///
    /// Only the `name` parameter is required. All other parameters have reasonable default values.
    public init(id: UUID                         = UUID(),
                externalReferences: [String]?    = nil,
                lifecycleStatus: LifecycleStatus = LifecycleStatus.unknown,
                lastUpdate: Date                 = Date(),
                name: String,
                localName: String?               = nil,
                abbreviation: String?            = nil,
                automationLabel: String?         = nil,
                shortDescription: String?        = nil) {
        self.id                 = id
        self.externalReferences = externalReferences
        self.lifecycleStatus    = lifecycleStatus
        self.lastUpdate         = lastUpdate
        self.name               = name
        self.localName          = localName
        self.abbreviation       = abbreviation
        self.automationLabel    = automationLabel
        self.shortDescription   = shortDescription
    }
}

public extension PolisIdentity {
    enum CodingKeys: String, CodingKey {
        case id
        case externalReferences = "external_references"
        case lifecycleStatus    = "lifecycle_status"
        case lastUpdate         = "last_update"
        case name
        case localName          = "local_name"
        case abbreviation
        case automationLabel    = "automation_label"
        case shortDescription   = "short_description"
    }
}

