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

public struct MirrorProperties {
    public enum MaterialType {
        case fusedSilica
    }

    public var clearAperture: PolisMeasurement  // in "m"
    public var material: MaterialType?

    // Geometry
    // Rank order - what about siderostats?
    // Coating

    // Ups, and what about multi-mirror systems?
    // Thin vs. classical discussion?
    // Active vs. passive?
    // Solid vs. liquid?
    // Do we need concave vs. convex?
}
