//
//  AdaptiveOpticsSystemProperties.swift
//  
//
//  Created by Georg Tuparev on 23.06.23.
//

import Foundation

public struct AdaptiveOpticsSystemProperties: Codable {

    public enum GuideStarType: String, Codable {
        case natural
        case artificial
    }

    public enum AdaptiveOpticsSensorType: String, Codable {
        case shackHartmann = "shack_hartmann"
        case pyramid
        case commonPath    = "common_path"
        case other
    }

    public var fieldSizeX: PolisPropertyValue? // [degree]
    public var fieldSizeY: PolisPropertyValue? // [degree]
    public var guideStarType = GuideStarType.natural
    public var updateRate: PolisPropertyValue? // [s^-1]
    public var adaptiveOpticsSensorType = AdaptiveOpticsSensorType.other
}
