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


/// `PolisTelescope` is an instrument to observe astronomical objects composed by a hierarchy of devices with the possiblity of being arranged in different configurations.
///
/// It contains a type defining how the sub devices are set up (e.g. reflector, refractor etc.), the part of the electromagnetic spectrum it covers, along with other properties such as network membership, interferometer capabilities etc. 
///

public struct PolisTelescope: Codable {

    /// Defines how the telescope works together with it's instruments as a combined system
    public enum `Type`: String, Codable {
        case reflector
        case refractor
        case steerableRadioDish
        case staticRadioDish
        case telephotoLens
        case cherenkov
        case radioAntenna
        case other
    }

    /// Documentation is needed
    public enum ObservingGrade: String, Codable {
        case amateur
        case professional
        case other
    }

    /// Documentation is needed
    public enum CollaborationCapability: String, Codable {
        case interferometer
        case vlbi
        case оpenForObservationRequests
        case none                       // default
    }
    
    /// Item information as defined by `PolisItem`
    public var item: PolisItem
    
    /// The International Astronomical Union (IAU) Minor Planet Centre (MPC) code
    public var observatoryCode: String?
    
    /// The type of the telescope, i.e. how the telescope functions in a general sense
    public var type: `Type`

    /// Is the telescope mostly professional or used for amateur observations
    public var observingGrade: ObservingGrade?

    /// Root devices of the hierarchy belonging to the telescope
    public var deviceIDs: Set<UUID>?
    
    /// `PolisConfiguration`s associated with the telescope
    public var configurationIDs: Set<UUID>?
    
    /// The URL of the telescope, e.g. https://subarutelescope.org/en/
    public var url: URL?
    
    /// Indication of if the telescope is capable of Interferometry or Very Long Baseline Interferometry (VLBI)
    public var collaborationCapabilities: [CollaborationCapability]?

    public init(item: PolisItem,
                observatoryCode: String?                               = nil,
                type: `Type`,
                observingGrade: ObservingGrade?                        = nil,
                deviceIDs: Set<UUID>?                                  = nil,
                configurationIDs: Set<UUID>?                           = nil,
                url: URL?                                              = nil,
                collaborationCapabilities: [CollaborationCapability]?  = nil) {
        self.item                      = item
        self.observatoryCode           = observatoryCode
        self.type                      = type
        self.observingGrade            = observingGrade
        self.deviceIDs                 = deviceIDs
        self.configurationIDs          = configurationIDs
        self.url                       = url
        self.collaborationCapabilities = collaborationCapabilities
    }
}

//MARK: - Making types Codable and CustomStringConvertible -

public extension PolisTelescope.`Type` {
    enum CodingKeys: String, CodingKey {
        case reflector           = "reflector"
        case refractor           = "refractor"
        case steerableRadioDish  = "steerable_radio_dish"
        case staticRadioDish     = "static_radio_dish"
        case telephotoLens       = "telephoto_lens"
        case cherenkov           = "cherenkov"
        case radioAntenna        = "radio_antenna"
        case other               = "other"
    }
}

public extension PolisTelescope.CollaborationCapability {
    enum CodingKeys: String, CodingKey {
        case interferometer
        case vlbi
        case оpenForObservationRequests = "оpen_for_observation_requests"
        case none
    }
}

public extension PolisTelescope {
    enum CodingKeys: String, CodingKey {
        case item
        case observatoryCode           = "observatory_code"
        case type
        case observingGrade            = "observing_grade"
        case deviceIDs                 = "device_ids"
        case configurationIDs          = "configuration_ids"
        case url
        case collaborationCapabilities = "collaboration_capabilities"
    }
}


//MARK: - Other junk code -


//public enum PolisTelescopeType: String, Codable {
//    case static_dish
//    case reflector
//    case steerable_dish
//    case refractor
//    case antenna
//    case telephoto_lens
//    case other
//    case unknown
//}
//
//public enum PolisFocusType: String, Codable {
//    case nasymth
//    case newtonian
//    case coude
//    case prime
//    case unknown
//}

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

//public extension PolisTelescopeType {
//    enum CodingKeys: String, CodingKey {
//        case staticDish         = "static_dish"
//        case reflector
//        case steerableDish      = "steerable_dish"
//        case refractor
//        case antenna
//    }
//}



// defines the overall type of the telescope, i.e. how the combined devices function together as a system
// public enum TelescopeType: String, Codable {
//     case reflector
//     case refractor
//     case steerableRadioDish
//     case staticRadioDish
//     case telephotoLens
//     case antenna
//     case other
// }

