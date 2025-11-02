//===----------------------------------------------------------------------===//
//  PolisImplementationTests.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2025 Tuparev Technologies and the ASTRO-POLIS project
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
import SoftwareEtudesUtilities

final class PolisImplementationTests: XCTestCase {

    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!
    private var data: Data!
    private var string: String!

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
        try super.tearDownWithError()

        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil
    }

    //MARK: - Tests -
    func test_PolisImplementation_dataFormat_shouldSucceed() throws {
        // Given
        let sutJSON = PolisImplementation.DataFormat.json
        let sutXML  = PolisImplementation.DataFormat.xml

        // Then
        XCTAssertNotEqual(sutJSON, sutXML)
        XCTAssertEqual(sutJSON.rawValue, "json")
        XCTAssertEqual(sutXML.rawValue, "xml")
    }

    func test_PolisImplementation_apiLevel_shouldSucceed() throws {
        // Given
        let sutStaticData        = PolisImplementation.APILevel.staticData
        let sutDynamicStatus     = PolisImplementation.APILevel.dynamicStatus
        let sutDynamicScheduling = PolisImplementation.APILevel.dynamicScheduling

        // When
        data   = try? jsonEncoder.encode(sutStaticData)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotEqual(sutStaticData, sutDynamicScheduling)

        XCTAssertEqual(sutStaticData.rawValue,        "static_data")
        XCTAssertEqual(sutDynamicStatus.rawValue,     "dynamic_status")
        XCTAssertEqual(sutDynamicScheduling.rawValue, "dynamic_scheduling")

        XCTAssertEqual(string, "\"static_data\"")
        XCTAssertNoThrow(try jsonDecoder.decode(PolisImplementation.APILevel.self, from: string!.data(using: .utf8)!))

    }

    func test_PolisImplementation_supportedImplementation_shouldSucceed() throws {
        // Given
        let sutAlpha = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                           apiSupport: PolisImplementation.APILevel.staticData,
                                           version: SemanticVersion(with: "0.1.0-alpha.1")!)
        let sutBeta  = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                           apiSupport: PolisImplementation.APILevel.staticData,
                                           version: SemanticVersion(with: "0.1.0-beta.1")!)

        // When
        data   = try? jsonEncoder.encode(sutAlpha)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotEqual(sutAlpha, sutBeta)
        XCTAssertEqual(sutAlpha,
                       PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                           apiSupport: PolisImplementation.APILevel.staticData,
                                           version: SemanticVersion(with: "0.1.0-alpha.1")!))

        XCTAssertNoThrow(try jsonDecoder.decode(PolisImplementation.self, from: string!.data(using: .utf8)!))
    }

    @MainActor func test_PolisImplementation_oldestSupportedImplementation_shouldSucceed() {
        // Given
        let sut = PolisImplementation.latestSupportedImplementation()

        // When
        let last    = polisFrameworkSupportedImplementation.last!
        let version = last.version
        let api     = last.apiSupport
        let format  = last.dataFormat

        // Then
        XCTAssertEqual(sut.version,    version)
        XCTAssertEqual(sut.apiSupport, api)
        XCTAssertEqual(sut.dataFormat, format)
    }

    static let allTests = [
        ("test_PolisImplementation_dataFormat_shouldSucceed",                   test_PolisImplementation_dataFormat_shouldSucceed),
        ("test_PolisImplementation_apiLevel_shouldSucceed",                     test_PolisImplementation_apiLevel_shouldSucceed),
        ("test_PolisImplementation_supportedImplementation_shouldSucceed",      test_PolisImplementation_supportedImplementation_shouldSucceed),
    ]
}
