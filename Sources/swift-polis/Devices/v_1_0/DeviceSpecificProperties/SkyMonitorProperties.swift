//
//  SkyMonitorProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct SkyMonitorProperties: Codable {
    public var spatialResolution: PolisMeasurement? // [degree]
    public var updateRate: PolisMeasurement?        // [s]
}
