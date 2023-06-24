//
//  CameraProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct CameraProperties: Codable {
    public enum SensorType: String, Codable {
        case ccd
        case cmos
        case other
    }

    public var sensorType: SensorType                      //TODO: Originally it was suggested String, but I remember that we discussed enum. Correct?
    public var numberOfPixelsX: Int
    public var numberOfPixelsY: Int
    public var pixelSizeX: PolisMeasurement                // [µ]
    public var pixelSizeY: PolisMeasurement                // [µ]
    public var material: String?                           //TODO: Why not Enum? Is it optional?
    public var readoutTimeWithoutBinning: PolisMeasurement // [s]
}
