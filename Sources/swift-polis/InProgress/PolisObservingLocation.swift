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

public enum PolisRelationshipToTheGravitationalBodyType: Codable {
    case surface
    case orbital
}

public protocol PolisLocationClassificationProtocol {
    func solarSystemBody()                    -> PolisObservingSiteLocationType.SolarSystemBodyType
    func relationshipToTheGravitationalBody() -> PolisRelationshipToTheGravitationalBodyType
    func isStatic()                           -> Bool
}

//TODO: Make this stuff Codable and Equitable! Uf what a pain :-(
public enum PolisObservingSiteLocationType {

    public enum SurfaceLocationType: Codable {
        case fixed
        case movable
        case mobile
        case unknown
    }

    public indirect enum SolarSystemBodyType {
        case Sun

        // Planets
        case Mercury
        case Venus
        case Earth
        case Mars
        case Jupiter
        case Saturn
        case Uranus
        case Neptune

        // Kuiper and Asteroid belt
        case Pluto
        case Ceres
        case Haumea
        case Makemake
        case Eris
        case asteroidBeltObject(name: String, code: String?)
        case KuiperBeltObject(name: String, code: String?)

        // Miscellaneous
        //TODO: Do we need the Minor Planet code?
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
        public let continent: EarthContinent?
        public let place: String?                   // e.g. Mount Wilson
        public let regionOrState: String?           // e.g. California
        public let regionOrStateCode: String?       // e.g. CA for California
        public let zipCode: String?                 // e.g. 12345
        public let country: String?                 // e.g. Armenia
        public let countryCode: String?             // 2-letter code.
        public let surfaceSize: PolisMeasurement?   // in m^2
        public let staticLocation: Bool             // Static or Airborne

        public init(eastLongitude: PolisMeasurement?  = nil,
                    latitude: PolisMeasurement?       = nil,
                    altitude: PolisMeasurement?       = nil,
                    continent: EarthContinent?        = nil,
                    place: String?                    = nil,
                    regionOrState: String?            = nil,
                    regionOrStateCode: String?        = nil,
                    zipCode: String?                  = nil,
                    country: String?                  = nil,
                    countryCode: String?              = nil,
                    surfaceSize: PolisMeasurement?    = nil,
                    staticLocation: Bool              = true) {
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
            self.staticLocation    = staticLocation
        }
    }

    case earthSurfaceBased(base: EarthBasedLocation, type: SurfaceLocationType)
    case orbitBased
}


//TODO: Make this stuff Codable! Oh boy, oh boy! What a pain!
//public enum ObservingSiteLocationType {
//    case earthAirBorn(range: AltitudeRange?)                            // Altitude in km
//    case groundBasedFixed(location: SolarSystemBodyType)
//    case groundBasedMobile(location: SolarSystemBodyType)               // e.g. Mars rover
//    case airBorn(location: SolarSystemBodyType, range: AltitudeRange?)
//    case solarSystemBodyOrbital(location: SolarSystemBodyType)
//    case solarSystemBodyNonOrbital(locationDescription: String?)        // e.g. Voyager
//}






//public struct TemporaryEarthLocation: Codable {
//    public let startTime: Date
//    public let endTime: Date
//    public let location: FixedEarthLocation
//
//    public init(startTime: Date, endTime: Date, location: FixedEarthLocation) {
//        self.startTime = startTime
//        self.endTime   = endTime
//        self.location  = location
//    }
//}

//public enum EarthBaseLocation: Codable {
//    case earthGroundBasedFixed(location: FixedEarthLocation)
//    case earthGroundBasedMobile(locationDescription: [TemporaryEarthLocation])
//
//    // orbiting: SolarSystemBodyType
//    // roving: SolarSystemBodyType
//
//    case unknown
//}


//MARK: - Making types Codable and CustomStringConvertible -
// These extensions do not need any additional documentation.
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


//public extension FixedEarthLocation {
//    enum CodingKeys: String, CodingKey {
//        case eastLongitude     = "east_longitude"
//        case latitude
//        case altitude
//        case continent
//        case place
//        case regionOrState     = "region_or_state"
//        case regionOrStateCode = "region_or_state_code"
//        case zipCode           = "zip_code"
//        case countryCode       = "country_ode"
//        case surfaceSize       = "surface_size"
//    }
//}


//public extension PolisObservingLocation {
//    enum CodingKeys: String, CodingKey {
//        case earthGroundBasedFixed  = "earth_ground_based_fixed"
//        case earthGroundBasedMobile = "earth_ground_based_mobile"
//        case unknown
//   }
//}
