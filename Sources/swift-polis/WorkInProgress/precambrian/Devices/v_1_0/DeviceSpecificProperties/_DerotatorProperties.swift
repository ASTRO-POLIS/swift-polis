//
//  DerotatorProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct DerotatorProperties: Codable {

    public enum CableRewindingMode: String, Codable {
        case manual
        case automatic
        case unknown
    }

    public var CableRewindingMode = CableRewindingMode.unknown
}
