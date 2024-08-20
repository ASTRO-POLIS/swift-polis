//
//  PolisObservingTests.swift
//  
//
//  Created by Georg Tuparev on 06/09/2022.
//

import XCTest
import SoftwareEtudesUtilities

@testable import swift_polis

class PolisObservingTests: XCTestCase {

    //MARK: - Initialisation -
    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!
    private var data: Data!
    private var string: String!

    override func setUp() {
        super.setUp()

        jsonEncoder = PrettyJSONEncoder()
        jsonDecoder = PrettyJSONDecoder()
    }

    override func tearDown() {
        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil

        super.tearDown()
    }

    //MARK: - Actual tests -
    func testPolisObservingFacilityCodingSupport() {
//        let identity = PolisIdentity(id: UUID(),
//                                     lifecycleStatus: PolisIdentity.LifecycleStatus.inactive,
//                                     lastUpdate: Date(),
//                                     name: "testing",
//                                     abbreviation: "tst",
//                                     automationLabel: "tst",
//                                     shortDescription: "test identity")
//        let item     = PolisItem(identity: identity)
//        let location = PolisObservingFacilityLocationType.earthSurfaceBased(location: PolisObservingFacilityLocationType.EarthBasedLocation(), type: PolisObservingFacilityLocationType.SurfaceLocationType.fixed)
//        let sut      = PolisEarthObservingSite(item: item)
//
//        data   = try? jsonEncoder.encode(sut)
//        string = String(data: data!, encoding: .utf8)
//
//        XCTAssertNoThrow(try jsonDecoder.decode(PolisEarthObservingFacility.self, from: string!.data(using: .utf8)!))
    }

    //MARK: - Housekeeping -
        static var allTests = [
            ("testPolisObservingFacilityCodingSupport", testPolisObservingFacilityCodingSupport),
        ]

}
