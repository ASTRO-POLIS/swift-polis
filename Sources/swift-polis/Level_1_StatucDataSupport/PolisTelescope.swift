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

public enum PolisTelescopeModeOfOperation: String, Codable {
    case manual
    case remote
    case robotic
    case unknown
}

public class PolisTelescope: Codable {
    public var item: PolisItem   // Telescope Identification
    public var type: [String]
    public var eastLongitude: Float
    public var latitude: Float
    public var elevation: Float
    public var modeOfOperation: PolisTelescopeModeOfOperation
    public var emSpectrumCoverage: [String]
    public var primaryMirrorDiameter: Float
    public var secondaryMirrorDiameter: Float
    public var focus: [String]
    public var focalLength: [Float]
    public var focalRatio: [String]
    public var collectingArea: Float
    public var aperture: Float
    public var objectives: String
    public var manimumBaseline: Float
    public var maximumBaseline: Float
    public var arrayConstituents: Int
    public var mirrorCoating: String
    public var vlbiCapabilities: Bool
    public var vlbiParentNetwork: [String]
    public var detectorIDs: [UUID]
    public var mountIDs: [UUID]
    public var finderscopeIDs: [UUID]
    public var aoIDs: [UUID]
}


//MARK: - Type extensions -


public extension PolisTelescope {
    enum CodingKeys: String, CodingKey {
        case item
        case modeOfOperation    = "mode_of_operation"
        case detectorIDs        = "detector_ids"
        case mountIDs           = "mount_ids"
        case finderscopeIDs     = "finderscope_ids"
        case aoIDs              = "ao_ids"
    }
}
