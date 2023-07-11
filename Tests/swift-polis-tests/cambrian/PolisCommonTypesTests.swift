//
//  PolisCommonTypesTests.swift
//  
//
//  Created by Georg Tuparev on 29.06.23.
//

import XCTest

@testable import swift_polis

final class PolisCommonTypesTests: XCTestCase {

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

    //MARK: - Tests -

    //MARK: - PolisOpeningTimesForVisitors tests
    func test_PolisVisitingHours_creation_shouldSucceed() throws {
        // Given
        let aNote = "A very interesting note"
        let sut = PolisVisitingHours(note: aNote)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.note!, aNote)
    }

    func test_PolisVisitingHours_codingSupport_shouldSucceed() throws {
        // Given
        let aNote = "A very interesting note"
        let sut =  PolisVisitingHours(note: aNote)

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisVisitingHours.self, from: data))
        XCTAssertNoThrow(try jsonDecoder.decode(PolisVisitingHours.self, from: string!.data(using: .utf8)!))
    }

    //MARK: - PolisPropertyValue tests -
    func test_PolisPropertyValue_codingSupport_shouldSucceed() throws {
        // Given
        let sut = PolisPropertyValue(valueKind: .double, value: "123.4", unit: "m")

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisPropertyValue.self, from: data))
        XCTAssertNoThrow(try jsonDecoder.decode(PolisPropertyValue.self, from: string!.data(using: .utf8)!))
   }

    func test_PolisPropertyValue_equatable_shouldSucceed() throws {
        // Given
        let sut_string = PolisPropertyValue(valueKind: .string, value: "NW",    unit: "direction")
        let sut_int    = PolisPropertyValue(valueKind: .int,    value: "17",    unit: "m")
        let sut_float  = PolisPropertyValue(valueKind: .float,  value: "123.4", unit: "m")
        let sut_double = PolisPropertyValue(valueKind: .double, value: "123.4", unit: "m")

        // Then
        XCTAssertNotNil(sut_string)
        XCTAssertNotNil(sut_int)
        XCTAssertNotNil(sut_float)
        XCTAssertNotNil(sut_double)

        XCTAssertEqual(sut_string.stringValue(), "NW")
        XCTAssertEqual(sut_string.unit, "direction")

        XCTAssertEqual(sut_int.intValue(), 17)
        XCTAssertEqual(sut_float.floatValue(), Float(123.4))
        XCTAssertEqual(sut_double.doubleValue(), Double(123.4))
    }

    //MARK: Directions
    func test_PolisDirection_exactCodingSupport_shouldSucceed() throws {
        // Given
        let sut_exact = try PolisDirection(exactDirection: 16.63)

        // When
        data   = try? jsonEncoder.encode(sut_exact)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(sut_exact)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirection.self, from: data))
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirection.self, from: string!.data(using: .utf8)!))
   }

    func test_PolisDirection_roughCodingSupport_shouldSucceed() throws {
        // Given
        let sut_rough = try PolisDirection(roughDirection: PolisDirection.RoughDirection.eastNorthEast)

        // When
        data   = try? jsonEncoder.encode(sut_rough)
        string = String(data: data!, encoding: .utf8)


        // Then
        XCTAssertNotNil(sut_rough)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirection.self, from: data))
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirection.self, from: string!.data(using: .utf8)!))
  }

    func test_PolisDirection_calculations_shouldSucceed() throws {
        // Given
        let sut_exact = try PolisDirection(exactDirection: 16.63)
        let sut_rough = try PolisDirection(roughDirection: PolisDirection.RoughDirection.eastNorthEast)

        // Then
        XCTAssertEqual(sut_exact.direction(), 16.63)
        XCTAssertEqual(sut_rough.direction(), 67.5)
  }

    static var allTests = [
        ("test_PolisVisitingHours_creation_shouldSucceed",       test_PolisVisitingHours_creation_shouldSucceed),
        ("test_PolisVisitingHours_creation_shouldSucceed",       test_PolisVisitingHours_creation_shouldSucceed),
        ("test_PolisPropertyValue_codingSupport_shouldSucceed",  test_PolisPropertyValue_codingSupport_shouldSucceed),
        ("test_PolisPropertyValue_equatable_shouldSucceed",      test_PolisPropertyValue_equatable_shouldSucceed),
        ("test_PolisDirection_exactCodingSupport_shouldSucceed", test_PolisDirection_exactCodingSupport_shouldSucceed),
        ("test_PolisDirection_roughCodingSupport_shouldSucceed", test_PolisDirection_roughCodingSupport_shouldSucceed),
        ("test_PolisDirection_calculations_shouldSucceed",       test_PolisDirection_calculations_shouldSucceed),
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
