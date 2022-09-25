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

    func test_PolisStaticResourceFinderCreation() {
        let sut_wrongPath    = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/root"), supportedImplementation: correctImplementation)
        let sut_wrongFormat  = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: wrongFormatImplementation)
        let sut_wrongVersion = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: wrongVersionImplementation)
        let sut_correct      = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: correctImplementation)

        XCTAssertNil(sut_wrongPath)
        XCTAssertNil(sut_wrongFormat)
        XCTAssertNil(sut_wrongVersion)

        XCTAssertNotNil(sut_correct)
    }

    func test_PolisFoldersAndFiles() {
        let siteID  = UUID()
        let dataID  = UUID()
        let sut = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: correctImplementation)

        XCTAssert((sut != nil))
        XCTAssertEqual(sut!.rootFolder(), "/tmp/")
        XCTAssertEqual(sut!.baseFolder(), "/tmp/polis/")
        XCTAssertEqual(sut!.sitesFolder(), "/tmp/polis/\(version.description)/polis_sites/")
        XCTAssertEqual(sut!.resourcesFolder(), "/tmp/polis/\(version.description)/polis_resources/")

        XCTAssertEqual(sut!.configurationFilePath(), "/tmp/polis/polis.json")
        XCTAssertEqual(sut!.sitesDirectoryFilePath(), "/tmp/polis/polis_directory.json")
        XCTAssertEqual(sut!.observingSitesDirectoryFilePath(), "/tmp/polis/\(version.description)/polis_sites.json")

        XCTAssertEqual(sut!.observingSiteFilePath(siteID: siteID.uuidString), "/tmp/polis/\(version.description)/polis_sites/\(siteID.uuidString)/\(siteID.uuidString).json")
        //TODO: Understand why the test below fails!
         XCTAssertEqual(sut!.resourcesPath(uniqueName: "mead"), "/tmp/polis/\(version.description)/polis_resources/mead/")
        XCTAssertEqual(sut!.observingDataFilePath(withID: dataID, siteID: siteID.uuidString), "/tmp/polis/\(version.description)/polis_sites/\(siteID.uuidString)/\(dataID.uuidString).json")
    }

    func test_PolisRemoteResourceFinder() {
        let domain = "https://polis.observer/"
        let siteID = UUID()
        let dataID = UUID()
        let sut    = try? PolisRemoteResourceFinder(at: URL(string: domain)!, supportedImplementation: correctImplementation)

        XCTAssert((sut != nil))
        XCTAssertEqual(sut!.polisDomain(), domain)
        XCTAssertEqual(sut!.baseURL(), "\(domain)polis/")
        XCTAssertEqual(sut!.sitesURL(), "\(domain)polis/\(version.description)/polis_sites/")
        XCTAssertEqual(sut!.resourcesURL(), "\(domain)polis/\(version.description)/polis_resources/")

        XCTAssertEqual(sut!.configurationURL(), "\(domain)polis/polis.json")
        XCTAssertEqual(sut!.sitesDirectoryURL(), "\(domain)polis/polis_directory.json")
        XCTAssertEqual(sut!.observingSitesDirectoryURL(), "\(domain)polis/\(version.description)/polis_sites.json")

        XCTAssertEqual(sut!.observingSiteURL(siteID: siteID.uuidString), "\(domain)polis/\(version.description)/polis_sites/\(siteID.uuidString)/\(siteID.uuidString).json")
        //TODO: Understand why the test below fails!
         XCTAssertEqual(sut!.resourcesURL(uniqueName: "mead"), "\(domain)polis/\(version.description)/polis_resources/mead/")
        XCTAssertEqual(sut!.observingDataURL(withID: dataID, siteID: siteID.uuidString), "\(domain)polis/\(version.description)/polis_sites/\(siteID.uuidString)/\(dataID.uuidString).json")
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
        ("test_PolisStaticResourceFinderCreation", test_PolisStaticResourceFinderCreation),
        ("test_PolisFoldersAndFiles",              test_PolisFoldersAndFiles),
        ("test_PolisRemoteResouceFinder",          test_PolisRemoteResourceFinder),
    ]

}
