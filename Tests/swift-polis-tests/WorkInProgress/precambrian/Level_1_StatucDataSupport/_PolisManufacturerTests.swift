//
//  PolisManufacturerTests.swift
//  
//
//  Created by Georg Tuparev on 31/08/2022.
//

import XCTest
import SoftwareEtudesUtilities

@testable import swift_polis

class PolisManufacturerTests: XCTestCase {

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
    func testPolisManufacturerCodingSupport() {
        let identity = PolisIdentity(externalReferences: ["6539"],
                                     lifecycleStatus: PolisIdentity.LifecycleStatus.active,
                                     lastUpdate: Date(),
                                     name: "asa",
                                     abbreviation: "asa",
                                     automationLabel: "asa mounts",
                                     shortDescription: "ASA Mount")
        let sut      = PolisManufacturer(identity: identity)

        XCTAssertNotNil(identity)
        XCTAssertNotNil(sut)

        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisManufacturer.self, from: string!.data(using: .utf8)!))
    }

    //MARK: - Housekeeping -
    static var allTests = [
        ("testPolisManufacturerCodingSupport", testPolisManufacturerCodingSupport),
    ]
}
