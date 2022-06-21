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

public enum PolisFinderscopeModeOfOperation: String, Codable {
    case manual
    case remote
    case robotic
    case unknown
}

public class PolisFinderscope: Codable {
    public var item: PolisItem   // Finderscope Identification
    public var type: [String]
    public var eastLongitude: Float
    public var latitude: Float
    public var elevation: Float
    public var modeOfOperation: PolisTelescopeModeOfOperation
    public var primaryMirrorDiameter: Float
    public var secondaryMirrorDiameter: Float
    public var focus: [String]
    public var focalLength: [Float]
    public var focalRatio: [String]
    public var collectingArea: Float
    public var aperture: Float
}


//MARK: - Type extensions -


public extension PolisFinderscope {
    enum CodingKeys: String, CodingKey {
        case item
        case modeOfOperation = "mode_of_operation"
    }
}
