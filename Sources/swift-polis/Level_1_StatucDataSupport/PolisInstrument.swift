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

public enum PolisSensorType: Codable {
    case temperature
    case pressure
    case humidity
    case windspeed
    case windDirection
    case rain
    case dust
    case light       // Should it be CCD, or SMOS?
    case UVIndex
}

public struct PolisSensor: Codable {
    public var attributes: PolisItemAttributes

    public var type: PolisSensorType
    public var minValue: Double?
    public var maxValue: Double?
    public var precision: Double?                                        // A universal way to express precision???
    public var units: UnitsAndMeasurements.Unit
    public var measurementFrequency: UnitsAndMeasurements.Measurement<Double>?

    public var currentValue: UnitsAndMeasurements.Measurement<Double>?   // This is not good! Discuss! Perhaps an enum?
}


public enum PolisInstrumentType: Codable {
    case telescope
    case weatherStation
    case flatFieldScreen
    case camera
    case spectrograph
    case webcam
    case unknown
}

/// This is an abstract class that should not be used directly!
public struct PolisInstrument: Codable {
    public var item: PolisItem

    public var type: PolisInstrumentType

    public var assignedToID: UUID?
    public var subInstrumentIDs: [UUID]?

    public var sensorIDs: [UUID]?

    public init(item: PolisItem, type: PolisInstrumentType = .unknown, assignedToID: UUID? = nil, subInstrumentIDs: [UUID]? = nil, sensorIDs: [UUID]? = nil) {
        self.item             = item
        self.type             = type
        self.assignedToID     = assignedToID
        self.subInstrumentIDs = subInstrumentIDs
        self.sensorIDs        = sensorIDs
    }
}


//MARK: - Making types Codable and CustomStringConvertible -

public extension PolisSensorType {
    enum CodingKeys: String, CodingKey {
        case temperature
        case pressure
        case humidity
        case windspeed
        case windDirection = "wind_direction"
        case rain
        case dust
        case light
        case UVIndex       = "uv_index"
    }
}

public extension PolisInstrument {
    enum CodingKeys: String, CodingKey {
        case item
        case type
        case assignedToID     = "assignet_to_id"
        case subInstrumentIDs = "sub_instrument_ids"
        case sensorIDs        = "sensor_ids"
    }
}
