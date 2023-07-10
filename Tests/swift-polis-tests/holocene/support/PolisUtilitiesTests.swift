//===----------------------------------------------------------------------===//
//  PolisUtilitiesTests.swift
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

final class PolisUtilitiesTests: XCTestCase {

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
    }

    override func tearDownWithError() throws {
        print("In tearDown.")
        try super.tearDownWithError()
    }

    //MARK: - Tests -
    func test_PolisUtilities_mustStartWithAtSignExtension_shouldSucceed() throws {
        XCTAssertEqual("@bla", "bla".mustStartWithAtSign())
        XCTAssertEqual("@bla", "@bla".mustStartWithAtSign())
    }

    func test_PolisUtilities_normalisedPath_shouldSucceed() throws {
        XCTAssertEqual("/a/b/c/", "/a/b/c".normalisedPath())
        XCTAssertEqual("/a/b/c/", "/a/b/c/".normalisedPath())
    }

    static var allTests = [
        ("test_PolisUtilities_mustStartWithAtSignExtension_shouldSucceed", test_PolisUtilities_mustStartWithAtSignExtension_shouldSucceed),
        ("test_PolisUtilities_normalisedPath_shouldSucceed",               test_PolisUtilities_normalisedPath_shouldSucceed),
    ]


    //MARK: - Templates
    /*
     func test_Type_stateUnderTest_expectedBehavior() throws {
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
 [UnitOfWork_StateUnderTest_ExpectedBehavior].

 If you follow that precisely it would create test method names like this:
 test_Hater_AfterHavingAGoodDay_ShouldNotBeHating().

 *Note:* Mixing PascalCase and snake_case might hurt your head at first, but at least it makes clear the
 UnitOfWork – StateUnderTest – ExpectedBehavior
 separation at a glance. You might also see camelCase being used, which would give
 test_Hater_afterHavingAGoodDay_shouldNotBeHating()
 */
