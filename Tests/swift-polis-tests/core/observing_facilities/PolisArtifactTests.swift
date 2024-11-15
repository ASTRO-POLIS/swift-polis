//
//  PolisArtifactTests.swift
//  swift-polis
//
//  Created by Georg Tuparev on 15/11/2024.
//

import XCTest
import Foundation
import SoftwareEtudesUtilities

@testable import swift_polis

final class PolisArtifactTests: XCTestCase {
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
    func test_PolisArtifact_codingSupport_shouldSucceed() throws {
        // Given
        let sut = PolisArtifact(identity: TestingSupport.examplePolisIdentityBAO(), artifactType: .monument, visitingOpportunities: "One can visit Viktor Ambartsumian monument et any time BAO is open")

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisArtifact.self, from: data))
        XCTAssertNoThrow(try jsonDecoder.decode(PolisArtifact.self, from: string!.data(using: .utf8)!))
   }

    static var allTests = [
        ("test_PolisArtifact_codingSupport_shouldSucceed", test_PolisArtifact_codingSupport_shouldSucceed),
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

