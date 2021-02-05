import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ServiceDiscoveryTests.allTests),
        XCTestCase(UtilitiesTests.allTests),
    ]
}
#endif
