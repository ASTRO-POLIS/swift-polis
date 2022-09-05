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

/// `PolisManufacturer` encapsulates basic information about manufacturer.
///
/// Every provider is free to implement it's own handling of list of manufacturers, but we highly recommend that all manufacturer information is managed in a single,
/// possibly manually maintained cache. This will help client application to display unique information and avoid "almost the same" information to be found multiple
/// times. It is best if manufacturers maintain their product catalogues themselves.
///
/// It is important that POLIS Providers guarantee the uniqueness of manufacturers and their products. This is not required by the standard, but it is strongly
/// recommended.
public struct PolisManufacturer: Codable, Identifiable {
    /// Makes `PolisManufacturer` uniquely identifiable
    public var identity: PolisIdentity

    public var uniqueName: String     // e.g. asa, mead, ... used for statically grouping reusable resources

    /// The fully qualified URL of the service provider, e.g. https://www.celestron.com
    public var url: URL?

    /// The person (or email address) you can contact.
    public var contact: PolisAdminContact?

    /// `id` is needed to make the structure `Identifiable`
    public var id: UUID { identity.id }
}


extension PolisManufacturer {
    enum CodingKeys: String, CodingKey {
        case identity
        case uniqueName = "unique_name"
        case url
        case contact
    }
}