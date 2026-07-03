//===----------------------------------------------------------------------===//
//  PolisDirectionTests.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2026 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//

import Foundation
import SoftwareEtudesUtilities
import Testing

@testable import SwiftPolis

struct PolisDirectionTests {

    @Test("Testing exact direction algorithms", .tags(.simpleAssignmentsAndCalculations))
    func simpleExactDirections() {
        let inRange   = PolisDirection(exactDirection: 17.3)
        let negative  = PolisDirection(exactDirection: 135.0)
        let tooLarge  = PolisDirection(exactDirection: 370.0)
        let southWest = PolisDirection(roughDirection: .southWest)

        #expect(inRange.direction()   == 17.3)
        #expect(negative.direction()  == 135.0)
        #expect(tooLarge.direction()  == 10.0)
        #expect(southWest.direction() == 225.0)
    }

    @Test("Testing exact rough algorithms", .tags(.simpleAssignmentsAndCalculations))
    func simpleRoughDirections() {
        let zero           = PolisDirection(roughDirection: .north)
        let ninety         = PolisDirection(roughDirection: .east)
        let southEast      = PolisDirection(roughDirection: .southEast)
        let south          = PolisDirection(roughDirection: .south)
        let southSouthWest = PolisDirection(roughDirection: .southSouthWest)
        let southSouthEast = PolisDirection(exactDirection: 157)
        let eastNorthEast  = PolisDirection(exactDirection: 45)

        #expect(zero.direction()           == 0.0)
        #expect(ninety.direction()         == 90.0)
        #expect(southEast.direction()      == 135.0)
        #expect(south.direction()          == 180.0)
        #expect(southSouthWest.direction() == 202.5)

        #expect(zero.roughDirection?.rawValue == "N")
        #expect(southSouthWest.roughDirection?.rawValue == "SSW")

        #expect(southSouthWest.roughDirection?.abbreviation() == "S/SW")

        #expect(southSouthEast.nearestRoughDirection() == .southSouthEast)
        #expect(eastNorthEast.nearestRoughDirection()  == .eastNorthEast)

        #expect(ninety.nearestRoughDirection() == .east)
    }

    @Test("Testing JSON Codable", .tags(.jsonCodable))
    func jsonCoding() throws {
        var data: Data!
        var string: String!

        let zero           = PolisDirection(exactDirection: 0.1)
        let southSouthWest = PolisDirection(roughDirection: .southSouthWest)

        
        data = try jsonEncoder.encode(zero)
        string  = String(data: data, encoding: .utf8)

        #expect(string.removeAllWhitespacesAndNewLines() == PolisDirectionDataSource.almostNorthTemplate.removeAllWhitespacesAndNewLines())

        data = try jsonEncoder.encode(southSouthWest)
        string  = String(data: data, encoding: .utf8)

        #expect(string.removeAllWhitespacesAndNewLines() == PolisDirectionDataSource.roughSouthSouthWestTemplate.removeAllWhitespacesAndNewLines())
    }

    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!
    private var data: Data!
    private var string: String!

    init() {
        jsonEncoder = PrettyJSONEncoder()
        jsonDecoder = PrettyJSONDecoder()
    }
}

