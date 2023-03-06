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

/// A type that defines the owner of an observing site or a device.
///
/// Files containing an owner's information are in general stored within the static file hierarchy of the observing site (or equivalent).
/// For performance reasons, it is recommended (but not required by the standard) that the service provider supports a directory of owners
/// (as this framework does). Such a cache of owners would of course have performance and data maintenance implications as well.
public struct PolisItemOwner: Codable, Identifiable {

    /// A type that describes the different kinds of owners of a POLIS item.
    ///
    /// `OwnershipType` is used to identify the ownership type of POLIS items (or devices) such as observing sites, telescopes,
    /// CCD cameras, weather stations, etc. Different cases should be self-explanatory. The `private` type should be utilised by
    /// amateurs and hobbyists.
    public enum OwnershipType: String, Codable {
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
        case collaboration
        case `private`
        case other
    }

    public let identity: PolisIdentity
    public let type: OwnershipType
    public let shortName: String?   // e.g. MIT. MONET, BAO, ...

    public var id: UUID { identity.id }

    public init(identity: PolisIdentity, type: OwnershipType, shortName: String?) {
        self.identity  = identity
        self.type      = type
        self.shortName = shortName
    }
}

//MARK: - Type Extensions -

public extension PolisItemOwner {
    enum CodingKeys: String, CodingKey {
        case identity
        case type
        case shortName = "short_name"
    }
}
