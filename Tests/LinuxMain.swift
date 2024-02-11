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


import XCTest

import swift_polisTests

var tests = [XCTestCaseEntry]()

// service_provider
tests += PolisImplementationTests.allTests()

// support
tests += PolisStaticResourceFinderTests.allTests()

// core
tests += PolisPropertyValueTests.allTests()
tests += PolisDirectionTests.allTests()
tests += PolisVisitingHoursTests.allTests()

XCTMain(tests)
