//===----------------------------------------------------------------------===//
//  PolisPropertyValueTests.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2024 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//

import Foundation
import SoftwareEtudesUtilities

import XCTest

@testable import swift_polis

final class PolisPropertyValueTests: XCTestCase {

    //MARK: - Setup & Teardown -
    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!
    private var data: Data!
    private var string: String!

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
 
        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil

       try super.tearDownWithError()
    }

    //MARK: - Tests -
    func test_PolisPropertyValue_codingSupport_shouldSucceed() throws {
        // Given
        let sut = PolisPropertyValue(valueKind: .double, value: "123.4", unit: "m")

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNoThrow(try jsonDecoder.decode(PolisPropertyValue.self, from: data))
        XCTAssertNoThrow(try jsonDecoder.decode(PolisPropertyValue.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisPropertyValue_equatable_shouldSucceed() throws {
        // Given
        let sut_string = PolisPropertyValue(valueKind: .string, value: "NW",    unit: "direction")
        let sut_int    = PolisPropertyValue(valueKind: .int,    value: "17",    unit: "m")
        let sut_float  = PolisPropertyValue(valueKind: .float,  value: "123.4", unit: "m")
        let sut_double = PolisPropertyValue(valueKind: .double, value: "123.4", unit: "m")

        // Then
        XCTAssertNotNil(sut_string)
        XCTAssertNotNil(sut_int)
        XCTAssertNotNil(sut_float)
        XCTAssertNotNil(sut_double)

        XCTAssertEqual(sut_string.stringValue(), "NW")
        XCTAssertEqual(sut_string.unit, "direction")

        XCTAssertEqual(sut_int.intValue(), 17)
        XCTAssertEqual(sut_float.floatValue(), Float(123.4))
        XCTAssertEqual(sut_double.doubleValue(), Double(123.4))
    }

    static var allTests = [
        ("test_PolisPropertyValue_codingSupport_shouldSucceed", test_PolisPropertyValue_codingSupport_shouldSucceed),
        ("test_PolisPropertyValue_equatable_shouldSucceed",     test_PolisPropertyValue_equatable_shouldSucceed),
    ]
}
