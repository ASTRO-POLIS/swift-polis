//===----------------------------------------------------------------------===//
//  PolisItem.swift
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


/// A core data model representing a POLIS Item.
///
/// `PolisItem` encapsulates the `identity`, ownership, hierarchical relationship,
/// automation metadata, and associated media linkage for a single entity in the
/// POLIS domain. It is designed to be serialisable (Codable) for persistence and
/// transport, and comparable (Equatable) for value-based equality checks.
///
/// Key characteristics:
/// - Uniquely identified by a `PolisIdentity`.
/// - Optionally associated with an owner (`PolisOwner`).
/// - Supports manual, tree-like hierarchies via an optional `parentID` and
///   a private set of child identifiers accessible through helper methods.
/// - Provides an optional `automationLabel` to integrate with automation systems
///   (e.g., ASCOM, INDI) and scheduling/discovery tools where labels are commonly
///   used as identifiers.
/// - Links to optional media resources through `mediaSourceID`.
///
/// Notes on hierarchy:
/// - Hierarchical relationships are not automatically managed. Clients are responsible
///   for constructing and maintaining parent/child links using the provided helper methods:
///   `childrenIDs()`, `addChildWith(id:)`, and `removeChildWith(id:)`.
///
/// Codable behavior:
/// - Custom coding keys map select properties to snake_case to ensure stable external
///   representations:
///   - `parentID`        -> `parent_id`
///   - `automationLabel` -> `automation_label`
///   - `mediaSourceID`   -> `media_source_id`
///
/// Equality:
/// - Conformance to `Equatable` enables straightforward comparisons, which is useful
///   when diffing collections or detecting changes.
public struct PolisItem: Codable, Equatable {

    /// Uniquely identifies the POLIS Item
    public var identity: PolisIdentity

    /// Who are the owners of the POLIS Item?
    public var owner: PolisOwner?

    /// Defines a hierarchy of POLIS Items
    public var parentID: UUID?

    /// In open source automation systems (ASCOM, INDI) and most telescope control software systems Automation
    /// Labels are used as identifiers for scripts, schedulers, and device discovery. It is recommended to be unique
    /// within the domain.
    public var automationLabel: String?

    /// Defines a set of media sources (images, audio etc) attached to the POLIS Item
    public var mediaSourceID: UUID?

    /// Designated initialiser
    public init(identity: PolisIdentity,
                owner: PolisOwner?       = nil,
                parentID: UUID?          = nil,
                automationLabel: String? = nil,
                mediaSourceID: UUID?     = nil) {
        self.identity      = identity
        self.owner         = owner
        self.parentID      = parentID
        self.mediaSourceID = mediaSourceID
    }

    // The following three methods help the creation of a tree-based hierarchy of POLIS Items.
    // It is client's responsibility to create the hierarchy manually
    public          func childrenIDs() -> Set<UUID> { _childrenIDs }
    public mutating func addChildWith(id: UUID)     { _childrenIDs.insert(id) }
    public mutating func removeChildWith(id: UUID)  { _childrenIDs.remove(id) }

    //MARK: - Private properties
    private var _childrenIDs = Set<UUID>()

}

public extension PolisItem {
    enum CodingKeys: String, CodingKey {
        case identity
        case owner
        case parentID        = "parent_id"
        case automationLabel = "automation_label"
        case mediaSourceID   = "media_source_id"
    }
}

