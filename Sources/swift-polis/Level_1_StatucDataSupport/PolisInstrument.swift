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

public protocol PolisInstrumentType: Codable {
    var item: PolisItem                        { get set }

    var parent: PolisInstrumentType?           { get set }
    var subInstruments: [PolisInstrumentType]? { get set }

}

/// This is an abstract class that should not be used directly!
public class PolisInstrument: PolisInstrumentType {
    public var item: PolisItem

    public var parent: PolisInstrumentType? {
        get { return _parent }
        set { _parent = newValue as? PolisInstrument }
    }

    public var subInstruments: [PolisInstrumentType]? {
        get { return _subInstruments }
        set { _subInstruments = newValue as? [PolisInstrument] }
    }

    private weak var _parent: PolisInstrument?
    private      var _subInstruments: [PolisInstrument]?

    public init(item: PolisItem, parent: PolisInstrumentType? = nil, subInstruments: [PolisInstrumentType]? = nil) {
        self.item           = item
        self.parent         = parent
        self.subInstruments = subInstruments
    }
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

    var currentValue: Double?                   { get set }
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

public class WeatherStation: PolisInstrument {
    public var sensors = [PolisSensor]()
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
}
