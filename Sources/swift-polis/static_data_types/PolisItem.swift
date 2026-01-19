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
 
/// A model representing a single POLIS domain item.
///
/// PolisItem is a value type that encapsulates identity, ownership, operational state,
/// hierarchical placement, automation metadata, and media linkage for an entity within
/// the POLIS ecosystem. It is Codable for persistence/transport and Equatable for
/// value-based comparison.
///
/// Responsibilities and usage:
/// - Identification:
///   - `identity`: A unique `PolisIdentity` that defines the item within the system.
/// - Operational state:
///   - `modeOfOperation`: Describes how the item is intended to operate. For static artifacts
///     (e.g., monuments), prefer `.notApplicable` over `.unknown`.
/// - Ownership:
///   - `owner`: Optional owner information describing who owns or manages the item.
/// - Hierarchy:
///   - `parentID`: Optional UUID linking this item to a parent item, enabling manual tree structures.
///   - `childrenIDs()`: Returns the set of child item identifiers managed internally.
///   - `addChildWith(id:)`, `removeChildWith(id:)`: Helpers to maintain the manual hierarchy.
///     Note: Hierarchical relationships are not automatically enforced—clients must
///     maintain both parent and child references consistently.
/// - Automation metadata:
///   - `automationLabel`: Optional label commonly used in open automation systems (e.g., ASCOM, INDI)
///     and scheduling/discovery tools; recommended to be unique within its domain.
/// - Media association:
///   - `mediaSourceID`: Optional UUID linking the item to external media (e.g., images, audio).
///
/// Codable and external representation:
/// - Custom coding keys map select properties to snake_case to ensure stable external
///   representations:
///   - `parentID`        -> `parent_id`
///   - `automationLabel` -> `automation_label`
///   - `mediaSourceID`   -> `media_source_id`
///
/// Equality:
/// - `Equatable` conformance enables straightforward diffing and change detection.
///
/// Thread-safety:
/// - As a struct with internal mutable state (children set), treat instances as
///   non-thread-safe if mutated concurrently.
public struct PolisItem: Codable, Equatable, Sendable, PolisObject {

    /// Uniquely identifies the POLIS Item
    public var identity: PolisIdentity

    /// Defines the Mode of Operation of the POLIS Item
    ///
    /// For artifacts like monuments it is recommended to us `.notApplicable` instead of the
    /// default value `.unknown`.
    public var modeOfOperation: PolisModeOfOperation

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
                modeOfOperation: PolisModeOfOperation = .unknown,
                owner: PolisOwner?                    = nil,
                parentID: UUID?                       = nil,
                automationLabel: String?              = nil,
                mediaSourceID: UUID?                  = nil) {
        self.identity        = identity
        self.modeOfOperation = modeOfOperation
        self.owner           = owner
        self.parentID        = parentID
        self.mediaSourceID   = mediaSourceID
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
        case modeOfOperation = "mode_of_operation"
        case owner
        case parentID        = "parent_id"
        case automationLabel = "automation_label"
        case mediaSourceID   = "media_source_id"
    }
}

