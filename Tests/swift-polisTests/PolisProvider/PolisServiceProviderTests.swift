//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
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
import SoftwareEtudesUtilities

@testable import swift_polis
final class PolisServiceProviderTests: XCTestCase {

    //MARK: - Initialisation -
    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
    private var data: Data!
    private var string: String!
    private let jsonDataFromDirectoryEntry = """
{
    "supported_implementations": [
        {
            "api_support": "static_data",
            "version": "0.1.0-alpha.1",
            "data_format": "json"
        }
    ],
    "provider_type": {
        "type": "experimental"
    },
    "url": "www.telescope.observer",
    "id": "6084D02F-A110-43A1-ACB4-93D32A42E605",
    "name": "Telescope Observer",
    "short_description": "The original site",
    "last_update": "2022-02-12T20:59:26Z",
    "reachability_status" : "currentlyUnreachable",
    "contact": {
       "id": "6084D02F-A110-43A1-ACB4-93D32A42E606",
       "email": "polis@tuparev.com",
        "additional_communication_channels": [
            {
                "twitter": {
                    "username": "@TelescopeObserver"
                },
                "communication_type": "twitter"
            }
        ],
        "notes": "The site is experimental, so not need to contact us yet.",
        "name": "TelescopeObserver Admin"
    }
}
"""

    override func setUp() {
        super.setUp()

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
    }

    override func tearDown() {
        jsonEncoder = nil
        jsonDecoder = nil

        data = nil
        string = nil

        super.tearDown()
    }

    //MARK: - Actual tests -
    func testPolisProviderTypeCodingAndDecoding() {
        let sut_pub = PolisDirectory.DirectoryEntry.ProviderType.public
        let sut_mir = PolisDirectory.DirectoryEntry.ProviderType.mirror(id: "abc")

        XCTAssertNotNil(sut_pub)
        XCTAssertNotNil(sut_mir)

        data   = try? jsonEncoder.encode(sut_pub)
        string = String(data: data!, encoding: .utf8)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.DirectoryEntry.ProviderType.self, from: string!.data(using: .utf8)!))

        data   = try? jsonEncoder.encode(sut_mir)
        string = String(data: data!, encoding: .utf8)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.DirectoryEntry.ProviderType.self, from: string!.data(using: .utf8)!))
    }


    func testPolisDirectoryEntryCodingSupport() {
        let sut = try? PolisDirectory.DirectoryEntry(name: "Telescope Observer",
                                           url: "https://polis.net",
                                           providerDescription: "Polis test",
                                           supportedImplementations: [frameworkSupportedImplementation.last!],
                                           providerType: PolisDirectory.DirectoryEntry.ProviderType.experimental,
                                           contact: PolisAdminContact(name: "polis",
                                                                      email: "polis@observer.net",
                                                                      phone: "+3068452820",
                                                                      additionalCommunicationChannels: [PolisAdminContact.Communication.instagram(username: "@polis")],
                                                                      notes: "The admin works only on Sunday")!)

        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.DirectoryEntry.self, from: string!.data(using: .utf8)!))
    }

    func testLoadingPolisDirectoryEntryFromData() {
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.DirectoryEntry.self, from: jsonDataFromDirectoryEntry.data(using: .utf8)!))
    }

    func testPolisDirectoryFromStaticData() {
        let entry   = try? jsonDecoder.decode(PolisDirectory.DirectoryEntry.self, from: jsonDataFromDirectoryEntry.data(using: .utf8)!)
        let entries = [entry!]
        let sut     = PolisDirectory(lastUpdate: Date(), entries: entries)

        XCTAssertNotNil(sut)
    }

    func test_PolisResourceSiteDirectoryResourceReference_coding_shouldSucceed() throws {
        // Given
        let asa_identity = PolisIdentity(name: "ASA")
        let asa          = PolisResourceSiteDirectory.ResourceReference(identity: asa_identity, uniqueName: "asa", deviceTypes: [.mount])

        // When
        let sut = PolisResourceSiteDirectory(lastUpdate: Date(), entries: [asa])

        // Then
        XCTAssertNotNil(sut)

        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisResourceSiteDirectory.self, from: string!.data(using: .utf8)!))
   }

    //MARK: - Housekeeping -
    static var allTests = [
        ("testPolisProviderTypeCodingAndDecoding",                                testPolisProviderTypeCodingAndDecoding),
        ("testPolisDirectoryEntryCodingSupport",                                  testPolisDirectoryEntryCodingSupport),
        ("testLoadingPolisDirectoryEntryFromData",                                testLoadingPolisDirectoryEntryFromData),
        ("testPolisDirectoryFromStaticData",                                      testPolisDirectoryFromStaticData),
        ("test_PolisResourceSiteDirectoryResourceReference_coding_shouldSucceed", test_PolisResourceSiteDirectoryResourceReference_coding_shouldSucceed),
    ]
}
