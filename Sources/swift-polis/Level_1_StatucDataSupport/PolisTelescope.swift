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

public struct PolisTelescope: Codable {
    public var item: PolisItem   // Telescope Identification
//    public var type: [String]
    public var location: PolisObservingLocation?
    public var modeOfOperation: PolisModeOfOperation
//    public var emSpectrumCoverage: [String]
    //TODO: Discuss array of mirror tyypes!
//    public var primaryMirrorDiameter: Double
//    public var secondaryMirrorDiameter: Double
//    public var focus: [String]
//    public var focalLength: [Double]
//    public var focalRatio: [String]
//    public var collectingArea: Double
//    public var aperture: Double
//    public var objectives: String
//    public var minimumBaseline: Double
//    public var maximumBaseline: Double
//    public var arrayConstituents: Int
//    public var mirrorCoating: String
//    public var vlbiCapabilities: Bool
//    public var vlbiParentNetwork: [String]
    public var detectorIDs: [UUID]
//    public var mountIDs: [UUID]
    public var finderscopeIDs: [UUID]
//    public var aoIDs: [UUID]
}


//MARK: - Type extensions -


public extension PolisTelescope {
    enum CodingKeys: String, CodingKey {
        case item
        case location
        case modeOfOperation    = "mode_of_operation"
        case detectorIDs        = "detector_ids"
//        case mountIDs           = "mount_ids"
        case finderscopeIDs     = "finderscope_ids"
//        case aoIDs              = "ao_ids"
    }
}
