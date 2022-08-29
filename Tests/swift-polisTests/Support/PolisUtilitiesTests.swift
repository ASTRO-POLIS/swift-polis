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
@testable import swift_polis

class PolisUtilitiesTests: XCTestCase {

    // This is a set of very simple test cases that do not need special setup and do not change the outcome of other
    // tests.
    
    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func testMustStartWithAtSignExtension() throws {
        XCTAssertEqual("@bla", "bla".mustStartWithAtSign())
        XCTAssertEqual("@bla", "@bla".mustStartWithAtSign())
    }

    func testNormalisedPath() throws {
        XCTAssertEqual("/a/b/c/", normalisedPath("/a/b/c"))
        XCTAssertEqual("/a/b/c/", normalisedPath("/a/b/c/"))
    }

    static var allTests = [
        ("testMustStartWithAtSignExtension", testMustStartWithAtSignExtension),
        ("testNormalisedPath",               testNormalisedPath),
    ]
}
