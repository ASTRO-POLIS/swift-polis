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
    case KuiperBeltObject(String)

    case moon(SolarSystemBodyType, String)       // e.g. .moon(.Jupiter, "Titan")
    case asteroid(String)
    case comet(String)
}

public enum ObservingSiteLocationType {
    case earthGroundBasedFixed
    case earthGroundBasedMobile
    case earthAirBorn(altitudeInMeters: Double)                    // Altitude in km
    case groundBasedFixed(SolarSystemBodyType)
    case groundBasedMobile(SolarSystemBodyType)  // e.g. Mars rover
    case airBorn(SolarSystemBodyType, Double)
    case solarSystemBody(SolarSystemBodyType)
    case solarSystemNonOrbital                   // e.g. Voyager
    case extraSolarSystem
}

public struct ObservingSite {
    // Location
    public let name: String
    public let startDate: Date? // Might be unknown
    public let endDate: Date?   // if != nil -> either closed or temporary created (e.g. solar eclipse monitoring)
    public let observatories: [Observatory]
}

public enum ObservatoryType {
    // Location
    case telescope(Telescope)
    case radioAntenna(RadioAntenna)
}

public struct Observatory {
    let type: ObservatoryType
}

public enum InstrumentType {
}

public struct Telescope {
    // Aperture
    // Camera
    public let description: String?
    // FocalLength
    // FocalRatio
    // Mirrors
    // SpectralEfficiency
    // SpectralRegion
    // TrackRate
    public let telescopes: [Telescope]?
    public let instruments: [InstrumentType]?
}

public struct RadioAntenna {

}
