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

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        // service_provider
        XCTestCase(PolisImplementationTests),
        
        // support
        XCTestCase(PolisImplementationTests),
        XCTestCase(PolisStaticResourceFinderTests),

        // core
        XCTestCase(PolisDirectionTests),
        XCTestCase(PolisPropertyValueTests),
        XCTestCase(PolisVisitingHoursTests),
    ]
}
#endif
