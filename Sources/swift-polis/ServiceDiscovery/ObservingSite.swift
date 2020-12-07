//
//  ObservingSite.swift
//  
//
//  Created by Georg Tuparev on 20/11/2020.
//

import Foundation

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

    case moon(planet: SolarSystemBodyType, name: String)       // e.g. .moon(.Jupiter, "Titan")
    case asteroid(name: String)
    case comet(name: String)
}

public enum ObservingSiteLocationType {
    case earthGroundBasedFixed(location: EarthLocation)
    case earthGroundBasedMobile(description: String)
    case earthAirBorn(range: AltitudeRange?)     // Altitude in km
    case groundBasedFixed(SolarSystemBodyType)
    case groundBasedMobile(SolarSystemBodyType)  // e.g. Mars rover
    case airBorn(SolarSystemBodyType, Double)
    case solarSystemBody(SolarSystemBodyType)
    case solarSystemNonOrbital                   // e.g. Voyager
    case extraSolarSystem
}

public struct AltitudeRange {
    let lowOrbit: Double  // m
    let highOrbit: Double // m
}

public struct EarthLocation {
    public let eastLongitude: Double  // degrees
    public let latitude: Double       // degrees
    public let altitude: Double?      // m
}

public struct ObservingSite {
    public let location: ObservingSiteLocationType
    public let name: String
    public let startDate: Date? // Might be unknown
    public let endDate: Date?   // if != nil -> either closed or temporary created (e.g. solar eclipse monitoring)
    public let observatories: [Observatory]
    public let description: String?
}

public enum ObservatoryType {
    // Location
    case opticalTelescope(OpticalTelescope)
    case radioAntenna(RadioAntenna)
}

public struct Observatory {
    let type: ObservatoryType
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
    public let instruments: [InstrumentType]?
    public let telescopes: [OpticalTelescope]?
    public let description: String?
}

public struct RadioAntenna {

}
