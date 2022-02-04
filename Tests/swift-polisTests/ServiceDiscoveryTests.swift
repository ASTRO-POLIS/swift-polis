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
import SoftwareEtudes

@testable import swift_polis
final class ServiceDiscoveryTests: XCTestCase {

    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
    private var data: Data!
    private var string: String!

    func testPolisContact() {
        let c = PolisAdminContact(name: "polis",
                                  email: "polis@observer.net",
                                  mobilePhone: nil,
                                  additionalCommunicationChannels: [PolisCommunication.instagram(username: "@polis")],
                                  notes: nil)

        data   = try? jsonEncoder.encode(c)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAdminContact.self, from: string!.data(using: .utf8)!))
    }

    func testPolisDirectoryEntry() {
        let pd = try? PolisDirectoryEntry(attributes: PolisItemAttributes(name: "polis"),
                                     url: "https://polis.net",
                                     providerDescription: "Polis test",
                                     supportedImplementations: [frameworkSupportedImplementation.last!],
                                     providerType: PolisProviderType.experimental,
                                     contact: PolisAdminContact(name: "polis",
                                                                email: "polis@observer.net",
                                                                mobilePhone: nil,
                                                                additionalCommunicationChannels: [PolisCommunication.instagram(username: "@polis")],
                                                                notes: "The admin works only on Sunday")!)

        data   = try? jsonEncoder.encode(pd)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectoryEntry.self, from: string!.data(using: .utf8)!))
    }

    override func setUp() {
        super.setUp()

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
    }

    override func tearDown() {
        data = nil
        string = nil
        jsonEncoder = nil
        jsonDecoder = nil

        super.tearDown()
    }

    static var allTests = [
        ("testPolisContact", testPolisContact),
        ("testPolisDirectoryEntry", testPolisDirectoryEntry),
    ]
}
