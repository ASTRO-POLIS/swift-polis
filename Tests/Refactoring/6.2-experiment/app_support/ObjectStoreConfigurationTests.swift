//===----------------------------------------------------------------------===//
//  ObjectStoreConfigurationTests.swift
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
//  Created by Georg Tuparev on 08/06/2025.
//


import XCTest

@testable import swift_polis

final class ObjectStoreConfigurationTests : XCTestCase {
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
    @MainActor func test_ObjectStoreConfiguration_creation_shouldSucceed() throws {
        // Given
        let sut = ObjectStoreConfiguration()

        // Then
        XCTAssertNotNil(sut)
    }


    func test_ObjectStoreConfiguration_createStore_shouldSucceed() async throws {
        // Given
        let sut = await ObjectStoreConfiguration()

        // When
        try await sut.setLocalPolisRootFolder("/tmp")
        let store = try await sut.objectStore()

        // Then
        XCTAssertNotNil(store)
    }

//    static let allTests = [
//        ("test_ObjectStoreConfiguration_creation_shouldSucceed",    test_ObjectStoreConfiguration_creation_shouldSucceed),
//        ("test_ObjectStoreConfiguration_createStore_shouldSucceed", test_ObjectStoreConfiguration_createStore_shouldSucceed),
//    ]
}
