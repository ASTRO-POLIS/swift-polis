//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2022 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import swift_polis

class PolisItemOwnerTests: XCTestCase {

    //MARK: - Initialisation -
    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
    private var data: Data!
    private var string: String!

    override func setUpWithError() throws {
        super.setUp()

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
    }

    override func tearDownWithError() throws {
        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil

        super.tearDown()
    }

    //MARK: - Actual tests -

    // We need this just in case it collides with Swift's `private` keyword.
    func testPrivateOwnershipType() {
        let sut = PolisItemOwner.OwnershipType.private

        XCTAssertNotNil(sut)
    }

    func testPolisItemOwnerCodingSupport() {
        let identity = PolisIdentity(externalReferences: ["1234"],
                                     lifecycleStatus: PolisIdentity.LifecycleStatus.active,
                                     lastUpdate: Date(),
                                     name: "Test identity",
                                     abbreviation: "abc",
                                     automationLabel: "Ascom Label",
                                     shortDescription: "Testing ownership")
        let sut      = PolisItemOwner(identity: identity, type: PolisItemOwner.OwnershipType.club, shortName: "AstroClubBAO")

        XCTAssertNotNil(identity)
        XCTAssertNotNil(sut)

        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisItemOwner.self, from: string!.data(using: .utf8)!))
    }

    //MARK: - Housekeeping -
    static var allTests = [
        ("testPrivateOwnershipType",        testPrivateOwnershipType),
        ("testPolisItemOwnerCodingSupport", testPolisItemOwnerCodingSupport),
    ]
}
