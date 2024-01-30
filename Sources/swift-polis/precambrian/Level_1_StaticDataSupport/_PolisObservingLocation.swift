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

/*
import Foundation

public enum PolisRelationshipToTheGravitationalBodyType: String, Codable {
    case surface
    case orbital
}

public protocol PolisLocationClassificationProtocol {
//    func solarSystemBody()                    -> PolisObservingSiteLocationType.SolarSystemBodyType
    func relationshipToTheGravitationalBody() -> PolisRelationshipToTheGravitationalBodyType
    func isStatic()                           -> Bool
}

//TODO: Make the type a PolisLocationClassificationProtocol
public enum PolisObservingSiteLocationType: Codable {

    public enum SurfaceLocationType: String, Codable {
        case fixed
        case airborne
        case mobile
        case other
    }

    public enum OrbitalType: String, Codable {
        case keplerian
        case nonKeplerian
        case transitional // For transitional orbits the base should be the destination object!
        case chaotic
        case unknown
    }

    public struct EarthBasedLocation: Codable {

        public let eastLongitude: PolisPropertyValue? // degrees
        public let latitude: PolisPropertyValue?      // degrees
        public let altitude: PolisPropertyValue?      // m
        public var timeZoneIdentifier: String?      // .. as defined with `TimeZone.knownTimeZoneIdentifiers`
//        public var continent: EarthContinent?
        public let place: String?                   // e.g. Mount Wilson
        public let regionOrState: String?           // e.g. California
        public let regionOrStateCode: String?       // e.g. CA for California
        public let zipCode: String?                 // e.g. 12345
        public let country: String?                 // e.g. Armenia
        public let countryCode: String?             // 2-letter code.
        public let surfaceSize: PolisPropertyValue?   // in m^2

        public init(eastLongitude: PolisPropertyValue? = nil,
                    latitude: PolisPropertyValue?      = nil,
                    altitude: PolisPropertyValue?      = nil,
//                    continent: EarthContinent?         = nil,
                    place: String?                     = nil,
                    regionOrState: String?             = nil,
                    regionOrStateCode: String?         = nil,
                    zipCode: String?                   = nil,
                    country: String?                   = nil,
                    countryCode: String?               = nil,
                    surfaceSize: PolisPropertyValue?   = nil) {
            self.eastLongitude     = eastLongitude
            self.latitude          = latitude
            self.altitude          = altitude
//            self.continent         = continent
            self.place             = place
            self.regionOrState     = regionOrState
            self.regionOrStateCode = regionOrStateCode
            self.zipCode           = zipCode
            self.country           = country
            self.countryCode       = countryCode
            self.surfaceSize       = surfaceSize
        }
    }

    //TODO:
    // - Orbital location
    // - Lander location
    // - Airborne location

    /// Anything but the Earth
//    public struct GravitationalObjectBasedLocation: Codable {
//        public let eastLongitude: PolisPropertyValue?     // degrees
//        public let latitude: PolisPropertyValue?          // degrees
//        public let altitude: PolisPropertyValue?          // m
//        public let region: String?                      // e.g. the Tranquility crater
//    }

    case earthSurfaceBased(location: EarthBasedLocation, type: SurfaceLocationType)
    case earthOrbital(type: OrbitalType)
//    case solarSystemBodySurfaceBased(location: GravitationalObjectBasedLocation, type: SurfaceLocationType)
    case solarSystemBodyOrbital(type: OrbitalType)
}


//MARK: - Making types Codable and CustomStringConvertible -
// These extensions do not need any additional documentation.



public extension PolisObservingSiteLocationType.OrbitalType {
    enum CodingKeys: String, CodingKey {
        case keplerian    = "Keplerian"
        case nonKeplerian = "non-Keplerian"
        case transitional
        case chaotic
        case unknown
    }
}

public extension PolisObservingSiteLocationType {
    enum CodingKeys: String, CodingKey {
        case earthSurfaceBased           = "earth_surface_based"
        case earthOrbital                = "earth_orbital"
//        case solarSystemBodySurfaceBased = "solar_system_body_surface_based"
        case solarSystemBodyOrbital      = "solar_system_body_orbital"
    }
}

*/

