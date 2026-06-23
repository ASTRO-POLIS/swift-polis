//
//  JSONBasedTestExamples.swift
//  swift-polis
//
//  Created by Georg Tuparev on 23/06/2026.
//

import Foundation
import SoftwareEtudesUtilities

@testable import SwiftPolis

struct JSONBasedTestExamples {

    //MARK: Static JSON data

    // Polis Directions
    static let exactNorthJSONDirection = """
{
   "exact_direction" : 0.0
}
"""

    static let roughSouthSouthwestJSONDirection = """
{
   "rough_direction" : "SSW"
}
"""

    //MARK: Static methods

    // Polis Directions
    static func exactNorthDirectionFromString() -> PolisDirection {
        let data     = exactNorthJSONDirection.data(using: .utf8)!
        let instance = try! JSONDecoder().decode(PolisDirection.self, from: data)

        return instance
    }

    static func roughSouthSouthwestDirectionFromString() -> PolisDirection {
        let data     = roughSouthSouthwestJSONDirection.data(using: .utf8)!
        let instance = try! JSONDecoder().decode(PolisDirection.self, from: data)

        return instance
    }

}
