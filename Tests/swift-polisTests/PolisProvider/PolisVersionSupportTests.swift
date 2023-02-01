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

class PolisVersionSupportTests: XCTestCase {

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
    func testPolisDataFormat() {
        let sutJSON = PolisImplementationInfo.DataFormat.json
        let sutXML  = PolisImplementationInfo.DataFormat.xml

        XCTAssertNotEqual(sutJSON, sutXML)
        XCTAssertEqual(sutJSON.rawValue, "json")
        XCTAssertEqual(sutXML.rawValue, "xml")
    }

    func testPolisAPISupport() {
        let sutStaticData        = PolisImplementationInfo.APILevel.staticData
        let sutDynamicStatus     = PolisImplementationInfo.APILevel.dynamicStatus
        let sutDynamicScheduling = PolisImplementationInfo.APILevel.dynamicScheduling

        XCTAssertNotEqual(sutStaticData, sutDynamicScheduling)

        XCTAssertEqual(sutStaticData.rawValue,        "static_data")
        XCTAssertEqual(sutDynamicStatus.rawValue,     "dynamic_status")
        XCTAssertEqual(sutDynamicScheduling.rawValue, "dynamic_scheduling")

        data   = try? jsonEncoder.encode(sutStaticData)
        string = String(data: data!, encoding: .utf8)
        XCTAssertEqual(string, "\"static_data\"")
        XCTAssertNoThrow(try jsonDecoder.decode(PolisImplementationInfo.APILevel.self, from: string!.data(using: .utf8)!))
    }

    func testPolisSupportedImplementation() {
        let sutAlpha = PolisImplementationInfo(dataFormat: PolisImplementationInfo.DataFormat.json,
                                               apiSupport: PolisImplementationInfo.APILevel.staticData,
                                               version: SemanticVersion(with: "0.1-alpha.1")!)
        let sutBeta  = PolisImplementationInfo(dataFormat: PolisImplementationInfo.DataFormat.json,
                                               apiSupport: PolisImplementationInfo.APILevel.staticData,
                                               version: SemanticVersion(with: "0.1-beta.1")!)

        XCTAssertNotEqual(sutAlpha, sutBeta)
        XCTAssertEqual(sutAlpha,
                       PolisImplementationInfo(dataFormat: PolisImplementationInfo.DataFormat.json,
                                               apiSupport: PolisImplementationInfo.APILevel.staticData,
                                               version: SemanticVersion(with: "0.1-alpha.1")!))

        data   = try? jsonEncoder.encode(sutAlpha)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisImplementationInfo.self, from: string!.data(using: .utf8)!))
    }

    func testDeviceCompatibilityDiscovery() {
        let version             = frameworkSupportedImplementation.last!.version
        let implementationInfo  = PolisImplementationInfo(dataFormat: PolisImplementationInfo.DataFormat.json,
                                                          apiSupport: PolisImplementationInfo.APILevel.staticData,
                                                          version: version)
        let telescopeDeviceType = PolisDevice.DeviceType.telescope

        XCTAssertTrue(PolisImplementationInfo.isValid(deviceType: telescopeDeviceType, for: implementationInfo))
        XCTAssertTrue(PolisImplementationInfo.canDevice(ofType: telescopeDeviceType, beSubDeviceOfType: telescopeDeviceType, for: implementationInfo))
    }

    //TODO: Test oldestSupportedImplementationInfo
    
    //MARK: - Housekeeping -
    static var allTests = [
        ("testPolisDataFormat",              testPolisDataFormat),
        ("testPolisAPISupport",              testPolisAPISupport),
        ("testPolisSupportedImplementation", testPolisSupportedImplementation),
        ("testDeviceCompatibilityDiscovery", testDeviceCompatibilityDiscovery),
    ]

}
