//
//  PolisGlobalTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 2.11.25.
//

import Foundation
import SoftwareEtudesUtilities

let __localResources = LocalResources()

struct LocalResources : Sendable{
    let jsonEncoder: PrettyJSONEncoder
    let jsonDecoder: PrettyJSONDecoder

    init() {
        self.jsonEncoder = PrettyJSONEncoder()
        self.jsonDecoder = PrettyJSONDecoder()
    }
}
