//
//  DimmProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct DimmProperties: Codable {
    public var updateRate: PolisPropertyValue?         // [s^-1]
    public var apertureSeparation: PolisPropertyValue? // [m]
}