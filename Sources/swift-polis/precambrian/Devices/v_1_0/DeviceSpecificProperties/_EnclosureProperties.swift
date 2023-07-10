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
public struct EnclosureProperties {

    public enum EnclosureType {
        case dome(diameter: PolisPropertyValue?, slitSize: PolisPropertyValue?, maximumSlewingRate: PolisPropertyValue?)  // [m], [m], [deg s^-1]
        case rollOffRoof(length: PolisPropertyValue?, width: PolisPropertyValue?, hight: PolisPropertyValue?)               // [m], [m], [m]
        case clamshell(diameter: PolisPropertyValue?, door1: PolisDirection?, door2: PolisDirection?)                    // [m]
        case platform(length: PolisPropertyValue?, width: PolisPropertyValue?)                                          // [m], [m] - Open, no roof
        case other
    }

    public var type: EnclosureType
}
