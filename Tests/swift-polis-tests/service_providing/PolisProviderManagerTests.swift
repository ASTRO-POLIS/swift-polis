//
//  PolisProviderConfigurationTests.swift
//  swift-polis
//
//  Created by Georg Tuparev on 12.09.24.
//

import XCTest

@testable import swift_polis

final class PolisProviderManagerTests: XCTestCase {


    //MARK: - Setup & Teardown -
    var providerWillCreateNotificationExpectation: XCTNSNotificationExpectation!
    var providerDidCreateNotificationExpectation: XCTNSNotificationExpectation!

    var facilityInfoWillCreateExpectation: XCTNSNotificationExpectation!
    var facilityInfoDidCreateExpectation: XCTNSNotificationExpectation!

    override class func setUp() {
        print("In class setUp.")
    }

    override class func tearDown() {
        print("In class tearDown.")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        print("In setUp.")

        try TestingSupport.cleanUpTestingFolder()
        
        providerWillCreateNotificationExpectation = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.providerWillCreateNotification)
        providerDidCreateNotificationExpectation  = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.providerDidCreateNotification)

        facilityInfoWillCreateExpectation = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.facilityInfoWillCreateNotification)
        facilityInfoDidCreateExpectation  = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.facilityInfoDidCreateNotification)

    }

    override func tearDownWithError() throws {
        print("In tearDown.")
        PolisProviderManager.currentProviderManager = nil

        try super.tearDownWithError()
    }

    //MARK: - Tests -
    func test_PolisProviderManager_creatingAndStoringProvider_shouldSucceed() async throws {
        // Given
        PolisProviderManager.localPolisRootPath = TestingSupport.testingFolder

        let config   = PolisProviderConfiguration(name: "BigBang", adminName: "admin", adminEmail:  "admin@admin.nirvana")
        let facility = TestingSupport.exampleFacility()
        
        // When
        let sut         = try PolisProviderManager.createLocalProviderWith(configuration: config, isExperimentalVersion: true)
        let facilityRep = try EarthFixBasedObservingFacilityRep.registerNewEarthBasedFacilityFrom(polisData: facility, shouldCreateNewEntity: true)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut?.facilityDirectory)
        XCTAssertEqual(sut?.facilityDirectory.observingFacilityReferences.count, 1)

        XCTAssertNotNil(facilityRep)

        await fulfillment(of: [providerWillCreateNotificationExpectation, providerDidCreateNotificationExpectation,
                              facilityInfoWillCreateExpectation, facilityInfoDidCreateExpectation,],
                          timeout: 5,
                          enforceOrder: true)

        //TODO: Test if the Facility dir has first zero and then 1 entry!
    }


    static var allTests = [
        ("test_PolisProviderManager_creatingAndStoringProvider_shouldSucceed", test_PolisProviderManager_creatingAndStoringProvider_shouldSucceed),
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

