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

    private var correctImplementation: PolisSupportedImplementation!
    private var wrongFormatImplementation: PolisSupportedImplementation!
    private var wrongVersionImplementation: PolisSupportedImplementation!

    func test_PolisStaticResourceFinderCreation() {
        let sut_wrongPath    = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/root"), supportedImplementation: correctImplementation)
        let sut_wrongFormat  = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: wrongFormatImplementation)
        let sut_wrongVersion = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: wrongVersionImplementation)
        let sut_correct      = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: correctImplementation)

        XCTAssertNil(sut_wrongPath)
        XCTAssertNil(sut_wrongFormat)
        XCTAssertNil(sut_wrongVersion)
        XCTAssert(sut_correct != nil)
    }

    func test_polisFolders() {
        let sut = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: correctImplementation)

        XCTAssert((sut != nil))
        XCTAssertEqual(sut!.rootPolisFolder(), "/tmp/")
        XCTAssertEqual(sut!.basePolisFolder(), "/tmp/polis/")
    }

    override func setUp() {
        super.tearDown()

        correctImplementation      = PolisSupportedImplementation(dataFormat: PolisDataFormat.json, apiSupport: PolisAPISupport.staticData, version: SemanticVersion(with: "0.1-alpha.1")!)
        wrongFormatImplementation  = PolisSupportedImplementation(dataFormat: PolisDataFormat.xml,  apiSupport: PolisAPISupport.staticData, version: SemanticVersion(with: "0.1-alpha.1")!)
        wrongVersionImplementation = PolisSupportedImplementation(dataFormat: PolisDataFormat.json, apiSupport: PolisAPISupport.staticData, version: SemanticVersion(with: "0.1-beta.1")!)
    }

    override func tearDown() {
        correctImplementation      = nil
        wrongFormatImplementation  = nil
        wrongVersionImplementation = nil
        
     super.tearDown()
    }

    static var allTests = [
        ("test_PolisStaticResourceFinderCreation", test_PolisStaticResourceFinderCreation),
        ("test_polisFolders",test_polisFolders),
    ]

}
