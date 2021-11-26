//
//  ObservingSite.swift
//
//
//  Created by Georg Tuparev on 20/11/2020.
//

import Foundation

public enum SiteOwnershipType: String, Codable {
    case university
    case research
    case commercial
    case school
    case network
    case government
    case ngo
    case `private`     // personal, amateur, ...
    case other         //TODO: Perhaps we need a `description` parameter?
}

public indirect enum SolarSystemBodyType {
    case Sun
    
    case Mercury
    case Venus
    case Earth
    case Mars
    case Jupiter
    case Saturn
    case Uranus
    case Neptune
    
    case Pluto
    case Ceres
    case Haumea
    case Makemake
    case Eris
    case KuiperBeltObject(name: String)
    
    case moon(of: SolarSystemBodyType, name: String)       // e.g. .moon(.Jupiter, "Titan")
    case asteroid(name: String)
    case comet(name: String)
}

public struct EarthLocation: Codable {
    public let eastLongitude: Double  // degrees
    public let latitude: Double       // degrees
    public let altitude: Double?      // m
    public let place: String?
    public let regionOrState: String?
    public let regionOrStateCode: String?
    public let zipCode: String?
    public let countryCode: String        // 3-letter code.
}

public struct AltitudeRange: Codable {
    public var lowOrbit: Double  // m
    public var highOrbit: Double // m
}

public enum ObservingSiteLocationType {
    case earthGroundBasedFixed(location: EarthLocation?)
    case earthGroundBasedMobile(locationDescription: String?)
    case earthAirBorn(range: AltitudeRange?)                            // Altitude in km
    case groundBasedFixed(location: SolarSystemBodyType)
    case groundBasedMobile(location: SolarSystemBodyType)               // e.g. Mars rover
    case airBorn(location: SolarSystemBodyType, range: AltitudeRange?)
    case solarSystemBodyOrbital(location: SolarSystemBodyType)
    case solarSystemBodyNonOrbital(locationDescription: String?)        // e.g. Voyager
    case extraSolarSystem
    case ivoa(descriptor: String)
}

public struct ObservingSite {
    public let location: ObservingSiteLocationType
    public let name: String
    public let startDate: Date? // Might be unknown
    public let endDate: Date?   // if != nil -> either closed or temporary created (e.g. solar eclipse monitoring)
    public let ownershipType: SiteOwnershipType
    public let observatories: [Observatory]
    public let description: String?
}

public enum ObservatoryType {
    // Location
    case opticalTelescope(OpticalTelescope)
    case radioAntenna(RadioAntenna)
}

public enum ModeOfOperation {
    case robotic
    case manual
}

public struct Observatory {
    var type: ObservatoryType
    // Coordinates
}

public enum InstrumentType {
}

public struct OpticalTelescope {
    // Aperture
    // Camera
    // [Devices]
    // FocalLength
    // FocalRatio
    // [Mirrors]
    // PlateScale
    // SpectralEfficiency
    // SpectralRegion
    // Spectrograph
    // TrackRate
    public var instruments: [InstrumentType]?
    public var telescopes: [OpticalTelescope]?
    public var description: String?
}

public struct RadioAntenna {
    
}
