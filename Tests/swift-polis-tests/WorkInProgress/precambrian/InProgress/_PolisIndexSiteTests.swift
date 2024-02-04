//
//  PolisIndexSiteTests.swift
//  
//
//  Created by Georg Tuparev on 23.11.22.
//

import XCTest

import XCTest

@testable import swift_polis

final class PolisIndexSiteTests: XCTestCase {

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
    func test_PolisIndex_Creation_ShouldSucceed() throws {
        // Given
        let sut = PolisIndex()

        // When

        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.sites.count, 0)
    }

    func test_PolisIndex_CreationOfSingleRootSite_ShouldSucceed() {
        // Given
        let id  = UUID()
        let sut = PolisIndex()

        // When
        sut.addSite(id: id)

        // Then
        XCTAssertEqual(sut.sites.count, 1)
        XCTAssertEqual(sut.sites.first!.id, id)
    }

    func test_PolisIndex_AddingSubSite_ShouldSucceed() {
        // Given
        let rootID1      = UUID()
        let rootID2      = UUID()
        let childID      = UUID()
        let grandchildID = UUID()
        let sut          = PolisIndex()

        // When
        sut.addSite(id: rootID1)
        let rootSite       = sut.addSite(id: rootID2, assumedSubSiteIDs: [childID])
        let childSite      = sut.addSite(id: childID, assumedSubSiteIDs: [grandchildID])
        let grandchildSite = sut.addSite(id: grandchildID)

        // Then
        XCTAssertEqual(sut.sites.count, 2)
        XCTAssertEqual(rootSite!.id, childSite!.parent!.id)
        XCTAssertEqual(childSite!.id, grandchildSite!.parent!.id)
    }

    func test_PolisIndex_AddingSubSiteReverseOrder_ShouldSucceed() {
        // Given
//        let rootID1      = UUID()
//        let rootID2      = UUID()
//        let childID      = UUID()
//        let grandchildID = UUID()
//        let sut          = PolisIndex()

        // When
//        let grandchildSite = sut.addSite(id: grandchildID)
//        let childSite      = sut.addSite(id: childID, assumedSubSiteIDs: [grandchildID])
//        let rootSite       = sut.addSite(id: rootID2, assumedSubSiteIDs: [childID])
//        let grandchildSite = sut.addSite(id: grandchildID)

        // Then
//        XCTAssertEqual(sut.sites.count, 1)
//        XCTAssertEqual(rootSite!.id, childSite!.parent!.id)
//        XCTAssertEqual(childSite!.id, grandchildSite!.parent!.id)
    }

    func test_PolisIndex_IDPath() throws {
        // Given
        let rootID1      = UUID()
        let rootID2      = UUID()
        let childID      = UUID()
        let grandchildID = UUID()
        let sut          = PolisIndex()

        // When
        sut.addSite(id: rootID1)
        let rootSite       = sut.addSite(id: rootID2, assumedSubSiteIDs: [childID])
        let childSite      = sut.addSite(id: childID, assumedSubSiteIDs: [grandchildID])
        let grandchildSite = sut.addSite(id: grandchildID)

        // Then
        XCTAssertEqual(rootSite!.idPath(), rootID2.uuidString)
        XCTAssertEqual(childSite!.idPath(), "\(rootID2.uuidString)/\(childID.uuidString)")
        XCTAssertEqual(grandchildSite!.idPath(), "\(rootID2.uuidString)/\(childID.uuidString)/\(grandchildID.uuidString)")
    }

    func test_PolisIndex_FindingSite_ShouldSucceed() {
        // Given
        let rootID1      = UUID()
        let rootID2      = UUID()
        let childID      = UUID()
        let grandchildID = UUID()
        let sut          = PolisIndex()

        // When
        sut.addSite(id: rootID1)
        let rootSite       = sut.addSite(id: rootID2, assumedSubSiteIDs: [childID])
        let childSite      = sut.addSite(id: childID, assumedSubSiteIDs: [grandchildID])
        let grandchildSite = sut.addSite(id: grandchildID)

        let foundRootSite       = sut.indexSiteWith(id: rootID2)
        let foundChildSite      = sut.indexSiteWith(id: childID)
        let foundGrandchildSite = sut.indexSiteWith(id: grandchildID)

        // Then
        XCTAssertEqual(rootSite!.id, foundRootSite!.id)
        XCTAssertEqual(childSite!.id, foundChildSite!.id)
        XCTAssertEqual(grandchildSite!.id, foundGrandchildSite!.id)
    }

    static var allTests = [
        ("test_PolisIndex_Creation_ShouldSucceed",                  test_PolisIndex_Creation_ShouldSucceed),
        ("test_PolisIndex_CreationOfSingleRootSite_ShouldSucceed",  test_PolisIndex_CreationOfSingleRootSite_ShouldSucceed),
        ("test_PolisIndex_AddingSubSite_ShouldSucceed",             test_PolisIndex_AddingSubSite_ShouldSucceed),
        ("test_PolisIndex_AddingSubSiteReverseOrder_ShouldSucceed", test_PolisIndex_AddingSubSiteReverseOrder_ShouldSucceed),
        ("test_PolisIndex_IDPath",                                  test_PolisIndex_IDPath),
        ("test_PolisIndex_FindingSite_ShouldSucceed",               test_PolisIndex_FindingSite_ShouldSucceed),
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

