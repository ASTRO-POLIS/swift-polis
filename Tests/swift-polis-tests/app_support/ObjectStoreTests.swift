//
//  ObjectStoreTests.swift
//  swift-polis
//
//  Created by Georg Tuparev on 09/06/2025.
//

import XCTest

@testable import swift_polis

final class ObjectStoreTests: XCTestCase {
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
    func test_ObjectStore_creatingEmptyStore_shouldSucceed() async throws {
        // Given
        let sut = try await AppSupportTestingSupport.objectStore()

        // When
        let isConfigured = await sut.isConfigured()
        let fileFinder   = await sut.fileResourceFinder()
        let domainFinder = await sut.remoteResourceFinder()

        // Then
        XCTAssertFalse(isConfigured)
        XCTAssertNotNil(fileFinder)
        XCTAssertNotNil(domainFinder)
    }

    func test_ObjectStore_creatingAndRemovingLocalStore_shouldSucceed() async throws {
        // Given
        let sut    = try await AppSupportTestingSupport.objectStore()
        let config = ProviderConfiguration(name: "BAO", adminName: "Mr. Astronomer", adminEmail: "astro@example.com")

        // When
        let isConfiguredPreCreation = await sut.isConfigured()
        try await sut.createLocalStore(providerConfiguration: config)
        let isConfiguredPostCreation = await sut.isConfigured()
        try await sut.removeExistingLocalStore()
        let isConfiguredAfterRemoval  = await sut.isConfigured()
        
        // Then
        XCTAssertFalse(isConfiguredPreCreation)
        XCTAssertTrue(isConfiguredPostCreation)
        XCTAssertFalse(isConfiguredAfterRemoval)
    }

    static var allTests = [
        ("test_ObjectStore_creatingEmptyStore_shouldSucceed",            test_ObjectStore_creatingEmptyStore_shouldSucceed),
        ("test_ObjectStore_creatingAndRemovingLocalStore_shouldSucceed", test_ObjectStore_creatingAndRemovingLocalStore_shouldSucceed),
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
