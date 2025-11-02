//===----------------------------------------------------------------------===//
//  PolisIdentityTests.swift
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

import Foundation
import SoftwareEtudesUtilities

import XCTest

@testable import swift_polis

final class PolisIdentityTests: XCTestCase {

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
        data        = nil
        string      = nil
        jsonEncoder = nil
        jsonDecoder = nil

        try super.tearDownWithError()
    }

    private var jsonEncoder: PrettyJSONEncoder!
    private var jsonDecoder: PrettyJSONDecoder!
    private var data: Data!
    private var string: String!


    //MARK: - Tests -
    func test_PolisIdentity_codingSupport_shouldSucceed() throws {
        // Given
        let sut = StaticDataTypeTestingSupport.examplePolisIdentityBAO()

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisIdentity.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisIdentity_EquatableCompliance_shouldComply() throws {
        // Given
        let sut1 = StaticDataTypeTestingSupport.examplePolisIdentityBAO()
        var sut2 = sut1

        // When
        sut2.name = "New name"

        // Then
        XCTAssertEqual(sut1, sut1)
        XCTAssertNotEqual(sut1, sut2)
    }

    static let allTests = [
        ("test_PolisIdentity_codingSupport_shouldSucceed",      test_PolisIdentity_codingSupport_shouldSucceed),
        ("test_PolisIdentity_EquatableCompliance_shouldComply", test_PolisIdentity_EquatableCompliance_shouldComply),
    ]

}

