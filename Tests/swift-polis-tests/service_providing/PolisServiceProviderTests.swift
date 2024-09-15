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

    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!
    private var data: Data!
    private var string: String!
    private let jsonDataFromDirectoryEntry = """
{
    "id": "090E3F63-EF2A-4123-8518-77D5664EAA01",
    "mirror_id": "62B5E7C7-4A90-4569-9B13-4AEF324441E4",
    "reachability_status": "reachable_and_responsive",
    "name": "Telescope Observer",
    "short_description": "The Big Bank Source",
    "last_update": "2023-07-22T12:10:06Z",
    "url": "https://polis.net",
    "supported_implementations": [
        {
            "api_support": "static_data",
            "version": "0.2.0-alpha.1",
            "data_format": "json"
        }
    ],
    "provider_type": "mirror",
    "admin_contact": {
        "name": "Amon Ra",
        "email": "ra@god.cun",
        "communication": {
            "skype_ids": [
                "cool_astro"
            ],
            "instagram_ids": [
                "GalaxyFarAway"
            ],
            "twitter_ids": [
                "@CoolAstro",
                "@GalaxyFarAway"
            ],
            "whatsapp_phone_numbers": [
                "+1 900 1234567"
            ],
            "mastodon_ids": [
                "@GalaxyFarAway@mastodon.social"
            ],
            "facebook_ids": [
                "916735592641"
            ]
        },
        "address": {
            "state": "Comet",
            "po_box": "4242",
            "place": "Sun hill",
            "zip_code": "ST1234",
            "country_id": "AM",
            "district": "Stars",
            "street_line_4": "4",
            "note": "Send only stars and love",
            "street_line_1": "1",
            "street": "Observatory str.",
            "street_line_3": "3",
            "attention_off": "Mrs. Royal Astronomer",
            "house_name": "Galaxy.",
            "house_number_suffix": "a",
            "poste_restante": "The Observing Man",
            "po_box_zip": "ST1256",
            "apartment": "24",
            "block": "43",
            "street_line_2": "2",
            "street_line_5": "5",
            "floor": 1,
            "longitude": 11.07,
            "region": "Milky way",
            "house_number": 42,
            "latitude": 41.24,
            "province": "Star cluster",
            "street_line_6": "6"
        }
    }
}
"""

    //MARK: - Setup & Teardown -

    override class func setUp() {
        print("In class setUp.")
    }

    override class func tearDown() {
        print("In class tearDown.")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        jsonEncoder = PrettyJSONEncoder()
        jsonDecoder = PrettyJSONDecoder()

        print("In setUp.")
    }

    override func tearDownWithError() throws {
        print("In tearDown.")
        
        jsonEncoder = nil
        jsonDecoder = nil

        data = nil
        string = nil

        try super.tearDownWithError()
    }

    //MARK: - Tests -
    func test_ProviderDirectoryEntry_codingSupport_shouldSucceed() throws {
        // Given
        let sut = try? PolisDirectory.ProviderDirectoryEntry(mirrorID: UUID(),
                                                             reachabilityStatus: .reachableAndResponsive,
                                                             name: "Telescope Observer",
                                                             shortDescription: "The Big Bank Source",
                                                             url: "https://polis.net",
                                                             supportedImplementations: [PolisConstants.frameworkSupportedImplementation.last!],
                                                             providerType: .mirror,
                                                             adminContact: TestingSupport.examplePerson())

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.ProviderDirectoryEntry.self, from: string!.data(using: .utf8)!))
    }

    func test_DirectoryEntry_loadingPolisDirectoryEntryFromData_shouldSucceed() throws {
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.ProviderDirectoryEntry.self, from: jsonDataFromDirectoryEntry.data(using: .utf8)!))
   }

    func test_PolisDirectory_codingSupport_shouldSucceed() throws {
        // Given
        let sut_entry = try? PolisDirectory.ProviderDirectoryEntry(mirrorID: UUID(),
                                                                   reachabilityStatus: .reachableAndResponsive,
                                                                   name: "Telescope Observer",
                                                                   shortDescription: "The Big Bank Source",
                                                                   url: "https://polis.net",
                                                                   supportedImplementations: [PolisConstants.frameworkSupportedImplementation.last!],
                                                                   providerType: .mirror,
                                                                   adminContact: TestingSupport.examplePerson())
        let sut       = PolisDirectory(providerDirectoryEntries: [sut_entry!])

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.self, from: string!.data(using: .utf8)!))
    }

    func test_ObservingFacilityReference_codingSupport_shouldSucceed() throws {
        // Given
        let identity = PolisIdentity(externalReferences: ["1234", "6539"],
                                     lastUpdateDate: Date(),
                                     name: "TestAttributes",
                                     abbreviation: "abc",
                                     shortDescription: "Testing attributes")
        let sut      = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisObservingFacilityDirectory.ObservingFacilityReference.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisObservingFacilityDirectory_codingSupport_shouldSucceed() throws {
        // Given
        let i1   = PolisIdentity(externalReferences: ["1234", "6539"],
                                 lastUpdateDate: Date(),
                                 name: "TestAttributes",
                                 abbreviation: "abc",
                                 shortDescription: "Testing attributes")
        let i2   = PolisIdentity(externalReferences: ["1234"],
                                 lastUpdateDate: Date(),
                                 name: "OldStuff",
                                 abbreviation: "old",
                                 shortDescription: "Very old junk")
        let osd1 = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: i1)
        let osd2 = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: i2)
        let sut  = PolisObservingFacilityDirectory(lastUpdate: Date(), observingFacilityReferences: [osd1, osd2])

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisObservingFacilityDirectory.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisResourceFacilityDirectory_codingSupport_shouldSucceed() throws {
        // Given
        let identity  = PolisIdentity(lastUpdateDate: Date(),
                                      name: "AstroSystemeAustria",
                                      abbreviation: "ASA",
                                      shortDescription: "Austrian major telescope producer")
        //TODO: Reimplement!
//        let reference = PolisResourceDirectory.ResourceReference(identity: identity, uniqueName: "ASA")
//        let sut       = PolisResourceDirectory(lastUpdate: Date(), resourceReferences: [reference])
        
        // When
//        data   = try? jsonEncoder.encode(sut)
//        string = String(data: data!, encoding: .utf8)

        // Then
//        XCTAssertNoThrow(try jsonDecoder.decode(PolisResourceDirectory.self, from: string!.data(using: .utf8)!))
    }

    static var allTests = [
        ("test_ProviderDirectoryEntry_codingSupport_shouldSucceed",              test_ProviderDirectoryEntry_codingSupport_shouldSucceed),
        ("test_DirectoryEntry_loadingPolisDirectoryEntryFromData_shouldSucceed", test_DirectoryEntry_loadingPolisDirectoryEntryFromData_shouldSucceed),
        ("test_PolisDirectory_codingSupport_shouldSucceed",                      test_PolisDirectory_codingSupport_shouldSucceed),
        ("test_ObservingFacilityReference_codingSupport_shouldSucceed",          test_ObservingFacilityReference_codingSupport_shouldSucceed),
        ("test_PolisObservingFacilityDirectory_codingSupport_shouldSucceed",     test_PolisObservingFacilityDirectory_codingSupport_shouldSucceed),
        ("test_PolisResourceFacilityDirectory_codingSupport_shouldSucceed",      test_PolisResourceFacilityDirectory_codingSupport_shouldSucceed),
        ("test_PolisResourceFacilityDirectory_codingSupport_shouldSucceed",      test_PolisResourceFacilityDirectory_codingSupport_shouldSucceed),
    ]

    //MARK: - Templates
    /*
     func test_Type_stateUnderTest_expectedBehaviour() throws {
     // Given

     // When

     // Then
     }

     func testExampleWithTearDown() throws {
     print("Starting test.")
     addTeardownBlock {
     print("In first tearDown block.")

     }

     print("In middle of test.")
     addTeardownBlock {
     print("In second tearDown block.")
     }
     print("Finishing test.")
     }

     func testPerformanceExample() throws {
     self.measure {
     }
     }
     */
}



/* NAMING RULES

 As your skill with testing increases, you might find it useful to adopt Roy Osherove’s naming convention for tests:

 [UnitOfWork_StateUnderTest_ExpectedBehaviour].



 If you follow that precisely it would create test method names like this:

 test_Hater_AfterHavingAGoodDay_ShouldNotBeHating().



 *Note:* Mixing PascalCase and snake_case might hurt your head at first, but at least it makes clear the

 UnitOfWork – StateUnderTest – ExpectedBehaviour

 separation at a glance. You might also see camelCase being used, which would give

 test_Hater_afterHavingAGoodDay_shouldNotBeHating()

 */
