//
//  PolisLoggerTests.swift
//  swift-polis
//
//  Created by Georg Tuparev on 20/10/2024.
//

import XCTest

@testable import swift_polis

final class PolisLoggerTests: XCTestCase {
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
    func test_PolisLogger_sharedInstance_shouldExist() throws {
        // Given
        let sut = PolisLogger.shared

        // Then
        XCTAssertNotNil(sut)
    }

    func test_PolisLogger_creatingLogs_shouldSucceed() throws {
        // Given
        let sut = PolisLogger.shared

        // When
        sut.shouldLog = true
        
        sut.info("blah")
        sut.info("blah blah")
        sut.warning("foo")
        sut.error("bar")

        // Then
        XCTAssertEqual(sut.infoMessages().count, 2)
        XCTAssertEqual(sut.warningMessages().count, 1)
        XCTAssertEqual(sut.errorMessages().count, 1)
    }

    static var allTests = [
        ("test_PolisLogger_sharedInstance_shouldExist", test_PolisLogger_sharedInstance_shouldExist),
        ("test_PolisLogger_creatingLogs_shouldSucceed", test_PolisLogger_creatingLogs_shouldSucceed),
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

