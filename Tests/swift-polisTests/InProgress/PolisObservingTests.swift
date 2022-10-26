//
//  PolisObservingTests.swift
//  
//
//  Created by Georg Tuparev on 06/09/2022.
//

import XCTest
@testable import swift_polis

class PolisObservingTests: XCTestCase {

    //MARK: - Initialisation -
    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
    private var data: Data!
    private var string: String!

    override func setUp() {
        super.setUp()

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
    }

    override func tearDown() {
        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil

        super.tearDown()
    }

    //MARK: - Actual tests -
    func testPolisObservingSiteCodingSupport() {
        let identity = PolisIdentity(id: UUID(),
                                     status: PolisIdentity.LifecycleStatus.inactive,
                                     lastUpdate: Date(),
                                     name: "testing",
                                     abbreviation: "tst",
                                     automationLabel: "tst",
                                     shortDescription: "test identity")
        let item     = PolisItem(identity: identity)
        let location = PolisObservingSiteLocationType.earthSurfaceBased(earthBase: PolisObservingSiteLocationType.EarthBasedLocation(), type: PolisObservingSiteLocationType.SurfaceLocationType.fixed)
        let sut      = PolisObservingSite(item: item, location: location)

        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        print("///////////////")
        print(string!)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisObservingSite.self, from: string!.data(using: .utf8)!))
    }

    //MARK: - Housekeeping -
        static var allTests = [
            ("testPolisObservingSiteCodingSupport", testPolisObservingSiteCodingSupport),
        ]

}
