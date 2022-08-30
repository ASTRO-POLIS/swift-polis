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

import swift_polisTests

var tests = [XCTestCaseEntry]()
tests += PolisUtilitiesTests.allTests()
tests += PolisCommonTypesTests.allTests()
tests += PolisServiceProviderTests.allTests()
tests += PolisItemOwnerTests.allTests()

tests += PolisProviderTests.allTests()
tests += PolisStaticResourceFinderTests.allTests()
tests += PolisCommonsTests.allTests()

XCTMain(tests)
