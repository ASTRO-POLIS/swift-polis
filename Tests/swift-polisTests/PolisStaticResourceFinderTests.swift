//
//  PolisStaticResourceFinderTests.swift
//  
//
//  Created by Georg Tuparev on 13/10/2021.
//

import Foundation
import SoftwareEtudes
import XCTest

@testable import swift_polis

final class PolisStaticResourceFinderTests: XCTestCase {

    func test_PolisStaticResourceFinderCreation() {
        let sut_wrongPath    = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/root"), dataFormat: PolisDataFormat.json, version: SemanticVersion(with: "0.1-alpha.1")!)
        let sut_wrongFormat  = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  dataFormat: PolisDataFormat.xml,  version: SemanticVersion(with: "0.1-alpha.1")!)
        let sut_wrongVersion = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  dataFormat: PolisDataFormat.json, version: SemanticVersion(with: "0.1-beta.1")!)
        let sut_correct      = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  dataFormat: PolisDataFormat.json, version: SemanticVersion(with: "0.1-alpha.1")!)

        XCTAssertNil(sut_wrongPath)
        XCTAssertNil(sut_wrongFormat)
        XCTAssertNil(sut_wrongVersion)
        XCTAssert(sut_correct != nil)
    }

    func test_polisFolders() {
        let sut = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  dataFormat: PolisDataFormat.json, version: SemanticVersion(with: "0.1-alpha.1")!)

        XCTAssert((sut != nil))
        XCTAssertEqual(sut!.rootPolisFolder(), "/tmp/")
        XCTAssertEqual(sut!.basePolisFolder(), "/tmp/polis/")
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    static var allTests = [
        ("test_PolisStaticResourceFinderCreation", test_PolisStaticResourceFinderCreation),
        ("test_polisFolders",test_polisFolders),
    ]

}
