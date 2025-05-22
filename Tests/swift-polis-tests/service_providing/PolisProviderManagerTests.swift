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
    var config: PolisProviderConfiguration!

    var providerWillCreateNotificationExpectation: XCTNSNotificationExpectation!
    var providerDidCreateNotificationExpectation: XCTNSNotificationExpectation!
    var providerWillLoadLocalDataExpectation: XCTNSNotificationExpectation!
    var providerDidLoadLocalDataExpectation: XCTNSNotificationExpectation!

    var facilityReferenceWillCreateExpectation: XCTNSNotificationExpectation!
    var facilityReferenceDidCreateExpectation: XCTNSNotificationExpectation!

    var facilityInfoWillCreateExpectation: XCTNSNotificationExpectation!
    var facilityInfoDidCreateExpectation: XCTNSNotificationExpectation!

    var artifactWillCreateExpectation: XCTNSNotificationExpectation!
    var artifactDidCreateExpectation: XCTNSNotificationExpectation!

    override class func setUp() {
        print("In class setUp.")
    }

    override class func tearDown() {
        print("In class tearDown.")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        print("In setUp.")

        providerWillCreateNotificationExpectation = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.providerWillCreateNotification)
        providerDidCreateNotificationExpectation  = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.providerDidCreateNotification)
        providerWillLoadLocalDataExpectation      = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.providerWillLoadLocalDataNotification)
        providerDidLoadLocalDataExpectation       = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.providerDidLoadLocalDataNotification)

        facilityReferenceWillCreateExpectation = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.facilityReferenceWillCreateNotification)
        facilityReferenceDidCreateExpectation  = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.facilityReferenceDidCreateNotification)

        facilityInfoWillCreateExpectation = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.facilityInfoWillCreateNotification)
        facilityInfoDidCreateExpectation  = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.facilityInfoDidCreateNotification)

        artifactWillCreateExpectation = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.artifactWillCreateNotification)
        artifactDidCreateExpectation  = XCTNSNotificationExpectation(name: PolisProviderManager.StatusChangeNotification.artifactDidCreateNotification)
    }

    override func tearDownWithError() throws {
        print("In tearDown.")
        PolisProviderManager.prepareForTesting()

        try super.tearDownWithError()
    }

    func prepareData(shouldStartWithCleanFolder: Bool = true) throws {
        if shouldStartWithCleanFolder { try TestingSupport.cleanUpTestingFolder() }

        PolisProviderManager.localPolisRootPath = TestingSupport.testingFolder
        config = PolisProviderConfiguration(name: "BigBang", adminName: "admin", adminEmail:  "admin@admin.nirvana")
    }

    func createTestDataForReading() throws {
        try prepareData()
        PolisProviderManager.prepareForTesting()

        let manager  = try PolisProviderManager.createLocalProviderWith(configuration: config, isExperimentalVersion: true)
        let facility = try ObservingFacilityRep.findOrRegisterObservingFacilityWith(identity: TestingSupport.examplePolisIdentityBAO())
        try facility.addArtifact(artifactType: PolisArtifact.ArtifactType.monument, visitingOpportunities: "Every day opened")

        PolisProviderManager.currentProviderManager = nil
    }

    //MARK: - Tests -
    func test_PolisProviderManager_creatingAndStoringProvider_shouldSucceed() async throws {
        // Given
//        try prepareData()
//
//        // When
//        let sut                       = try PolisProviderManager.createLocalProviderWith(configuration: config, isExperimentalVersion: true)
//        let initialNumberOfFacilities = sut?.facilityDirectory.observingFacilityReferences.count
//        let facilityRep               = try ObservingFacilityRep.findOrRegisterObservingFacilityWith(identity: TestingSupport.examplePolisIdentityBAO())
//        let finalNumberOfFacilities   = sut?.facilityDirectory.observingFacilityReferences.count
//        let facilityRepCount          = sut?.allFacilities().count
//
//        facilityRep.website = URL(string: "https://www.example.com")
//
//        try facilityRep.addArtifact(artifactType: PolisArtifact.ArtifactType.monument, visitingOpportunities: "Every day opened")
//        try facilityRep.saveChanges()
//
//        // Then
//        XCTAssertNotNil(sut)
//        XCTAssertNotNil(facilityRep)
//
//        XCTAssertNotNil(sut?.facilityDirectory)
//        XCTAssertEqual(initialNumberOfFacilities, 0)
//        XCTAssertEqual(finalNumberOfFacilities, 1)
//        XCTAssertEqual(facilityRepCount, 1)
//
//        //TODO: Move this when testing Earth-based facility
//        await fulfillment(of: [providerWillCreateNotificationExpectation, providerDidCreateNotificationExpectation,
//                               facilityReferenceWillCreateExpectation, facilityReferenceDidCreateExpectation,
//                               /*facilityInfoWillCreateExpectation, facilityInfoDidCreateExpectation,*/
//                               artifactWillCreateExpectation, artifactDidCreateExpectation,],
//                          timeout: 5,
//                          enforceOrder: true)
    }

    func test_PolisProviderManager_readExistingData_shouldSucceed() async throws {
        // Given
        try prepareData()
        let manager     = try PolisProviderManager.createLocalProviderWith(configuration: config, isExperimentalVersion: true)
        let facilityRep = try ObservingFacilityRep.findOrRegisterObservingFacilityWith(identity: TestingSupport.examplePolisIdentityBAO())

        facilityRep.website = URL(string: "https://www.example.com")

        //TODO: Add proper Artefact example!
        try facilityRep.addArtifact(artifactType: PolisArtifact.ArtifactType.monument, visitingOpportunities: "Every day opened")
        try facilityRep.saveChanges()

        PolisProviderManager.prepareForTesting()
        try prepareData(shouldStartWithCleanFolder: false)


        // When
        let sut = try PolisProviderManager.useExistingLocalProvider()

        // Then
        XCTAssertNotNil(sut.facilityDirectory)
//        await fulfillment(of: [providerWillLoadLocalDataExpectation, providerDidLoadLocalDataExpectation,],
//                          timeout: 5,
//                          enforceOrder: true)
   }

    static var allTests = [
        ("test_PolisProviderManager_creatingAndStoringProvider_shouldSucceed", test_PolisProviderManager_creatingAndStoringProvider_shouldSucceed),
        ("test_PolisProviderManager_readExistingData_shouldSucceed",           test_PolisProviderManager_readExistingData_shouldSucceed),
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

