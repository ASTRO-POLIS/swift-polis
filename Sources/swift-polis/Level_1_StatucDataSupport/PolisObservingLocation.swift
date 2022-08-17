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

public enum PolisEarthContinent: String, Codable {
    case europe
    case northAmerica
    case southAmerica
    case africa
    case asia
    case oceania
    case arctica
    case antarctica
}

public struct FixedEarthLocation: Codable {
    public let eastLongitude: Double?          // degrees
    public let latitude: Double?               // degrees
    public let altitude: Double?               // m
    public let continent: PolisEarthContinent?
    public let place: String?                  // e.g. Mount Wilson
    public let regionOrState: String?          // e.g. California
    public let regionOrStateCode: String?      // e.g. CA for California
    public let zipCode: String?                // e.g. US
    public let countryCode: String?            // 2-letter code.
    public let surfaceSize: Double?            // in m^2
}

public struct TemporaryEarthLocation: Codable {
    public let startTime: Date
    public let endTime: Date
    public let location: FixedEarthLocation
}

public enum PolisObservingLocation: Codable {
    case earthGroundBasedFixed(location: FixedEarthLocation)
    case earthGroundBasedMobile(locationDescription: [TemporaryEarthLocation])
    case unknown
}


//MARK: - Making types Codable and CustomStringConvertible -
// These extensions do not need any additional documentation.
public extension PolisEarthContinent {
    enum CodingKeys: String, CodingKey {
        case europe       = "Europe"
        case northAmerica = "North America"
        case southAmerica = "South America"
        case africa       = "Africa"
        case asia         = "Asia"
        case oceania      = "Oceania"
        case arctica      = "Arctica"
        case antarctica   = "Antarctica"
    }
}


public extension FixedEarthLocation {
    enum CodingKeys: String, CodingKey {
        case eastLongitude     = "east_longitude"
        case latitude
        case altitude
        case continent
        case place
        case regionOrState     = "region_or_state"
        case regionOrStateCode = "region_or_state_code"
        case zipCode           = "zip_code"
        case countryCode       = "country_ode"
        case surfaceSize       = "surface_size"
    }
}


public extension PolisObservingLocation {
    enum CodingKeys: String, CodingKey {
        case earthGroundBasedFixed  = "earth_ground_based_fixed"
        case earthGroundBasedMobile = "earth_ground_based_mobile"
        case unknown
   }
}
