//
//  WeatherStationProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct WeatherStationProperties: Codable {

    //TODO: This list is different (enhanced) compared to the suggested. OK?
    public enum SensorType: String, Codable {
        case temperature
        case windSpeed
        case windDirection
        case humidity
        case precipitation
        case pressure
        case dust
        case skyBrightness
        case uvIndex        //TODO: Do we need this?
    }

    public var sensors = [SensorType]()
    public var updateFrequency: PolisMeasurement // [s]
    
}

