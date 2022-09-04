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



// Wanderar (for mobile platforms)
//    Orbiter
//    Rover

public struct AltitudeRange: Codable {
    public var lowOrbit: Double  // m
    public var highOrbit: Double // m
}

//public enum PolisObservatoryType {
//    // Location
//    case opticalTelescope(OpticalTelescope)
//    case radioAntenna(RadioAntenna)
//}


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
//    public var instruments: [InstrumentType]?
    public var telescopes: [OpticalTelescope]?
    public var description: String?
}
