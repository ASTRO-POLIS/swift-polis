//
//  PolisConfigurationTests.swift
//  
//
//  Created by Georg Tuparev on 02/10/2021.
//

import Foundation
import XCTest

@testable import swift_polis

final class PolisConfigurationTests: XCTestCase {

    func test_frameworkSupportedAPIVersions() {
        let sut = frameworkSupportedAPIVersions()

        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.count == 2)

        let bla = supportedAPIVersions(from: " { }")
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    static var allTests = [
        ("test_frameworkSupportedAPIVersions", test_frameworkSupportedAPIVersions),
    ]

}
