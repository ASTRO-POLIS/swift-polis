//===----------------------------------------------------------------------===//
//  PolisObservingFacilityTests.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//

import XCTest
import SoftwareEtudesUtilities

@testable import swift_polis

final class PolisObservingFacilityTests: XCTestCase {

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

    func test_PolisObservingFacility_codingSupport_shouldSucceed() throws {
        // Given
        let communication = PolisAdminContact.Communication(twitterIDs: ["@polis"],
                                                            whatsappPhoneNumbers: ["+305482049"],
                                                            facebookIDs: ["super_astronomers"],
                                                            instagramIDs: ["super_astro"],
                                                            skypeIDs: ["super_duper_astro"])
        let admin         = PolisAdminContact(name: "polis",
                                              emailAddress: "polis@observer.net",
                                              phoneNumber: nil,
                                              additionalCommunication: communication,
                                              note: nil)
        let owner         = PolisItemOwner(ownershipType: PolisItemOwner.OwnershipType.research, abbreviation: "SAO", adminContact: admin)
        let identity      = PolisIdentity(externalReferences: ["1234", "6539"],
                                          lifecycleStatus: PolisIdentity.LifecycleStatus.active,
                                          lastUpdate: Date(),
                                          name: "TestAttributes",
                                          abbreviation: "abc",
                                          automationLabel: "Ascom Label",
                                          shortDescription: "Testing attributes")
        let imageItem     = try PolisImageSource.ImageItem( originalSource: URL(string: PolisConstants.testBigBangPolisDomain)!,
                                                            shortDescription: "Very interesting image",
                                                            accessibilityDescription: "Image of a beautiful observatory on the topa high mountain",
                                                            copyrightHolderType: .useWithOwnersPermission,
                                                            copyrightHolderReference: "Contributor <contributor@example.com",
                                                            copyrightHolderNote: "I agree this image to be used in POLIS")
        let surfaceSize   = PolisPropertyValue(valueKind: .double, value: "2453.2", unit: "m^2")
        var imageSource   = PolisImageSource()
        imageSource.addImage(imageItem)
        
        let item          = PolisItem(identity: identity, manufacturerID: UUID(), owners: [owner], imageSourceID: imageSource.id)
        let sut           = PolisObservingFacility(item: item,
                                                   gravitationalBodyRelationship: PolisObservingFacility.ObservingFacilityLocationType.surfaceFixed,
                                                   placeInTheSolarSystem: .earth,
                                                   observingFacilityCode: "EARTH-SAO",
                                                   solarSystemBodyName: "Earth",
                                                   astronomicalCode: "SAO",
                                                   orbitingAroundPlaceInTheSolarSystemNamed: "Sun",
                                                   facilityLocationID: UUID(),
                                                   parentObservingFacilityID: nil,
                                                   subObservingFacilityIDs:  nil,
                                                   observatoryIDs: nil,
                                                   deviceIDs:  nil,
                                                   adminContact: admin,
                                                   website:URL(string: "https://sau.sa"),
                                                   scientificObjectives: "To make cool observations",
                                                   history: "Somewhere on the table Mountains people built an observatory",
                                                   openingHours: PolisVisitingHours(note: "From time to time"),
                                                   accessRestrictions: "Might meet lions",
                                                   averageClearNightsPerYear: 311,
                                                   averageSeeingConditions: PolisPropertyValue(valueKind: .double, value: "31", unit: "magnitude"),
                                                   averageSkyQuality: PolisPropertyValue(valueKind: .double, value: "0.9", unit: "magnitude / arcsec^2"),
                                                   traditionalLandOwners: "Lions and giraffes",
                                                   dominantWindDirection: PolisDirection.RoughDirection.eastNorthEast,
                                                   surfaceSize: surfaceSize)
        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisObservingFacility.self, from: string!.data(using: .utf8)!))
    }


    static var allTests = [
        ("test_PolisObservingFacility_codingSupport_shouldSucceed", test_PolisObservingFacility_codingSupport_shouldSucceed),
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
