//
//  PolisTestExamples.swift
//  swift-polis
//
//  Created by Georg Tuparev on 23/06/2026.
//

import Foundation
import SoftwareEtudesUtilities

@testable import SwiftPolis

struct PolisTestExamples {

    //MARK: Polis Directions
    static func exactNorthDirection() -> PolisDirection          { PolisDirection(exactDirection: 0.0) }
    static func roughSouthSouthwestDirection() -> PolisDirection { PolisDirection(roughDirection: .southSouthWest) }

}
