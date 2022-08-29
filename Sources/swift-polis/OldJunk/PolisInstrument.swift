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

public enum PolisInstrumentType: String, Codable {
    case telescope
    case telescopeMount
    case weatherStation
    case flatFieldScreen
    case camera
    case spectrograph
    case webcam
    case unknown
}

//public class PolisInstrument: Codable {
////    public var item: PolisItem
//
//    public var type: PolisInstrumentType
//
//    public var subInstrumentIDs: [UUID]?
//    public var sensorIDs: [UUID]?
//
//    public init(item: PolisItem, type: PolisInstrumentType = .unknown, subInstrumentIDs: [UUID]? = nil, sensorIDs: [UUID]? = nil) {
//        self.item             = item
//        self.type             = type
//        self.subInstrumentIDs = subInstrumentIDs
//        self.sensorIDs        = sensorIDs
//    }
//}


//MARK: - Making types Codable and CustomStringConvertible -
//public extension PolisInstrumentType {
//    enum CodingKeys: String, CodingKey {
//        case telescope
//        case telescopeMount  = "telescope_mount"
//        case weatherStation  = "weather_station"
//        case flatFieldScreen = "flat_field_screen"
//        case camera
//        case spectrograph
//        case webcam
//        case unknown
//    }
//}

//public extension PolisInstrument {
//    enum CodingKeys: String, CodingKey {
//        case item
//        case type
//        case subInstrumentIDs = "sub_instrument_ids"
//        case sensorIDs        = "sensor_ids"
//    }
//}
