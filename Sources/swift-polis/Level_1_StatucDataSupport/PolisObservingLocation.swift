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

public struct FixedEarthLocation: Codable {
    public let eastLongitude: Double?      // degrees
    public let latitude: Double?           // degrees
    public let altitude: Double?           // m
    public let place: String?              // e.g. Mount Wilson
    public let regionOrState: String?      // e.g. California
    public let regionOrStateCode: String?  // e.g. CA for California
    public let zipCode: String?            // e.g. US
    public let countryCode: String         // 2-letter code.
    public let surfaceSize: Double?        // in m^2
}

public struct TemporaryEarthLocation: Codable {
    public let startTime: Date
    public let endTime: Date
    public let location: FixedEarthLocation
}

public enum PolisObservingLocation: Codable {
    case earthGroundBasedFixed(location: FixedEarthLocation)
    case earthGroundBasedMobile(locationDescription: [TemporaryEarthLocation])
}


//MARK: - Making types Codable and CustomStringConvertible -
// These extensions do not need any additional documentation.


public extension PolisObservingLocation {
    enum CodingKeys: String, CodingKey {
        case earthGroundBasedFixed  = "earth_ground_based_fixed"
        case earthGroundBasedMobile = "earth_ground_based_mobile"
    }
}
