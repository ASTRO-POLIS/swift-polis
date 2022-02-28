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

public enum PolisObservatoryModeOfOperation: Codable {
    case manual
    case manualWithAutomatedImaging
    case manualWithAutomatedScheduling
    case robotic
}

public struct PolisObservatory: Codable {
    public var enclosure: PolisEnclosure
    public var modeOfOperation: PolisObservatoryModeOfOperation
}
