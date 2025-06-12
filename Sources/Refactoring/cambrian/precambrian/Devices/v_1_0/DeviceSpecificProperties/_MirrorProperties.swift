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

    public enum MaterialType {
        case fusedSilica
        case pyrex
        case aluminium
        case zerodur
        case astroSitall
        case suprax
        case other
    }

    public enum Coating: String, Codable {
        case silver
        case aluminium
        case gold
        case other
    }
    
    public enum MirrorGeometry: String, Codable {
        case convex
        case concave
        case flat
        case other
    }

    public var type: MirrorType
    public var clearAperture: PolisPropertyValue? // [m]
    public var material: MaterialType?
    public var coating: Coating?
    public var position: UInt
    public var reflectivity: Double?            // [%]
    public var diameter: PolisPropertyValue?      // [m]
    public var aperture: PolisPropertyValue?      // [m]
    public var collectingArea: PolisPropertyValue?// [m^2]
    public var segmentCount: UInt = 1
    public var geometry: MirrorGeometry?

    //TODO: Do we need Thin vs. Classical discussion? -> Probably yes
}
