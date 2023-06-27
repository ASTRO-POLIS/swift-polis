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

    public var sensorType: SensorType
    public var numberOfPixelsX: Int?
    public var numberOfPixelsY: Int?
    public var pixelSizeX: PolisMeasurement?                // [µm]
    public var pixelSizeY: PolisMeasurement?                // [µm]
    public var material: String?                            //TODO: Why not Enum? Is it optional? -> Same as all the other materials, yes optional
    public var readoutTimeWithoutBinning: PolisMeasurement? // [s]
}
