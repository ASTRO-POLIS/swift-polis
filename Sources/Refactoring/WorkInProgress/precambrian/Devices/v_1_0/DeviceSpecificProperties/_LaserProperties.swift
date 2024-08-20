//
//  LaserProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct LaserProperties: Codable {

    public var power: PolisPropertyValue?               // [watt]
    public var wavelength: PolisPropertyValue?          // [m]
    public var atmosphericDistance: PolisPropertyValue? // [km]
}
