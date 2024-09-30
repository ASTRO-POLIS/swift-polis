//
//  PolisUtilitiesTests.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25/09/2024.
//


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
    // Example UUID string: F666D608-DFFD-43F5-922D-201FB13CDC2C

    func test_PolisUtilities_checkingPolisReference_shouldSucceed() throws {
        // Given
        let sut = "\(PolisConstants.polisReferencePrefix)\(UUID().uuidString)"

        // Then
        XCTAssertTrue(isPolisReference(sut))
    }

    func test_PolisUtilities_checkingPolisReference_shouldFail() throws {
        // Given
        let sut = "\(PolisConstants.polisReferencePrefix)%^#^)&"

        // Then
        XCTAssertFalse(isPolisReference(sut))
    }

    func test_PolisUtilities_uuidFromReference_shouldGenerate() throws {
        // Given
        let sut = "\(PolisConstants.polisReferencePrefix)F666D608-DFFD-43F5-922D-201FB13CDC2C"

        // When
        let uuidString = uuidFromPolis(reference: sut)

        // Then
        XCTAssertEqual(uuidString, "F666D608-DFFD-43F5-922D-201FB13CDC2C")
    }

    func test_PolisUtilities_referenceFromUUID_shouldGenerate() throws {
        // Given
        let sut = UUID(uuidString: "F666D608-DFFD-43F5-922D-201FB13CDC2C")!

        // When
        let reference = polisReferenceFrom(uuid: sut)

        // Then
        XCTAssertEqual(reference, "\(PolisConstants.polisReferencePrefix)F666D608-DFFD-43F5-922D-201FB13CDC2C")
    }

    static var allTests = [
        ("test_PolisUtilities_checkingPolisReference_shouldSucceed", test_PolisUtilities_checkingPolisReference_shouldSucceed),
        ("test_PolisUtilities_checkingPolisReference_shouldFail",    test_PolisUtilities_checkingPolisReference_shouldFail),
        ("test_PolisUtilities_uuidFromReference_shouldGenerate",     test_PolisUtilities_uuidFromReference_shouldGenerate),
        ("test_PolisUtilities_referenceFromUUID_shouldGenerate",     test_PolisUtilities_referenceFromUUID_shouldGenerate),
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

