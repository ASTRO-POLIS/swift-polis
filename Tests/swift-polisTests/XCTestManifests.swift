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

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        XCTestCase(PolisUtilitiesTests),
        XCTestCase(PolisCommonTypesTests),
        XCTestCase(PolisServiceProviderTests.allTests),
        XCTestCase(PolisItemOwnerTests),
        XCTestCase(PolisItemTests),
        XCTestCase(PolisManufacturerTests),
        
        XCTestCase(PolisProviderTests),
        XCTestCase(PolisStaticResourceFinderTests),
        XCTestCase(PolisCommonsTests),
    ]
}
#endif
