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

public struct PolisSensor: Codable, Identifiable {
    public var attributes: PolisItemAttributes
    public var sensor: SensorDescription

    public var id: UUID { attributes.id }

    public init(attributes: PolisItemAttributes, sensorDescription: SensorDescription) {
        self.attributes = attributes
        self.sensor     = sensorDescription
    }
    
}

public enum PolisInstrumentType: String, Codable {
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

public extension PolisInstrument {
    enum CodingKeys: String, CodingKey {
        case item
        case type
        case assignedToID     = "assignet_to_id"
        case subInstrumentIDs = "sub_instrument_ids"
        case sensorIDs        = "sensor_ids"
    }
}
