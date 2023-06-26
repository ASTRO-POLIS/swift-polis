//
//  MountProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct MountProperties: Codable {

    public enum MountType: String, Codable {
        case equatorial
        case altAzimuthal = "alt_azimuthal"
        case zenith
        case fixed
        case other
    }

    public enum DesignType: String, Codable {
        case yoke
        case german
        case horseshoe
        case fork
        case other
    }

    public var type: MountType
    public var design: DesignType?
    public var maximumSlewingSpeed: PolisMeasurement? // [deg s^-1]
}
