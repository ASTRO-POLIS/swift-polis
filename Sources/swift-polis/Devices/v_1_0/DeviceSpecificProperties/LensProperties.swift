//
//  LensProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct LensProperties: Codable {

    public enum LensType: String, Codable {
        case convex
        case concave
        case planoConcave
        case planoConvex
        case positiveMeniscus
        case negativeMeniscus
        case other
    }

    public var type: LensType
    public var position: UInt              //TODO: Originally, it was suggested as enum, but perhaps UInt is better?
    public var transmittance: Double       //TODO: Double (0.0 ... 1.0)?
    public var diameter: PolisMeasurement  // [m]
}
