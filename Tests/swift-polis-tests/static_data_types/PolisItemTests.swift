//===----------------------------------------------------------------------===//
//  PolisItemTests.swift
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
import SoftwareEtudesUtilities

@testable import swift_polis

final class PolisItemTests: XCTestCase {
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
    func test_Owner_codingSupport_shouldSucceed() throws {
        // Given
        let sut = StaticDataTypeTestingSupport.exampleOwner()

        // When
        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisOwner.self, from: string!.data(using: .utf8)!))
        XCTAssertEqual(sut.ownershipType, .government)
        XCTAssertEqual(sut.personalOwnerIDs!.count, 1)
        XCTAssertEqual(sut.organisationalOwnerIDs?.count, 2)
    }


    static var allTests = [
        ("test_Owner_codingSupport_shouldSucceed", test_Owner_codingSupport_shouldSucceed),
    ]
}
