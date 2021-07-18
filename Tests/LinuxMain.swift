import XCTest

import swift_polisTests

var tests = [XCTestCaseEntry]()
tests += ServiceDiscoveryTests.allTests()
tests += UtilitiesTests.allTests()
tests += PolisPersistentContainerTests.allTests()

XCTMain(tests)
