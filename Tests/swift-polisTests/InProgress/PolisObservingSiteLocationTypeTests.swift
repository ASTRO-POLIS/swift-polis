//
//  PolisObservingSiteLocationTypeTests.swift
//  
//
//  Created by Georg Tuparev on 19.10.22.
//

import XCTest

import XCTest

@testable import swift_polis

final class PolisObservingSiteLocationTypeTests: XCTestCase {

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

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
    }

    override func tearDownWithError() throws {
        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil

        try super.tearDownWithError()
    }

    //MARK: - Tests -
    func test_PolisObservingSiteLocationType_earthBasedLocationCodable_shouldSucceed() throws {
        // Given
        let eastLongitude     = PolisMeasurement(value: 14.15, unit: "degree")
        let latitude          = PolisMeasurement(value: 48.51, unit: "degree")
        let altitude          = PolisMeasurement(value: 896.0, unit: "m")
        let continent         = PolisObservingSiteLocationType.EarthBasedLocation.EarthContinent.europe
        let place             = "Sandl"
        let regionOrState     = "Ober Östereich"
        let regionOrStateCode = "OÖ"
        let zipCode           = "1234"
        let country           = "Austria"
        let countryCode       = "OS"
        let surfaceSize       = PolisMeasurement(value: 453.2, unit: "m^2")

        // When
        let sut = PolisObservingSiteLocationType.EarthBasedLocation(eastLongitude: eastLongitude,
                                                                    latitude: latitude,
                                                                    altitude: altitude,
                                                                    continent: continent,
                                                                    place: place,
                                                                    regionOrState: regionOrState,
                                                                    regionOrStateCode: regionOrStateCode,
                                                                    zipCode: zipCode,
                                                                    country: country,
                                                                    countryCode: countryCode,
                                                                    surfaceSize: surfaceSize)

        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        print(string!)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisObservingSiteLocationType.EarthBasedLocation.self, from: string!.data(using: .utf8)!))
    }


    static var allTests = [
        ("test_PolisObservingSiteLocationType_earthBasedLocationCodable_shouldSucceed", test_PolisObservingSiteLocationType_earthBasedLocationCodable_shouldSucceed),
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

