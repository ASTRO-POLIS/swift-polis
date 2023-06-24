//
//  AutoguiderProperties.swift
//  
//
//  Created by Georg Tuparev on 23.06.23.
//

import Foundation

public struct AutoguiderProperties: Codable {

    public enum Mode: String, Codable {
        case singleStar = "single_star"
        case multiStar  = "multi_star"
        case mlpt
        case other
    }

    public var modes = [Mode]()
    public var hasSecondaryCamera: Bool?
}
