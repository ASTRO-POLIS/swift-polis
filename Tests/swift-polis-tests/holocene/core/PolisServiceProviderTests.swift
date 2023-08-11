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

@testable import swift_polis

final class PolisServiceProviderTests: XCTestCase {

    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
    private var data: Data!
    private var string: String!
    private let jsonDataFromDirectoryEntry = """
{
    "short_description": "The Big Bank Source",
    "reachability_status": "reachable_and_responsive",
    "id": "090E3F63-EF2A-4123-8518-77D5664EAA01",
    "last_update": "2023-07-22T12:10:06Z",
    "supported_implementations": [
        {
            "api_support": "static_data",
            "version": "0.2.0-alpha.1",
            "data_format": "json"
        }
    ],
    "provider_type": "mirror",
    "mirror_id": "62B5E7C7-4A90-4569-9B13-4AEF324441E4",
    "admin_contact": {
        "id": "4C8C99D5-1E44-4069-B30D-7DE18B76336F",
        "email_address": "polis@observer.net",
        "name": "polis",
        "phone_number": "+3068452820",
        "note": "The admin works only on Sunday"
    },
    "name": "Telescope Observer",
    "url": "https://polis.net"
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

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()

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
                                                             adminContact: PolisAdminContact(name: "polis",
                                                                                             emailAddress: "polis@observer.net",
                                                                                             phoneNumber: "+3068452820",
                                                                                             additionalCommunication: nil,
                                                                                             note: "The admin works only on Sunday")!)

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
                                                                   adminContact: PolisAdminContact(name: "polis",
                                                                                                   emailAddress: "polis@observer.net",
                                                                                                   phoneNumber: "+3068452820",
                                                                                                   additionalCommunication: nil,
                                                                                                   note: "The admin works only on Sunday")!)
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
                                     lifecycleStatus: PolisIdentity.LifecycleStatus.active,
                                     lastUpdate: Date(),
                                     name: "TestAttributes",
                                     abbreviation: "abc",
                                     automationLabel: "Ascom Label",
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
                                 lifecycleStatus: PolisIdentity.LifecycleStatus.active,
                                 lastUpdate: Date(),
                                 name: "TestAttributes",
                                 abbreviation: "abc",
                                 automationLabel: "Ascom Label",
                                 shortDescription: "Testing attributes")
        let i2   = PolisIdentity(externalReferences: ["1234"],
                                 lifecycleStatus: PolisIdentity.LifecycleStatus.suspended,
                                 lastUpdate: Date(),
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
        let identity  = PolisIdentity(lifecycleStatus: PolisIdentity.LifecycleStatus.active,
                                      lastUpdate: Date(),
                                      name: "AstroSystemeAustria",
                                      abbreviation: "ASA",
                                      automationLabel: "asa",
                                      shortDescription: "Austrian major telescope producer")
        let reference = PolisResourceDirectory.ResourceReference(identity: identity, uniqueName: "ASA")
        let sut       = PolisResourceDirectory(lastUpdate: Date(), resourceReferences: [reference])
        
        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisResourceDirectory.self, from: string!.data(using: .utf8)!))
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
