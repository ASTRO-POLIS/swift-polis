//
//  PolisManufacturerTests.swift
//  
//
//  Created by Georg Tuparev on 31/08/2022.
//

import XCTest
@testable import swift_polis

class PolisManufacturerTests: XCTestCase {

    //MARK: - Initialisation -
    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
    private var data: Data!
    private var string: String!

    override func setUpWithError() throws {
        super.setUp()

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
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
        let identity = PolisIdentity(references: ["6539"],
                                     status: PolisIdentity.LifecycleStatus.active,
                                     lastUpdate: Date(),
                                     name: "asa",
                                     abbreviation: "asa",
                                     automationLabel: "asa mounts",
                                     shortDescription: "ASA Mount")
        let sut      = PolisManufacturer(identity: identity, uniqueName: "asa")

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
