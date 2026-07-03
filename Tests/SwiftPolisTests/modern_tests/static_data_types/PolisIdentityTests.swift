//
//  PolisIdentityTests.swift
//  swift-polis
//
//  Created by Georg Tuparev on 3.07.26.
//

import Foundation
import SoftwareEtudesUtilities
import Testing

import Foundation
import SoftwareEtudesUtilities
import Testing

@testable import SwiftPolis

struct PolisIdentityTests {

    @Test("Testing simple assignments and computations", .tags(.simpleAssignmentsAndCalculations))
    func simpleAssignment() throws {
        let now      = Date.now
        let identity = PolisIdentity(lastUpdateTime: now, name: ["en" : "Test"], abbreviation: "abc" )
        let byurakan = try PolisIdentitySource.byurakanIdentity()

        #expect(identity.name!.count  == 1)
        #expect(identity.name         == ["en" : "Test"])
        #expect(identity.abbreviation == "abc")
        #expect(byurakan.abbreviation == "bao")
    }

    @Test("Testing JSON Codable", .tags(.jsonCodable))
    func jsonCoding() throws {
        var data: Data!
        let string   = PolisIdentitySource.identityFoByurakanObservatoryStringTemplate
        let byurakan = try PolisIdentitySource.byurakanIdentity()

        data = string.data(using: .utf8)!

        let newIdentity = try jsonDecoder.decode(PolisIdentity.self, from: data)

        #expect(newIdentity.id           == byurakan.id)
        #expect(newIdentity.abbreviation == byurakan.abbreviation)
    }

    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!

    init() {
        jsonEncoder = PrettyJSONEncoder()
        jsonDecoder = PrettyJSONDecoder()
    }

}
