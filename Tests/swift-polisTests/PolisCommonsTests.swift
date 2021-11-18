//
//  PolisCommonsTests.swift
//  
//
//  Created by Georg Tuparev on 18/11/2021.
//

import XCTest
import SoftwareEtudes

@testable import swift_polis

final class PolisCommonsTests: XCTestCase {

    let jsonEncoder = PolisJSONEncoder()
    let jsonDecoder = PolisJSONDecoder()
    var data: Data!
    var string: String!

    func test_polisDataFormat() {
        let sutJSON = PolisDataFormat.json
        let sutXML  = PolisDataFormat.xml

        XCTAssertNotEqual(sutJSON, sutXML)
        XCTAssertEqual(sutJSON.rawValue, "json")
        XCTAssertEqual(sutXML.rawValue, "xml")
    }

    func test_polisAPISupport() {
        let sutStaticData        = PolisAPISupport.staticData
        let sutDynamicStatus     = PolisAPISupport.dynamicStatus
        let sutDynamicScheduling = PolisAPISupport.dynamicScheduling

        XCTAssertNotEqual(sutStaticData, sutDynamicScheduling)

        XCTAssertEqual(sutStaticData.rawValue,        "static_data")
        XCTAssertEqual(sutDynamicStatus.rawValue,     "dynamic_status")
        XCTAssertEqual(sutDynamicScheduling.rawValue, "dynamic_scheduling")

        data   = try? jsonEncoder.encode(sutStaticData)
        string = String(data: data!, encoding: .utf8)
        XCTAssertEqual(string, "\"static_data\"")
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAPISupport.self, from: string!.data(using: .utf8)!))
    }

    func test_polisSupportedImplementation() {
        let sutAlpha = PolisSupportedImplementation(dataFormat: PolisDataFormat.json, apiSupport: PolisAPISupport.staticData, version: SemanticVersion(with: "0.1-alpha.1")!)
        let sutBeta  = PolisSupportedImplementation(dataFormat: PolisDataFormat.json, apiSupport: PolisAPISupport.staticData, version: SemanticVersion(with: "0.1-beta.1")!)

        XCTAssertNotEqual(sutAlpha, sutBeta)
        XCTAssertEqual(sutAlpha,
                       PolisSupportedImplementation(dataFormat: PolisDataFormat.json, apiSupport: PolisAPISupport.staticData, version: SemanticVersion(with: "0.1-alpha.1")!))
        XCTAssertTrue(frameworkSupportedImplementation.contains(sutAlpha))

        data   = try? jsonEncoder.encode(sutAlpha)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisSupportedImplementation.self, from: string!.data(using: .utf8)!))

    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()

        data = nil
        string = nil
    }

    static var allTests = [
        ("test_polisDataFormat", test_polisDataFormat),
        ("test_polisAPISupport", test_polisAPISupport),
        ("test_polisSupportedImplementation", test_polisSupportedImplementation),
    ]
}
