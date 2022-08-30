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

/// `PolisItemOwner` defines the owner of an observing site or a device.
///
/// Files containing owner's info are in general stored within the observing site (or equivalent) static file
/// hierarchy. For performance reasons it is recommended (but not required by the standard) that the service provider
/// supports a directory of owners (as this framework does). Such cache of owners has performance and data maintenance
/// implications. And as we know, ownership is unfortunately politically highly charged issue in astronomy.
public struct PolisItemOwner: Codable, Identifiable {

    /// `OwnershipType` defines various ownership types
    ///
    /// `OwnershipType` is used to identify the ownership type of POLIS items (or device) - observing sites, telescopes,
    /// CCD cameras, weather stations, etc. Different cases should be self-explanatory. `private` should be used by
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
}

//MARK: - Type Extensions -

public extension PolisItemOwner {
    enum CodingKeys: String, CodingKey {
        case identity
        case type
        case shortName = "short_name"
    }
}
