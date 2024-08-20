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
        case unknown
    }

    public var elementType = ElementType.unknown
    public var groovesPerMillimetre: Int?        //TODO: Originally the suggested type was Int -> manufacturers only do interger amounts per mm on the specifications
    public var material: String?                 //TODO: Why not Enum? Is it optional? -> optional yes, see other material comments
    public var dimensions: [PolisPropertyValue]    //TODO: This does not feel right -> how come not? Having a 2 or 3 element array of measurements with length, height, and width seems fairly reasonable, or am I missing something here? 
}
