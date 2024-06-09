//===----------------------------------------------------------------------===//
//  PolisIdentityTests.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2024 Tuparev Technologies and the ASTRO-POLIS project
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

import XCTest

@testable import swift_polis

final class PolisIdentityTests: XCTestCase {

    //MARK: - Setup & Teardown -
    override class func setUp() {
        print("In class setUp.")
    }

    override class func tearDown() {
        print("In class tearDown.")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        print("In setUp.")
    
        jsonEncoder = PrettyJSONEncoder()
        jsonDecoder = PrettyJSONDecoder()
}

    override func tearDownWithError() throws {
        print("In tearDown.")
        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil

        try super.tearDownWithError()
    }

    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!
    private var data: Data!
    private var string: String!


    //MARK: - Tests -
    func test_PolisIdentity_codingSupport_shouldSucceed() throws {
        // Given
        let sut = TestingSupport.examplePolisIdentityBAO()

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisIdentity.self, from: string!.data(using: .utf8)!))
    }

    static var allTests = [
        ("test_PolisIdentity_codingSupport_shouldSucceed", test_PolisIdentity_codingSupport_shouldSucceed),
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

