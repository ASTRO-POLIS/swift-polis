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

final class PolisCommonTypesTests: XCTestCase {

    //MARK: - Initialisation -
    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
    private var data: Data!
    private var string: String!

    override func setUp() {
        super.setUp()

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
    }

    override func tearDown() {
        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil

        super.tearDown()
    }

    //MARK: - Actual tests -
    func testPolisIdentificationCodingSupport() {
        let sut = PolisIdentification(references: ["1234", "6539"],
                                      status: PolisIdentification.LifecycleStatus.active,
                                      lastUpdate: Date(),
                                      name: "TestAttributes",
                                      abbreviation: "abc",
                                      automationLabel: "Ascom Label",
                                      shortDescription: "Testing attributes")

        XCTAssertNotNil(sut)

        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisIdentification.self, from: string!.data(using: .utf8)!))
    }

    func testPolisAdminContactCodingSupport() {
        let sut_twitter   = PolisAdminContact.Communication.twitter(username: "@polis")
        let sut_whatsapp  = PolisAdminContact.Communication.whatsApp(phone: "+305482049")
        let sut_facebook  = PolisAdminContact.Communication.facebook(id: "super_astronomers")
        let sut_instagram = PolisAdminContact.Communication.instagram(username: "super_astro")
        let sut_skype     = PolisAdminContact.Communication.skype(id: "super_duper_astro")


        XCTAssertNotNil(sut_twitter)
        XCTAssertNotNil(sut_whatsapp)
        XCTAssertNotNil(sut_facebook)
        XCTAssertNotNil(sut_instagram)
        XCTAssertNotNil(sut_skype)

        data   = try? jsonEncoder.encode(sut_twitter)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAdminContact.Communication.self, from: string!.data(using: .utf8)!))

        data   = try? jsonEncoder.encode(sut_whatsapp)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAdminContact.Communication.self, from: string!.data(using: .utf8)!))

        data   = try? jsonEncoder.encode(sut_facebook)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAdminContact.Communication.self, from: string!.data(using: .utf8)!))

        data   = try? jsonEncoder.encode(sut_instagram)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAdminContact.Communication.self, from: string!.data(using: .utf8)!))

        data   = try? jsonEncoder.encode(sut_skype)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAdminContact.Communication.self, from: string!.data(using: .utf8)!))
    }

    func testPolisDirectionsCodingSupport() {
        let sut_rough = PolisDirection.rough(direction: .southEast)
        let sut_exact = PolisDirection.exact(degree: 16.63)

        XCTAssertNotNil(sut_rough)
        XCTAssertNotNil(sut_exact)

        data   = try? jsonEncoder.encode(sut_rough)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirection.self, from: string!.data(using: .utf8)!))

        data   = try? jsonEncoder.encode(sut_exact)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirection.self, from: string!.data(using: .utf8)!))
    }


    //MARK: - Housekeeping -
    static var allTests = [
        ("testPolisIdentificationCodingSupport", testPolisIdentificationCodingSupport),
        ("testPolisAdminContactCodingSupport",   testPolisAdminContactCodingSupport),
        ("testPolisDirectionsCodingSupport",     testPolisDirectionsCodingSupport),
    ]
}
