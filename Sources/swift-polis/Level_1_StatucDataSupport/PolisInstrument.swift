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

public protocol PolisInstrument: Codable {
    var item: PolisItem                    { get set }

    var parent: PolisInstrument?           { get set }
    var subInstruments: [PolisInstrument]? { get set }
}

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

public protocol PolisSensing: Codable {
    var attributes: PolisItemAttributes         { get set }

    var type: PolisSensorType                   { get }

    var minValue: Double?                       { get set }
    var maxValue: Double?                       { get set }
    var precision: Double?                      { get set }
    var units: String                           { get set }
    var measurementFrequencyInSeconds: Double?  { get set }

    var currentValue: Double                    { get set }
}

public struct PolisSensor: PolisSensing {
    public var attributes: PolisItemAttributes

    public var type: PolisSensorType
    public var minValue: Double?
    public var maxValue: Double?
    public var precision: Double?
    public var units: String
    public var measurementFrequencyInSeconds: Double?

    public var currentValue: Double?
}

public struct WeatherStation: PolisInstrument {
    public var item: PolisItem
    public var parent: PolisInstrument?
    public var subInstruments: [PolisInstrument]?

    public var sensors: [PolisSensor]
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


public extension WeatherStation {
    enum CodingKeys: String, CodingKey {
        case item
        case parent
        case subInstruments = "sub_instruments"
        case sensors
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        //TODO: Decode the parent!
        self.item = try container.decode(PolisItem.self, forKey: .item)
        self.subInstruments = [PolisInstrument]()   //TODO: Make proper decoding!
        self.sensors = try container.decode([PolisSensor].self, forKey: .sensors)

        //TODO: Finish implementation!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(item, forKey: .item)
        try container.encode(sensors, forKey: .sensors)
        //TODO: Finish implementation!
    }
}
