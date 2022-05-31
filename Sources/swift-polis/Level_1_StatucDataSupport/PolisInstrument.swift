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

public enum PolisSensorType: Codable {
    case temperature
    case pressure
    case humidity
    case windspeed
    case windDirection
    case rain
    case dust
    case light
    case UVIndex
}

public struct PolisSensor: Codable {
    public var attributes: PolisItemAttributes

    public var type: PolisSensorType
    public var minValue: Double?
    public var maxValue: Double?
    public var precision: Double?
    public var units: String
    public var measurementFrequencyInSeconds: Double?

    public var currentValue: Double?
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

    public var parentID: UUID?
    public var subInstrumentIDs: [UUID]?

    public var sensorIDs: [UUID]?

    public init(item: PolisItem, type: PolisInstrumentType = .unknown, parentID: UUID? = nil, subInstrumentIDs: [UUID]? = nil, sensorIDs: [UUID]? = nil) {
        self.item             = item
        self.type             = type
        self.parentID         = parentID
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

