import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        XCTestCase(PolisPersistentContainerTests),
        XCTestCase(ServiceDiscoveryTests.allTests),
        XCTestCase(PolisStaticResourceFinderTests),
        XCTestCase(PolisCommonStaticTypesTests),
    ]
}
#endif
