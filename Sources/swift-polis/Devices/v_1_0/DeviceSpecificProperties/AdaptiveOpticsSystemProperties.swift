//
//  AdaptiveOpticsSystemProperties.swift
//  
//
//  Created by Georg Tuparev on 23.06.23.
//

import Foundation

public struct AdaptiveOpticsSystemProperties: Codable {

    public enum GuideStartType: String, Codable {
        case natural
        case artificial
        case other
    }

    public enum AdaptiveOpticsSensorType: String, Codable {
        case shackHartmann = "shack_hartmann"
        case pyramid
        case commonPath    = "common_path"
        case other
    }

    //TODO: Mark optionals?
    public var fieldSizeX: Int //TODO: How it is possible not to have units?
    public var fieldSizeY: Int //TODO: See above
    public var guideStarType = GuideStartType.other
    public var updateRate: Int //TODO: How it is possible not to have units? Rate?
    public var adaptiveOpticsSensorType = AdaptiveOpticsSensorType.other
}
