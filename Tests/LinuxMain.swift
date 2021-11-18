import XCTest

import swift_polisTests

var tests = [XCTestCaseEntry]()
tests += ServiceDiscoveryTests.allTests()
tests += PolisPersistentContainerTests.allTests()
tests += PolisStaticResourceFinderTests.allTests()
tests += PolisCommonStaticTypesTests.allTests()
tests += PolisCommonsTests.allTests()

XCTMain(tests)
