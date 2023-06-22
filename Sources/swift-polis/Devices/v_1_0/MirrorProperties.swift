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
    public enum MaterialType {
        case fusedSilica
    }

    public enum Coating: String, Codable {
        case silver
        case aluminium
        case other
    }

    public var clearAperture: PolisMeasurement  // in "m"
    public var material: MaterialType?
    public var coating: Coating

    // Geometry
    // Rank order - what about siderostats?

    // Ups, and what about multi-mirror systems?
    // Thin vs. classical discussion?
    // Active vs. passive?
    // Solid vs. liquid?
    // Do we need concave vs. convex?
}
