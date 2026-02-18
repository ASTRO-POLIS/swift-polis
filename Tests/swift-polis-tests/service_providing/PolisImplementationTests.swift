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
        let sut = PolisConstants().latestPolisFrameworkSupportedImplementation()

        // When
        let last    = PolisConstants().latestPolisFrameworkSupportedImplementation()
        let version = last.version
        let api     = last.apiSupport
        let format  = last.dataFormat

        // Then
        XCTAssertEqual(sut.version,    version)
        XCTAssertEqual(sut.apiSupport, api)
        XCTAssertEqual(sut.dataFormat, format)
    }

    func test_PolisImplementation_latestSupportedImplementation_jsonStatic_shouldReturnLatestJSONStatic() throws {
        // Given
        let v1xml = PolisImplementation(dataFormat: PolisImplementation.DataFormat.xml,
                                         apiSupport: PolisImplementation.APILevel.staticData,
                                         version: SemanticVersion(with: "1.0.0-alpha.1")!)
        let v2xml = PolisImplementation(dataFormat: PolisImplementation.DataFormat.xml,
                                         apiSupport: PolisImplementation.APILevel.staticData,
                                         version: SemanticVersion(with: "2.0.0-alpha.1")!)
        let v2json = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                         apiSupport: PolisImplementation.APILevel.staticData,
                                         version: SemanticVersion(with: "2.0.0-alpha.1")!)

        let supported = [v1xml, v2xml, v2json]

        let request = PolisImplementation.SupportRequest(acceptableFormats: [.json],
                                                         minimumAPILevel: .staticData)

        // When
        let result = PolisImplementation.latestSupportedImplementation(for: request, in: supported)

        // Then
        XCTAssertEqual(result, v2json)
    }

    func test_PolisImplementation_latestSupportedImplementation_minimumDynamicStatus_shouldReturnLatestDynamicStatus() throws {
        // Given
        let v2jsonStatic = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                                apiSupport: PolisImplementation.APILevel.staticData,
                                                version: SemanticVersion(with: "2.0.0-alpha.1")!)
        let v21jsonDynamic = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                                apiSupport: PolisImplementation.APILevel.dynamicStatus,
                                                version: SemanticVersion(with: "2.1.0-alpha.1")!)
        let v3jsonStatic = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                                apiSupport: PolisImplementation.APILevel.staticData,
                                                version: SemanticVersion(with: "3.0.0-alpha.1")!)

        let supported = [v2jsonStatic, v21jsonDynamic, v3jsonStatic]

        let request = PolisImplementation.SupportRequest(acceptableFormats: [.json],
                                                         minimumAPILevel: .dynamicStatus)

        // When
        let result = PolisImplementation.latestSupportedImplementation(for: request, in: supported)

        // Then
        XCTAssertEqual(result, v21jsonDynamic)
    }

    func test_PolisImplementation_latestSupportedImplementation_whenNoMatch_shouldReturnNil() throws {
        // Given
        let v1xml = PolisImplementation(dataFormat: PolisImplementation.DataFormat.xml,
                                        apiSupport: PolisImplementation.APILevel.staticData,
                                        version: SemanticVersion(with: "1.0.0-alpha.1")!)

        let supported = [v1xml]

        let request = PolisImplementation.SupportRequest(acceptableFormats: [.json],
                                                         minimumAPILevel: .staticData)

        // When
        let result = PolisImplementation.latestSupportedImplementation(for: request, in: supported)

        // Then
        XCTAssertNil(result)
    }

    func test_PolisImplementation_hashable_equalInstances_shouldHaveEqualHashes() throws {
        // Given
        let sut1 = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                       apiSupport: PolisImplementation.APILevel.staticData,
                                       version: SemanticVersion(with: "1.0.0-alpha.1")!)
        let sut2 = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                       apiSupport: PolisImplementation.APILevel.staticData,
                                       version: SemanticVersion(with: "1.0.0-alpha.1")!)

        // When
        let h1 = sut1.hashValue
        let h2 = sut2.hashValue

        // Then
        XCTAssertEqual(sut1, sut2)
        XCTAssertEqual(h1, h2)
    }

    func test_PolisImplementation_hashable_nonEqualInstances_shouldNotBeEqual() throws {
        // Given
        let sut1 = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                       apiSupport: PolisImplementation.APILevel.staticData,
                                       version: SemanticVersion(with: "1.0.0-alpha.1")!)
        let sut2 = PolisImplementation(dataFormat: PolisImplementation.DataFormat.xml,
                                       apiSupport: PolisImplementation.APILevel.staticData,
                                       version: SemanticVersion(with: "1.0.0-alpha.1")!)

        // When
        let h1 = sut1.hashValue
        let h2 = sut2.hashValue

        // Then
        XCTAssertNotEqual(sut1, sut2)
        XCTAssertNotEqual(h1, h2)
    }

    static let allTests = [
        ("test_PolisImplementation_dataFormat_shouldSucceed",                   test_PolisImplementation_dataFormat_shouldSucceed),
        ("test_PolisImplementation_apiLevel_shouldSucceed",                     test_PolisImplementation_apiLevel_shouldSucceed),
        ("test_PolisImplementation_supportedImplementation_shouldSucceed",      test_PolisImplementation_supportedImplementation_shouldSucceed),
        ("test_PolisImplementation_latestSupportedImplementation_jsonStatic_shouldReturnLatestJSONStatic",      test_PolisImplementation_latestSupportedImplementation_jsonStatic_shouldReturnLatestJSONStatic),
        ("test_PolisImplementation_latestSupportedImplementation_minimumDynamicStatus_shouldReturnLatestDynamicStatus",      test_PolisImplementation_latestSupportedImplementation_minimumDynamicStatus_shouldReturnLatestDynamicStatus),
        ("test_PolisImplementation_latestSupportedImplementation_whenNoMatch_shouldReturnNil",      test_PolisImplementation_latestSupportedImplementation_whenNoMatch_shouldReturnNil),
        ("test_PolisImplementation_hashable_equalInstances_shouldHaveEqualHashes", test_PolisImplementation_hashable_equalInstances_shouldHaveEqualHashes),
        ("test_PolisImplementation_hashable_nonEqualInstances_shouldNotBeEqual", test_PolisImplementation_hashable_nonEqualInstances_shouldNotBeEqual),
    ]
}
