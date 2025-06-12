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
    public var position: UInt
    public var transmittance: Double?
    public var diameter: PolisPropertyValue?  // [m]
}
