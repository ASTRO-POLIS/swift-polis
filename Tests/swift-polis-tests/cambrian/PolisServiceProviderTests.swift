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
    func test_ProviderType_codingSupport_shouldSucceed() throws {
        // Given
        let sut = try? PolisDirectory.DirectoryEntry(mirrorID: UUID(),
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
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.DirectoryEntry.self, from: string!.data(using: .utf8)!))

    }
    static var allTests = [
        ("test_ProviderType_codingSupport_shouldSucceed", test_ProviderType_codingSupport_shouldSucceed),
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
