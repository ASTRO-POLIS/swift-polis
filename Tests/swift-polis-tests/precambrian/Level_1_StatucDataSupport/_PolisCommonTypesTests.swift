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

final class _PolisCommonTypesTests: XCTestCase {

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

    //MARK: Communication related types

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

    func testPolisContactCodingSupport() {
        let c = PolisAdminContact(name: "polis",
                                  email: "polis@observer.net",
                                  phone: nil,
                                  additionalCommunicationChannels: [PolisAdminContact.Communication.instagram(username: "@polis")],
                                  notes: nil)

        data   = try? jsonEncoder.encode(c)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAdminContact.self, from: string!.data(using: .utf8)!))
    }


    //MARK: - Housekeeping -
    static var allTests = [
        ("testPolisAdminContactCodingSupport", testPolisAdminContactCodingSupport),
        ("testPolisContactCodingSupport",      testPolisContactCodingSupport),
    ]
}
