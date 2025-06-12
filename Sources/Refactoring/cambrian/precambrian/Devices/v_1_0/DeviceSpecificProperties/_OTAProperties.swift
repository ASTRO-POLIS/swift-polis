//
//  OTAProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct OTAProperties: Codable {

    public enum OTAType: String, Codable {
        case tube
        case frame
        case other
    }

    public enum OpticalDesign: String, Codable {
        case newtonian
        case cassegrain
        case ritcheyChretien = "ritchey_chretien"
        case gregorian
        case maksutov
        case schmidt
        case wolter
        case other
    }

    public var type                = OTAType.other
    public var opticalDesign       = OpticalDesign.other
    public var numberOfFocii: UInt = 1
}

