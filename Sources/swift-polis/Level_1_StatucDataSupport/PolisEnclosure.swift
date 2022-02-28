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

public enum PolisEnclosureType: String, Codable {
    case dome
    case rollOff
    case clamshell
    case other
}

public enum PolisEnclosureModeOfOperation: String, Codable {
    case manual
    case robotic
}

public struct PolisEnclosure: Codable {
    public var item: PolisItem   // Observing Site Identification
    public var type: PolisEnclosureType
    public var modeOfOperation: PolisEnclosureModeOfOperation
}


//MARK: - Type extensions -


public extension PolisEnclosureType {
    enum CodingKeys: String, CodingKey {
        case dome      = "dome"
        case rollOff   = "roll_off"
        case clamshell = "clamshell"
        case other     = "other"
    }
}
