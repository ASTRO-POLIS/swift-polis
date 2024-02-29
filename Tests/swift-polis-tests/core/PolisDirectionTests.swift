//===----------------------------------------------------------------------===//
//  PolisDirectionTests.swift
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

import XCTest

@testable import swift_polis

final class PolisDirectionTests: XCTestCase {

    //MARK: - Setup & Teardown -
    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
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

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
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
    func test_PolisDirection_exactCodingSupport_shouldSucceed() throws {
        // Given
        let sut_exact = try PolisDirection(exactDirection: 16.63)

        // When
        data   = try? jsonEncoder.encode(sut_exact)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(sut_exact)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirection.self, from: data))
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirection.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisDirection_roughCodingSupport_shouldSucceed() throws {
        // Given
        let sut_rough = try PolisDirection(roughDirection: PolisDirection.RoughDirection.eastNorthEast)

        // When
        data   = try? jsonEncoder.encode(sut_rough)
        string = String(data: data!, encoding: .utf8)


        // Then
        XCTAssertNotNil(sut_rough)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirection.self, from: data))
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirection.self, from: string!.data(using: .utf8)!))
        XCTAssertEqual(sut_rough.roughDirection?.abbreviation(), "E/NE")
    }

    func test_PolisDirection_calculations_shouldSucceed() throws {
        // Given
        let sut_exact = try PolisDirection(exactDirection: 16.63)
        let sut_rough = try PolisDirection(roughDirection: PolisDirection.RoughDirection.eastNorthEast)

        // Then
        XCTAssertEqual(sut_exact.direction(), 16.63)
        XCTAssertEqual(sut_rough.direction(), 67.5)
    }

    static var allTests = [
        ("test_PolisDirection_exactCodingSupport_shouldSucceed", test_PolisDirection_exactCodingSupport_shouldSucceed),
        ("test_PolisDirection_roughCodingSupport_shouldSucceed", test_PolisDirection_roughCodingSupport_shouldSucceed),
        ("test_PolisDirection_calculations_shouldSucceed",       test_PolisDirection_calculations_shouldSucceed),
    ]
}
