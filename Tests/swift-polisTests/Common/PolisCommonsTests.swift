//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2022 Tuparev Technologies and the ASTRO-POLIS project
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

final class PolisCommonsTests: XCTestCase {

    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
    private var data: Data!
    private var string: String!

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

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
    }

    override func tearDown() {
        data = nil
        string = nil
        jsonEncoder = nil
        jsonDecoder = nil

        super.tearDown()
    }

    static var allTests = [
        ("test_polisDataFormat", test_polisDataFormat),
        ("test_polisAPISupport", test_polisAPISupport),
        ("test_polisSupportedImplementation", test_polisSupportedImplementation),
    ]
}
