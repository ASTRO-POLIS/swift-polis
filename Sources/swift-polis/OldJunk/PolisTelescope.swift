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
import UnitsAndMeasurements

public enum PolisTelescopeType: String, Codable {
    case static_dish
    case reflector
    case steerable_dish
    case refractor
    case antenna
    case telephoto_lens
    case other
    case unknown
}

public enum PolisEmSpectrumCoverage: String, Codable {
    case gammaRay
    case xRay
    case ultraviolet
    case optical
    case infrared
    case subMillimeter
    case radio
    case other
    case unknown
}

public enum PolisFocusType: String, Codable {
    case nasymth
    case newtonian
    case coude
    case prime
    case unknown
}

//Warning: These should be configurable! Not an Enum!
//public enum PolisParentNetwork: String, Codable {
//    case eventHorizonTelescope
//    case australianVLBINetwork
//    case europeanVLBINetwork
//    case americanVLBINetwork
//    case unknown
//}

//public struct PolisTelescope: Codable {
////    public var item: PolisItem   // Telescope Identity
//    public var type: PolisTelescopeType
//    public var location: PolisObservingLocation?
//    public var modeOfOperation: PolisModeOfOperation?
//    public var emSpectrumCoverage = PolisEmSpectrumCoverage.unknown
//    public var primaryMirrorDiameter: UnitsAndMeasurements.Measurement<Double>
//    public var secondaryMirrorDiameter: UnitsAndMeasurements.Measurement<Double>
//    public var focusType = PolisFocusType.unknown
//    public var focalLength: UnitsAndMeasurements.Measurement<Double>
//    public var focalRatio: String
//    public var collectingArea: Double
//    public var aperture: Double
//    public var objectives: String
//    public var minimumBaseline: Double
//    public var maximumBaseline: Double
//    public var arrayConstituents: Int
//    public var mirrorCoating: String
//    public var vlbiCapabilities: Bool
////    public var vlbiParentNetwork = PolisParentNetwork.unknown
//    public var detectorIDs: [UUID]?
//    public var mountIDs: [UUID]?
//    public var finderscopeIDs: [UUID]?
//    public var aoIDs: [UUID]?
//}
//

//MARK: - Type extensions -


//public extension PolisTelescope {
//    enum CodingKeys: String, CodingKey {
//        case item
//        case location
//        case modeOfOperation    = "mode_of_operation"
//        case detectorIDs        = "detector_ids"
////        case mountIDs           = "mount_ids"
//        case finderscopeIDs     = "finderscope_ids"
////        case aoIDs              = "ao_ids"
//    }
//}

public extension PolisTelescopeType {
    enum CodingKeys: String, CodingKey {
        case staticDish         = "static_dish"
        case reflector
        case steerableDish      = "steerable_dish"
        case refractor
        case antenna
    }
}
