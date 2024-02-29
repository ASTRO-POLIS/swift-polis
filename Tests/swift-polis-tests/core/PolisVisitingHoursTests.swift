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

@testable import swift_polis

final class PolisVisitingHoursTests: XCTestCase {

    //MARK: - Setup & Teardown -
    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
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

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
 }

    override func tearDownWithError() throws {
        print("In tearDown.")

        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil

        try super.tearDownWithError()
    }

    // JSON Examples
    private let onlyANote = """
{
   "only_group_visits": false,
   "note": "For group and individual visits, please call the observatory office every working day between 14:00h and 16:00h."
}
""".data(using: .utf8)!

    private let everyYearEveryMonthEverySunday = """
{
   "visiting_possibilities": [
      {
         "applicable_weekdays": ["Sunday"],
         "only_group_visits": true,
         "is_repeating": true
      },
   ],
   "note": "Please call before visiting."
}
""".data(using: .utf8)!

    // In 2024 and 2025, between July and September, every Saturday between 14:00 and 16:00 (only for groups), and every Sunday between
    // 9:00 and 12:00 and between 14:00 and 17:00.
    private let complexOpeningHours = """
{
   "visiting_possibilities": [
      {
         "applicable_years": [2024, 2025],
         "applicable_months": [7, 8, 9],
         "applicable_weekdays": ["Saturday"],
         "opening_period": [ { "from": "14:00", "to": "16:00" } ],
         "only_group_visits": true,
         "is_repeating": true
      },
      {
         "applicable_years": [2024, 2025],
         "applicable_months": [7, 8, 9],
         "applicable_weekdays": ["Sunday"],
         "opening_period": [ { "from": "09:00", "to": "12:00" }, { "from": "14:00", "to": "16:00" } ],
         "only_group_visits": false,
         "is_repeating": true
      }
   ],
   "note": "By or after heavy rain, the road to the observatory could be closed. Check the weather forcast before planning your visit."
}
""".data(using: .utf8)!

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
        let sut = try? jsonDecoder.decode(PolisVisitingHours.self, from: onlyANote)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut!.note)
    }

    func test_PolisVisitingHours_simpleVisitingPossibility_shouldSucceed() throws {
        // Given
        let sut = try? jsonDecoder.decode(PolisVisitingHours.self, from: everyYearEveryMonthEverySunday)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut!.visitingPossibilities?.count, 1)
        XCTAssertTrue(sut!.visitingPossibilities![0].applicableWeekdays![0] == PolisVisitingHours.VisitingPossibility.DayOfTheWeek.sunday)
    }

    func test_PolisVisitingHours_complexOpeningHours_shouldSucceed() throws {
        // Given
        let sut = try? jsonDecoder.decode(PolisVisitingHours.self, from: complexOpeningHours)

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
        ("test_PolisVisitingHours_complexOpeningHours_shouldSucceed",       test_PolisVisitingHours_complexOpeningHours_shouldSucceed),
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

