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

    //MARK: Test dada

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
                                                             supportedImplementations: [PolisConstants().latestPolisFrameworkSupportedImplementation()],
                                                             providerType: .mirror,
                                                             contact: StaticDataTypeTestingSupport.examplePerson())

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.ProviderDirectoryEntry.self, from: string!.data(using: .utf8)!))
    }

    func test_DirectoryEntry_loadingPolisDirectoryEntryFromData_shouldSucceed() throws {
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.ProviderDirectoryEntry.self, from: ServiceProviderDataSource.exampleServiceProviderTemplate.data(using: .utf8)!))
   }

    func test_PolisDirectory_codingSupport_shouldSucceed() throws {
        // Given
        let sut_entry = try? PolisDirectory.ProviderDirectoryEntry(mirrorID: UUID(),
                                                                   reachabilityStatus: .reachableAndResponsive,
                                                                   name: "Telescope Observer",
                                                                   shortDescription: "The Big Bank Source",
                                                                   url: "https://polis.net",
                                                                   supportedImplementations: [PolisConstants().latestPolisFrameworkSupportedImplementation()],
                                                                   providerType: .mirror,
                                                                   contact: StaticDataTypeTestingSupport.examplePerson())
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
                                     lastUpdateTime: Date(),
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
                                 lastUpdateTime: Date(),
                                 name: "TestAttributes",
                                 abbreviation: "abc",
                                 shortDescription: "Testing attributes")
        let i2   = PolisIdentity(externalReferences: ["1234"],
                                 lastUpdateTime: Date(),
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

    func test_PolisResourceDirectory_codingSupport_shouldSucceed() throws {
        // Given
        let identity  = PolisIdentity(lastUpdateTime: Date(),
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

    static let allTests = [
        ("test_ProviderDirectoryEntry_codingSupport_shouldSucceed",              test_ProviderDirectoryEntry_codingSupport_shouldSucceed),
        ("test_DirectoryEntry_loadingPolisDirectoryEntryFromData_shouldSucceed", test_DirectoryEntry_loadingPolisDirectoryEntryFromData_shouldSucceed),
        ("test_PolisDirectory_codingSupport_shouldSucceed",                      test_PolisDirectory_codingSupport_shouldSucceed),
        ("test_ObservingFacilityReference_codingSupport_shouldSucceed",          test_ObservingFacilityReference_codingSupport_shouldSucceed),
        ("test_PolisObservingFacilityDirectory_codingSupport_shouldSucceed",     test_PolisObservingFacilityDirectory_codingSupport_shouldSucceed),
        ("test_PolisResourceDirectory_codingSupport_shouldSucceed",              test_PolisResourceDirectory_codingSupport_shouldSucceed),
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
