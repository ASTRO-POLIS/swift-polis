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


import Foundation
import SoftwareEtudesUtilities
import XCTest

@testable import swift_polis

final class PolisStaticResourceFinderTests: XCTestCase {

    private var version: SemanticVersion!
    private var correctImplementation: PolisImplementationInfo!
    private var wrongFormatImplementation: PolisImplementationInfo!
    private var wrongVersionImplementation: PolisImplementationInfo!

    func testPolisStaticResourceFinderCreation() {
        let sut_wrongPath    = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/root"), supportedImplementation: correctImplementation)
        let sut_wrongFormat  = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: wrongFormatImplementation)
        let sut_wrongVersion = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: wrongVersionImplementation)
        let sut_correct      = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: correctImplementation)

        XCTAssertNil(sut_wrongPath)
        XCTAssertNil(sut_wrongFormat)
        XCTAssertNil(sut_wrongVersion)
        XCTAssert(sut_correct != nil)
    }

    func testPolisFoldersAndFiles() {
        let siteID  = UUID()
        let dataID  = UUID()
        let sut = try? PolisStaticResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: correctImplementation)

        XCTAssert((sut != nil))
        XCTAssertEqual(sut!.rootPolisFolder(), "/tmp/")
        XCTAssertEqual(sut!.basePolisFolder(), "/tmp/polis/")
        XCTAssertEqual(sut!.sitesPolisFolder(), "/tmp/polis/\(version.description)/polis_sites/")

        XCTAssertEqual(sut!.polisConfigurationFilePath(), "/tmp/polis/polis.json")
        XCTAssertEqual(sut!.polisProviderSitesDirectoryFilePath(), "/tmp/polis/\(version.description)/polis_directory.json")
        XCTAssertEqual(sut!.polisObservingSitesDirectoryFilePath(), "/tmp/polis/\(version.description)/polis_sites.json")
        XCTAssertEqual(sut!.polisObservingDataFilePath(withID: dataID, siteID: siteID.uuidString), "/tmp/polis/\(version.description)/polis_sites/\(siteID.uuidString)/\(dataID.uuidString).json")
    }

    override func setUp() {
        super.tearDown()

        version                    = frameworkSupportedImplementation.last!.version
        correctImplementation      = PolisImplementationInfo(dataFormat: PolisImplementationInfo.DataFormat.json,
                                                             apiSupport: PolisImplementationInfo.APILevel.staticData,
                                                             version: version)
        wrongFormatImplementation  = PolisImplementationInfo(dataFormat: PolisImplementationInfo.DataFormat.xml,
                                                             apiSupport: PolisImplementationInfo.APILevel.staticData,
                                                             version: version)
        wrongVersionImplementation = PolisImplementationInfo(dataFormat: PolisImplementationInfo.DataFormat.json,
                                                             apiSupport: PolisImplementationInfo.APILevel.staticData,
                                                             version: SemanticVersion(with: "12.3-beta.1")!)
    }

    override func tearDown() {
        correctImplementation      = nil
        wrongFormatImplementation  = nil
        wrongVersionImplementation = nil
        
        super.tearDown()
    }

    static var allTests = [
        ("testPolisStaticResourceFinderCreation", testPolisStaticResourceFinderCreation),
        ("testPolisFoldersAndFiles",              testPolisFoldersAndFiles),
    ]

}
