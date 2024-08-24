//
//  PolisPartyTests.swift
//
//
//  Created by Georg Tuparev on 23.08.24.
//

import Foundation
import SoftwareEtudesUtilities

import XCTest

@testable import swift_polis

final class PolisPartyTests: XCTestCase {

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

    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!
    private var data: Data!
    private var string: String!


    //MARK: - Tests -
    func test_CommunicationChannel_creation_shouldSucceed() {
        // Given

        // When
        data   = try? jsonEncoder.encode(PolisPartyTests.testCommunicationChannel)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(PolisPartyTests.testCommunicationChannel)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisCommunicationChannel.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisAddress_creation_shouldSucceed() throws {
        // Given

        // When
        data   = try? jsonEncoder.encode(PolisPartyTests.testAddress)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(PolisPartyTests.testAddress)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAddress.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisPerson_creation_shouldSucceed() throws {
        // Given

        // When
        data   = try? jsonEncoder.encode(PolisPartyTests.testPerson)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(PolisPartyTests.testAddress)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisPerson.self, from: string!.data(using: .utf8)!))
    }

    private static let testCommunicationChannel = PolisCommunicationChannel(twitterIDs: ["@CoolAstro", "@GalaxyFarAway"],
                                                                            mastodonIDs: ["@GalaxyFarAway@mastodon.social"],
                                                                            whatsappPhoneNumbers: ["+1 900 1234567"],
                                                                            facebookIDs: ["916735592641"],
                                                                            instagramIDs: ["GalaxyFarAway"],
                                                                            skypeIDs: ["cool_astro"])
    private static  let testAddress = PolisAddress(attentionOff: "Mrs. Royal Astronomer",
                                                   houseName: "Galaxy.",
                                                   street: "Observatory str.",
                                                   houseNumber: 42,
                                                   houseNumberSuffix: "a",
                                                   floor: 1,
                                                   apartment: "24",
                                                   district: "Stars",
                                                   place: "Sun hill",
                                                   block: "43",
                                                   zipCode: "ST1234",
                                                   province: "Star cluster",
                                                   region: "Milky way",
                                                   state: "Comet",
                                                   countryID: "AM",
                                                   poBox: "4242",
                                                   poBoxZip: "ST1256",
                                                   posteRestante: "The Observing Man",
                                                   latitude: 41.24,
                                                   longitude: 11.07,
                                                   streetLine1: "1",
                                                   streetLine2: "2",
                                                   streetLine3: "3",
                                                   streetLine4: "4",
                                                   streetLine5: "5",
                                                   streetLine6: "6",
                                                   note: "Send only stars and love")

    private static let testPerson = PolisPerson(name: "Amon Ra", email: "ra@god.cun", communication: testCommunicationChannel, address: testAddress)

    static var allTests = [
        ("test_CommunicationChannel_creation_shouldSucceed", test_CommunicationChannel_creation_shouldSucceed),
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

