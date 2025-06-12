//===----------------------------------------------------------------------===//
//  PolisLogger.swift
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
//
//  Created by Georg Tuparev on 20/10/2024
//

import XCTest

@testable import swift_polis

final class PolisLoggerTests: XCTestCase {
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
    }

    override func tearDownWithError() throws {
        print("In tearDown.")

        try super.tearDownWithError()
    }

    //MARK: - Tests -
    func test_PolisLogger_sharedInstance_shouldExist() throws {
        // Given
        let sut = PolisLogger.shared

        // Then
        XCTAssertNotNil(sut)
    }

    func test_PolisLogger_creatingLogs_shouldSucceed() throws {
        // Given
        let sut = PolisLogger()

        // When
        sut.shouldLog = true

        sut.info("blah")
        sut.info("blah blah")
        sut.warning("foo")
        sut.error("bar")

        // Then
        XCTAssertEqual(sut.infoMessages().count, 2)
        XCTAssertEqual(sut.warningMessages().count, 1)
        XCTAssertEqual(sut.errorMessages().count, 1)
    }

    func test_PolisLogger_flushingLogs_shouldSucceed() throws {
        // Given
        let sut = PolisLogger()

        // When
        sut.shouldLog = true

        sut.info("blah")
        sut.info("blah blah")
        sut.warning("foo")
        sut.error("bar")

        sut.flush()

        // Then
        XCTAssertEqual(sut.infoMessages().count, 0)
        XCTAssertEqual(sut.warningMessages().count, 0)
        XCTAssertEqual(sut.errorMessages().count, 0)
    }


    static var allTests = [
        ("test_PolisLogger_sharedInstance_shouldExist", test_PolisLogger_sharedInstance_shouldExist),
        ("test_PolisLogger_creatingLogs_shouldSucceed", test_PolisLogger_creatingLogs_shouldSucceed),
        ("test_PolisLogger_flushingLogs_shouldSucceed", test_PolisLogger_flushingLogs_shouldSucceed),
    ]
}
