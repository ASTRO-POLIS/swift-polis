//
//  PolisItemTests.swift
//  
//
//  Created by Georg Tuparev on 31/08/2022.
//

import XCTest
import SoftwareEtudesUtilities

@testable import swift_polis

final class PolisItemTests: XCTestCase {

    //MARK: - Initialisation -
    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!
    private var data: Data!
    private var string: String!

    override func setUpWithError() throws {
        super.setUp()

        jsonEncoder = PrettyJSONEncoder()
        jsonDecoder = PrettyJSONDecoder()
    }

    override func tearDownWithError() throws {
        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil

        super.tearDown()
    }

    //MARK: - Actual tests -
    func testPolisItemCodingSupport() {
        let identity = PolisIdentity(externalReferences: ["6539"],
                                     lifecycleStatus: PolisIdentity.LifecycleStatus.inactive,
                                     lastUpdate: Date(),
                                     name: "TestItem",
                                     abbreviation: "item",
                                     automationLabel: "Ascom Label",
                                     shortDescription: "Testing Polis Item")
        let sut      = PolisItem(identity: identity)

        XCTAssertNotNil(identity)
        XCTAssertNotNil(sut)

        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisItem.self, from: string!.data(using: .utf8)!))
    }

    //MARK: - Housekeeping -
    static var allTests = [
        ("testPolisItemCodingSupport", testPolisItemCodingSupport),
    ]
}
