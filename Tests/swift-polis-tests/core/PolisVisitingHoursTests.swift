//===----------------------------------------------------------------------===//
//  PolisVisitingHoursTests.swift
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

import XCTest
import SoftwareEtudesUtilities

@testable import swift_polis

final class PolisVisitingHoursTests: XCTestCase {

    //MARK: - Setup & Teardown -
    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!
    private var data: Data!
    private var string: String!


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

    //MARK: - Tests -
    func test_PolisVisitingHours_creation_shouldSucceed() throws {
        // Given
        let aNote = "A very interesting note"
        let sut   = PolisVisitingHours(note: aNote)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.note!, aNote)
    }

    func test_PolisVisitingHours_codingSupport_shouldSucceed() throws {
        // Given
        let aNote = "A very interesting note"
        let sut   =  PolisVisitingHours(note: aNote)

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisVisitingHours.self, from: data))
        XCTAssertNoThrow(try jsonDecoder.decode(PolisVisitingHours.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisVisitingHours_onlyNote_shouldSucceed() throws {
        // Given
        let sut = try? jsonDecoder.decode(PolisVisitingHours.self, from: TestingSupport.onlyANoteVisitingHours)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut!.note)
    }

    func test_PolisVisitingHours_simpleVisitingPossibility_shouldSucceed() throws {
        // Given
        let sut = try? jsonDecoder.decode(PolisVisitingHours.self, from: TestingSupport.everyYearEveryMonthEverySundayVisitingHours)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut!.visitingPossibilities?.count, 1)
        XCTAssertTrue(sut!.visitingPossibilities![0].applicableWeekdays![0] == PolisVisitingHours.VisitingPossibility.DayOfTheWeek.sunday)
    }

    func test_PolisVisitingHours_complexVisitingHours_shouldSucceed() throws {
        // Given
        let sut = try? jsonDecoder.decode(PolisVisitingHours.self, from: TestingSupport.complexVisitingHoursVisitingHours)

        // When

        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut!.visitingPossibilities?.count, 2)
        XCTAssertEqual(sut!.visitingPossibilities?[1].applicableYears?.count, 2)
        XCTAssertEqual(sut!.visitingPossibilities?[1].applicableMonths?.count, 3)
        XCTAssertEqual(sut!.visitingPossibilities?[1].applicableWeekdays?.count, 1)
    }

    static var allTests = [
        ("test_PolisVisitingHours_creation_shouldSucceed",                  test_PolisVisitingHours_creation_shouldSucceed),
        ("test_PolisVisitingHours_creation_shouldSucceed",                  test_PolisVisitingHours_creation_shouldSucceed),
        ("test_PolisVisitingHours_onlyNote_shouldSucceed",                  test_PolisVisitingHours_onlyNote_shouldSucceed),
        ("test_PolisVisitingHours_simpleVisitingPossibility_shouldSucceed", test_PolisVisitingHours_simpleVisitingPossibility_shouldSucceed),
        ("test_PolisVisitingHours_complexVisitingHours_shouldSucceed",      test_PolisVisitingHours_complexVisitingHours_shouldSucceed),
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

