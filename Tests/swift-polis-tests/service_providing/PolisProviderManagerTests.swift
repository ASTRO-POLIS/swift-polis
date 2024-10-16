//
//  PolisProviderConfigurationTests.swift
//  swift-polis
//
//  Created by Georg Tuparev on 12.09.24.
//

import XCTest

@testable import swift_polis

final class PolisProviderConfigurationTests: XCTestCase {

    //MARK: - Setup & Teardown -
    var providerWillCreateNotificationExpectation: XCTNSNotificationExpectation!
    var providerDidCreateNotificationExpectation: XCTNSNotificationExpectation!

    override class func setUp() {
        print("In class setUp.")
    }

    override class func tearDown() {
        print("In class tearDown.")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        print("In setUp.")

        providerWillCreateNotificationExpectation = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotifications.providerWillCreateNotification)
        providerDidCreateNotificationExpectation  = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotifications.providerDidCreateNotification)
    }

    override func tearDownWithError() throws {
        print("In tearDown.")
        try super.tearDownWithError()
    }

    //MARK: - Tests -
    func test_PolisProviderConfiguration_creation_shouldSucceed() throws {
        // Given
        PolisProviderManager.localPolisRootPath = "/tmp/polis_test"

        let sut = try PolisProviderManager()

        // Then
        XCTAssertNotNil(sut)
    }

    func test_PolisProviderConfiguration_creatingProvider_shouldSucceed() async throws {
        // Given
        PolisProviderManager.localPolisRootPath = "/tmp/polis_test"

        let sut = try PolisProviderManager()
        let config = PolisProviderConfiguration(name: "BigBang", adminName: "admin", adminEmail:  "admin@admin.nirvana")

        // When
        try await sut.createLocalProvider(configuration: config)
        
        // Then
        await fulfillment(of: [providerWillCreateNotificationExpectation, providerDidCreateNotificationExpectation],
                          timeout: 5,
                          enforceOrder: true)
    }

    //TODO: Start with test that create a new public provider
    
    static var allTests = [
        ("test_PolisProviderConfiguration_creatingProvider_shouldSucceed", test_PolisProviderConfiguration_creatingProvider_shouldSucceed),
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

