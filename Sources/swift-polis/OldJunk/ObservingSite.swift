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

public struct AltitudeRange: Codable {
    public var lowOrbit: Double  // m
    public var highOrbit: Double // m
}

public enum ObservingSiteLocationType {
    case earthAirBorn(range: AltitudeRange?)                            // Altitude in km
    case groundBasedFixed(location: SolarSystemBodyType)
    case groundBasedMobile(location: SolarSystemBodyType)               // e.g. Mars rover
    case airBorn(location: SolarSystemBodyType, range: AltitudeRange?)
    case solarSystemBodyOrbital(location: SolarSystemBodyType)
    case solarSystemBodyNonOrbital(locationDescription: String?)        // e.g. Voyager
    case extraSolarSystem
    case ivoa(descriptor: String)
}

//public enum PolisObservatoryType {
//    // Location
//    case opticalTelescope(OpticalTelescope)
//    case radioAntenna(RadioAntenna)
//}


public struct Observatory {
    var type: PolisObservatoryType
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
