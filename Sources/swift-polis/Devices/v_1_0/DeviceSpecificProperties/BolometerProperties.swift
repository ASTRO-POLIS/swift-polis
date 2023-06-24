//
//  BolometerProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct BolometerProperties: Codable {

    //TODO: Bolometer has no sensor type? If yes, Bolometer and Camera could be combined with an extra enum for the type of SensingDevice ... Better name?
    public var numberOfPixelsX: Int
    public var numberOfPixelsY: Int
    public var pixelSizeX: PolisMeasurement                // [µ]
    public var pixelSizeY: PolisMeasurement                // [µ]
    public var material: String?                           //TODO: Why not Enum? Is it optional?
    public var readoutTimeWithoutBinning: PolisMeasurement // [s]
}
