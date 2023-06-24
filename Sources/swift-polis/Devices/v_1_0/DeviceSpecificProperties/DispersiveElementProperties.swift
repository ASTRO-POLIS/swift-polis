//
//  DispersiveElementProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct DispersiveElementProperties: Codable {

    public enum ElementType: String, Codable {
        case prism
        case grating
        case grism
        case etalon
        case other
    }

    public var elementType = ElementType.other
    public var groovesPerMillimetre: Double      //TODO: Originally the suggested type was Int
    public var material: String?                 //TODO: Why not Enum? Is it optional?
    public var dimensions: [PolisMeasurement]    //TODO: This does not feel right
}
