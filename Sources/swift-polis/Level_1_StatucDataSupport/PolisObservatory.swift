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
import CoreText

public enum PolisObservatoryType: String, Codable {
    case observingSite
    case platform
    case robot
    case network
}

public enum PolisObservatoryModeOfOperation: Codable {
    case manual
    case manualWithAutomatedDetector
    case manualWithAutomatedDetectorAndScheduling
    case autonomous
    case mixed                                       // e.g. in case of Network
    case other
    case unknown
}

public protocol PolisObservatory: Codable {
    var type: PolisObservatoryType                       { get set }
    var modeOfOperation: PolisObservatoryModeOfOperation { get set }
    var item: PolisItem                                  { get set }
    var startDate: Date?                                 { get set } // Could be nil if unknown
    var endDate: Date?                                   { get set } // if != nil -> either closed or temporary created (e.g. solar eclipse monitoring)
    var location: PolisObservingLocation?                { get set }
    var instrumentIDs: [UUID]                            { get set }
}

//MARK: - Making types Codable and CustomStringConvertible -
// These extensions do not need any additional documentation.

public extension PolisObservatoryType {
    enum CodingKeys: String, CodingKey {
        case observingSite = "observing_site"
        case platform
        case robot
        case network
    }
}

public extension PolisObservatoryModeOfOperation {
    enum CodingKeys: String, CodingKey {
        case manual
        case manualWithAutomatedDetector              = "manual_with_automated_detector"
        case manualWithAutomatedDetectorAndScheduling = "manual_with_automated_detector_and_scheduling"
        case autonomous
        case mixed
        case other
        case unknown
    }
}

//MARK: - Making types Codable and CustomStringConvertible -

//public extension PolisObservatory {
//    enum CodingKeys: String, CodingKey {
//        case type
//        case modeOfOperation = "mode_of_operation"
//        case item
//        case startDate = "start_date"
//        case endDate = "end_date"
//        case location
//        case instruments
//    }
//}
