//
//  PolisObservingFacilityLocationTests.swift
//  
//
//  Created by Georg Tuparev on 4.08.23.
//

import XCTest

@testable import swift_polis

final class PolisObservingFacilityLocationTests: XCTestCase {

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
    func test_PolisObservingFacilityLocation_codingSupport_shouldSucceed() throws {
        // Given
        let eastLongitude     = PolisPropertyValue(valueKind: .double, value: "23.21", unit: "degree")
        let latitude          = PolisPropertyValue(valueKind: .double, value: "42.53", unit: "degree")
        let altitude          = PolisPropertyValue(valueKind: .double, value: "610.0", unit: "m")

        let sut = PolisObservingFacilityLocation(eastLongitude: eastLongitude,
                                                 latitude: latitude,
                                                 altitude: altitude,
                                                 regionName: "Rodopi mountains",
                                                 place: "Rozhen",
                                                 earthTimeZoneIdentifier: "Europe/Sofia",
                                                 earthContinent: PolisObservingFacilityLocation.EarthContinent.europe,
                                                 earthRegionOrStateName: "Smolyan",
                                                 earthRegionOrStateCode: "Smolyan",
                                                 earthZipCode: "4513",
                                                 earthCountry: "Bulgaria",
                                                 earthCountryCode: "BG")
        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisObservingFacilityLocation.self, from: string!.data(using: .utf8)!))
    }

    static var allTests = [
        ("test_PolisObservingFacilityLocation_codingSupport_shouldSucceed", test_PolisObservingFacilityLocation_codingSupport_shouldSucceed),
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
