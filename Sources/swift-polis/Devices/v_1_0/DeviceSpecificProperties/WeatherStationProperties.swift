//
//  WeatherStationProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct WeatherStationProperties: Codable {

    public enum SensorType: String, Codable {
        case temperature
        case windSpeed
        case windDirection
        case humidity
        case precipitation
        case pressure
        case dust
        case skyBrightness
    }

    public var sensors = [SensorType]()
    public var updateFrequency: PolisMeasurement? // [s]
    
}

