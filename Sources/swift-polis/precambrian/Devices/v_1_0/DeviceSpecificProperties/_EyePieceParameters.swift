//
//  EyePieceParameters.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct EyePieceParameters: Codable {
    public var magnificationFactor: Double?
    public var focalLength: PolisPropertyValue? // [mm]
}
