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


//MARK: - Manufacturer information -

/// A type that encapsulates basic information about the manufacturer.
///
/// Every provider is free to implement it's own handling of lists of manufacturers, but we highly recommend that all manufacturer information is managed in a single,
/// possibly manually maintained, cache. This will help client applications to display unique information and avoid "almost the same" information being found multiple
/// times. It is preferable and better for the community as a whole if manufacturers maintain their product catalogues themselves.
///
/// It is important that POLIS Providers guarantee the uniqueness of manufacturers and their products. This is not required by the standard, but it is strongly
/// recommended and makes the experience better for everyone.
public struct PolisManufacturer: Codable, Identifiable {
    /// Makes `PolisManufacturer` uniquely identifiable.
    public var identity: PolisIdentity
    
    public var id: UUID { identity.id }

    public var uniqueName: String     // e.g. ASA, Meade, ... used for statically grouping reusable resources

    /// The fully qualified URL of the service provider, e.g. https://www.celestron.com
    public var url: URL?

    /// The point-of-contact for the manufacturer.
    public var contact: PolisAdminContact?

    public init(identity: PolisIdentity, uniqueName: String, url: URL? = nil, contact: PolisAdminContact? = nil) {
        self.identity   = identity
        self.uniqueName = uniqueName
        self.url        = url
        self.contact    = contact
    }
}


extension PolisManufacturer {
    enum CodingKeys: String, CodingKey {
        case identity
        case uniqueName = "unique_name"
        case url
        case contact
    }
}