//
//  WavePlateProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct WavePlateProperties: Codable {

    public enum PolarisationType: String, Codable {
        case halfWave    = "half_wave"
        case quarterWave = "quarter_wave"
        case other
    }

    public var polarisation = PolarisationType.other
}
