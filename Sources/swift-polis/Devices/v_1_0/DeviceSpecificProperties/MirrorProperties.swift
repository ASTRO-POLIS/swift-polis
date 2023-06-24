//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
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

// TODO: Make everything codable!

public struct MirrorProperties {

    public enum MirrorType: String, Codable {
        case solid
        case liquid
        case dish
    }

    //TODO: More types needed
    public enum MaterialType {
        case fusedSilica
        case other
    }

    public enum Coating: String, Codable {
        case silver
        case aluminium
        case other
    }

    public var type: MirrorType


    public var clearAperture: PolisMeasurement  // [m]
    public var material: MaterialType?          //TODO: This was not in the original proposal
    public var coating: Coating                 //TODO: It was suggested as String. Is enum not better?
    public var position: UInt                   //TODO: Is it not better to be UInt 1.. ?
    public var reflectivity: Double             //TODO: Double (0.0 ... 1.0)?
    public var diameter: PolisMeasurement       // [m]
    public var aperture: PolisMeasurement       // [m]
    public var collectingArea: PolisMeasurement // [m^2]
    public var segmentCount: UInt = 1

    //TODO: Do we need  Geometry? concave vs. convex?
    //TODO: Do we need Thin vs. Classical discussion?
}
