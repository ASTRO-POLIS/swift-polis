//
//  LaserProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct LaserProperties: Codable {

    public var power: PolisMeasurement               // [watt]
    public var wavelength: PolisMeasurement          // [m]
    public var atmosphericDistance: PolisMeasurement // [km]
}
