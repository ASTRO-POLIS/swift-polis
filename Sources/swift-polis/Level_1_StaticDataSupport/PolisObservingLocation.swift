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

public enum PolisRelationshipToTheGravitationalBodyType: String, Codable {
    case surface
    case orbital
}

public protocol PolisLocationClassificationProtocol {
    func solarSystemBody()                    -> PolisObservingSiteLocationType.SolarSystemBodyType
    func relationshipToTheGravitationalBody() -> PolisRelationshipToTheGravitationalBodyType
    func isStatic()                           -> Bool
}

//TODO: Make the type a PolisLocationClassificationProtocol
public enum PolisObservingSiteLocationType: Codable {

    public enum SurfaceLocationType: String, Codable {
        case fixed
        case airborne
        case mobile
        case unknown
    }

    public enum OrbitalType: String, Codable {
        case keplerian
        case nonKeplerian
        case transitional // For transitional orbits the base should be the destination object!
        case chaotic
        case unknown
    }

    public indirect enum SolarSystemBodyType: Codable {
        case sun

        // Planets
        case mercury
        case venus
        case earth
        case mars
        case jupiter
        case saturn
        case uranus
        case neptune

        // Kuiper and Asteroid belt
        case pluto
        case ceres
        case haumea
        case makemake
        case eris
        case asteroidBeltObject(name: String, code: String?)
        case kuiperBeltObject(name: String, code: String?)

        // Miscellaneous
        case moon(of: SolarSystemBodyType, name: String, code: String?)       // e.g. .moon(.Jupiter, "Titan")
        case comet(name: String, code: String?)
    }

    public struct EarthBasedLocation: Codable {

        public enum EarthContinent: String, Codable {
            case europe       = "Europe"
            case northAmerica = "North America"
            case southAmerica = "South America"
            case africa       = "Africa"
            case asia         = "Asia"
            case oceania      = "Australia and Oceania"
            case antarctica   = "Antarctica"
        }

        public let eastLongitude: PolisMeasurement? // degrees
        public let latitude: PolisMeasurement?      // degrees
        public let altitude: PolisMeasurement?      // m
        public var timeZoneIdentifier: String?      // .. as defined with `TimeZone.knownTimeZoneIdentifiers`
        public var continent: EarthContinent?
        public let place: String?                   // e.g. Mount Wilson
        public let regionOrState: String?           // e.g. California
        public let regionOrStateCode: String?       // e.g. CA for California
        public let zipCode: String?                 // e.g. 12345
        public let country: String?                 // e.g. Armenia
        public let countryCode: String?             // 2-letter code.
        public let surfaceSize: PolisMeasurement?   // in m^2

        public init(eastLongitude: PolisMeasurement? = nil,
                    latitude: PolisMeasurement?      = nil,
                    altitude: PolisMeasurement?      = nil,
                    continent: EarthContinent?       = nil,
                    place: String?                   = nil,
                    regionOrState: String?           = nil,
                    regionOrStateCode: String?       = nil,
                    zipCode: String?                 = nil,
                    country: String?                 = nil,
                    countryCode: String?             = nil,
                    surfaceSize: PolisMeasurement?   = nil) {
            self.eastLongitude     = eastLongitude
            self.latitude          = latitude
            self.altitude          = altitude
            self.continent         = continent
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
    public struct GravitationalObjectBasedLocation: Codable {
        public let solarSystemBody: SolarSystemBodyType
        public let eastLongitude: PolisMeasurement?     // degrees
        public let latitude: PolisMeasurement?          // degrees
        public let altitude: PolisMeasurement?          // m
        public let region: String?                      // e.g. the Tranquility crater
    }

    case earthSurfaceBased(location: EarthBasedLocation, type: SurfaceLocationType)
    case earthOrbital(type: OrbitalType)
    case solarSystemBodySurfaceBased(location: GravitationalObjectBasedLocation, type: SurfaceLocationType)
    case solarSystemBodyOrbital(type: OrbitalType)
}


//MARK: - Making types Codable and CustomStringConvertible -
// These extensions do not need any additional documentation.

public extension PolisObservingSiteLocationType.SurfaceLocationType {
    enum CodingKeys: String, CodingKey {
        case fixed
        case airborne 
        case mobile
        case unknown
    }
}

public extension PolisObservingSiteLocationType.OrbitalType {
    enum CodingKeys: String, CodingKey {
        case keplerian    = "Keplerian"
        case nonKeplerian = "non-Keplerian"
        case transitional
        case chaotic
        case unknown
    }
}

public extension PolisObservingSiteLocationType.SolarSystemBodyType {
    enum CodingKeys: String, CodingKey {
        case sun                = "Sun"
        case mercury            = "Mercury"
        case venus              = "Venus"
        case earth              = "Earth"
        case mars               = "Mars"
        case jupiter            = "Jupiter"
        case saturn             = "Saturn"
        case uranus             = "Uranus"
        case neptune            = "Neptune"
        case pluto              = "Pluto"
        case ceres              = "Ceres"
        case haumea             = "Haumea"
        case makemake           = "Makemake"
        case eris               = "Eris"
        case asteroidBeltObject = "asteroid_belt_object"
        case kuiperBeltObject   = "Kuiper_belt_object"
        case moon
        case comet
   }
}

public extension PolisObservingSiteLocationType.EarthBasedLocation {
    enum CodingKeys: String, CodingKey {
        case eastLongitude      = "east_longitude"
        case latitude
        case altitude
        case timeZoneIdentifier = "time_zone_identifier"
        case continent
        case place
        case regionOrState      = "region_or_state"
        case regionOrStateCode  = "region_or_state_code"
        case zipCode            = "zip_code"
        case country
        case countryCode        = "country_code"
        case surfaceSize        = "surface_size"
    }
}

public extension PolisObservingSiteLocationType.EarthBasedLocation.EarthContinent {
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

public extension PolisObservingSiteLocationType.GravitationalObjectBasedLocation {
    enum CodingKeys: String, CodingKey {
        case solarSystemBody = "solar_system_body"
        case eastLongitude   = "east_longitude"
        case latitude
        case altitude
        case region
    }
}

public extension PolisObservingSiteLocationType {
    enum CodingKeys: String, CodingKey {
        case earthSurfaceBased           = "earth_surface_based"
        case earthOrbital                = "earth_orbital"
        case solarSystemBodySurfaceBased = "solar_system_body_surface_based"
        case solarSystemBodyOrbital      = "solar_system_body_orbital"
    }
}
