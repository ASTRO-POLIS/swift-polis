//===----------------------------------------------------------------------===//
//  PolisCommonTypesTests.swift
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

@testable import swift_polis

final class PolisCommonTypesTests: XCTestCase {

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
        print("In setUp.")

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
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

    //MARK: - PolisOpeningTimesForVisitors tests
    func test_PolisVisitingHours_creation_shouldSucceed() throws {
        // Given
        let aNote = "A very interesting note"
        let sut = PolisVisitingHours(note: aNote)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.note!, aNote)
    }

    func test_PolisVisitingHours_codingSupport_shouldSucceed() throws {
        // Given
        let aNote = "A very interesting note"
        let sut =  PolisVisitingHours(note: aNote)

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisVisitingHours.self, from: data))
        XCTAssertNoThrow(try jsonDecoder.decode(PolisVisitingHours.self, from: string!.data(using: .utf8)!))
    }

    //MARK: POLIS Identity
    func test_PolisIdentity_codingSupport_shouldSucceed() throws {
        // Given
        let sut = PolisIdentity(externalReferences: ["1234", "6539"],
                                lifecycleStatus: PolisIdentity.LifecycleStatus.active,
                                lastUpdate: Date(),
                                name: "TestAttributes",
                                localName: "Тестови атрибути",
                                abbreviation: "abc",
                                automationLabel: "Ascom Label",
                                shortDescription: "Testing attributes")

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisIdentity.self, from: string!.data(using: .utf8)!))
    }

    //MARK: - Item Owner
    func test_PolisItemOwner_codingSupport_shouldSucceed() throws {
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
        let sut           = PolisItemOwner(ownershipType: PolisItemOwner.OwnershipType.research, abbreviation: "SAO", adminContact: admin)

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisItemOwner.self, from: string!.data(using: .utf8)!))
    }


    //MARK: - Images
    func test_PolisImageItem_codingSupport_shouldSucceed() throws {
        // Given
        let sut = try PolisImageSource.ImageItem( originalSource: URL(string: PolisConstants.testBigBangPolisDomain)!,
                                                  shortDescription: "Very interesting image",
                                                  accessibilityDescription: "Image of a beautiful observatory on the topa high mountain",
                                                  copyrightHolderType: .useWithOwnersPermission,
                                                  copyrightHolderReference: "Contributor <contributor@example.com>",
                                                  copyrightHolderNote: "I agree this image to be used in POLIS")

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisImageSource.ImageItem.self, from: string!.data(using: .utf8)!))
    }

    //MARK: - POLIS Item
    func test_PolisItem_codingSupport_shouldSucceed() throws {
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
                                                            copyrightHolderReference: "Contributor <contributor@example.com>",
                                                            copyrightHolderNote: "I agree this image to be used in POLIS",
                                                            author: "John Appleseed")
        var imageSource   = PolisImageSource()
        imageSource.addImage(imageItem)

        let sut           = PolisItem(identity: identity, manufacturerID: UUID(), owners: [owner], imageSourceID: imageSource.id)

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisItem.self, from: string!.data(using: .utf8)!))
    }


    //MARK: - Communication
    func test_PolisAdminContactCommunication_codingSupport_shouldSucceed() throws {
        // Given
        let sut = PolisAdminContact.Communication(twitterIDs: ["@polis"],
                                                  whatsappPhoneNumbers: ["+305482049"],
                                                  facebookIDs: ["super_astronomers"],
                                                  instagramIDs: ["super_astro"],
                                                  skypeIDs: ["super_duper_astro"])


        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAdminContact.Communication.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisAdminContact_codingSupport_shouldSucceed() throws {
        // Given
        let communication = PolisAdminContact.Communication(twitterIDs: ["@polis"],
                                                            whatsappPhoneNumbers: ["+305482049"],
                                                            facebookIDs: ["super_astronomers"],
                                                            instagramIDs: ["super_astro"],
                                                            skypeIDs: ["super_duper_astro"])
        let sut = PolisAdminContact(name: "polis",
                                    emailAddress: "polis@observer.net",
                                    phoneNumber: nil,
                                    additionalCommunication: communication,
                                    note: nil)

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAdminContact.self, from: string!.data(using: .utf8)!))
   }

    func test_PolisImageSourceImageItem_codingSupport_shouldSucceed() throws {
        // Given
        let sut = try PolisImageSource.ImageItem( originalSource: URL(string: PolisConstants.testBigBangPolisDomain)!,
                                                  shortDescription: "Very interesting image",
                                                  accessibilityDescription: "Image of a beautiful observatory on the topa high mountain",
                                                  copyrightHolderType: .useWithOwnersPermission,
                                                  copyrightHolderReference: "Contributor <contributor@example.com",
                                                  copyrightHolderNote: "I agree this image to be used in POLIS")

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisImageSource.ImageItem.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisImageSource_codingSupport_shouldSucceed() async throws {
        // Given
        let item = try PolisImageSource.ImageItem( originalSource: URL(string: PolisConstants.testBigBangPolisDomain)!,
                                                   shortDescription: "Very interesting image",
                                                   accessibilityDescription: "Image of a beautiful observatory on the topa high mountain",
                                                   copyrightHolderType: .useWithOwnersPermission,
                                                   copyrightHolderReference: "Contributor <contributor@example.com",
                                                   copyrightHolderNote: "I agree this image to be used in POLIS")
        var sut  = PolisImageSource()

        print(">>>> 1. Number of items: \(sut.imageItems.count)")
        // When
        sut.addImage(item)

        print(">>>> 2. Number of items: \(sut.imageItems.count)")

        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)


        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisImageSource.self, from: string!.data(using: .utf8)!))
        XCTAssertEqual(sut.imageItems.count, 1)
 }

    func test_PolisImageSource_addingAndRemovingItems_shouldSucceed() async throws {
        // Given
        let item1 = try PolisImageSource.ImageItem( originalSource: URL(string: PolisConstants.testBigBangPolisDomain)!,
                                                    shortDescription: "Very interesting image",
                                                    accessibilityDescription: "Image of a beautiful observatory on the topa high mountain",
                                                    copyrightHolderType: .useWithOwnersPermission,
                                                    copyrightHolderReference: "Contributor <contributor@example.com",
                                                    copyrightHolderNote: "I agree this image to be used in POLIS")
        let item2 = try PolisImageSource.ImageItem( originalSource: URL(string: PolisConstants.testBigBangPolisDomain)!,
                                                    shortDescription: "Horrible image image",
                                                    accessibilityDescription: "Image of a beautiful observatory on the topa high mountain",
                                                    copyrightHolderType: .openSource,
                                                    copyrightHolderReference: "Contributor <contributor@example.com")
        var sut  = PolisImageSource()

        // Then
        sut.addImage(item1)
        XCTAssertEqual(sut.imageItems.count, 1)
        sut.addImage(item1)
        XCTAssertEqual(sut.imageItems.count, 1)
        sut.removeImageWith(id: item1.id)
        XCTAssertEqual(sut.imageItems.count, 0)
        sut.addImage(item1)
        sut.addImage(item2)
        XCTAssertEqual(sut.imageItems.count, 2)
    }

    static var allTests = [
        ("test_PolisVisitingHours_creation_shouldSucceed",                  test_PolisVisitingHours_creation_shouldSucceed),
        ("test_PolisVisitingHours_creation_shouldSucceed",                  test_PolisVisitingHours_creation_shouldSucceed),
        ("test_PolisIdentity_codingSupport_shouldSucceed",                  test_PolisIdentity_codingSupport_shouldSucceed),
        ("test_PolisItemOwner_codingSupport_shouldSucceed",                 test_PolisItemOwner_codingSupport_shouldSucceed),
        ("test_PolisImageItem_codingSupport_shouldSucceed",                 test_PolisImageItem_codingSupport_shouldSucceed),
        ("test_PolisItem_codingSupport_shouldSucceed",                      test_PolisItem_codingSupport_shouldSucceed),
        ("test_PolisAdminContactCommunication_codingSupport_shouldSucceed", test_PolisAdminContactCommunication_codingSupport_shouldSucceed),
        ("test_PolisAdminContact_codingSupport_shouldSucceed",              test_PolisAdminContact_codingSupport_shouldSucceed),
        ("test_PolisImageSourceImageItem_codingSupport_shouldSucceed",      test_PolisImageSourceImageItem_codingSupport_shouldSucceed),
        ("test_PolisImageSource_codingSupport_shouldSucceed",               test_PolisImageSource_codingSupport_shouldSucceed),
        ("test_PolisImageSource_addingAndRemovingItems_shouldSucceed",      test_PolisImageSource_addingAndRemovingItems_shouldSucceed),
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
