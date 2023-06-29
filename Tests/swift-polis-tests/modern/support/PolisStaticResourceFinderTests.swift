//===----//===----------------------------------------------------------------------===//
//  PolisStaticResourceFinderTests.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
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

import XCTest

@testable import swift_polis

final class PolisStaticResourceFinderTests: XCTestCase {

    //MARK: - Setup & Teardown -
    private var version: SemanticVersion!
    private var correctImplementation: PolisImplementation!
    private var wrongFormatImplementation: PolisImplementation!
    private var wrongVersionImplementation: PolisImplementation!

    override class func setUp() {
        print("In class setUp.")
    }

    override class func tearDown() {
        print("In class tearDown.")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        print("In setUp.")
        
        version                    = PolisConstants.frameworkSupportedImplementation.last!.version
        correctImplementation      = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                                         apiSupport: PolisImplementation.APILevel.staticData,
                                                         version: version)
        wrongFormatImplementation  = PolisImplementation(dataFormat: PolisImplementation.DataFormat.xml,
                                                         apiSupport: PolisImplementation.APILevel.staticData,
                                                         version: version)
        wrongVersionImplementation = PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                                                         apiSupport: PolisImplementation.APILevel.staticData,
                                                         version: SemanticVersion(with: "12.3-beta.1")!)
    }

    override func tearDownWithError() throws {
        print("In tearDown.")

        correctImplementation      = nil
        wrongFormatImplementation  = nil
        wrongVersionImplementation = nil

        try super.tearDownWithError()
    }

    //MARK: - Tests -
    func test_PolisStaticResourceFinder_creation_shouldSucceed() {
        // Given
        let sut_wrongPath    = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/root"), supportedImplementation: correctImplementation)
        let sut_wrongFormat  = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: wrongFormatImplementation)
        let sut_wrongVersion = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: wrongVersionImplementation)
        let sut_correct      = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: correctImplementation)

        // Then
        XCTAssertNil(sut_wrongPath)
        XCTAssertNil(sut_wrongFormat)
        XCTAssertNil(sut_wrongVersion)

        XCTAssertNotNil(sut_correct)
    }

    func test_PolisStaticResourceFinder_foldersAndFiles_shouldSucceed() {
        // Given
        let siteID  = UUID()
        let dataID  = UUID()
        let sut = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: correctImplementation)

        // Then
        XCTAssert((sut != nil))
        XCTAssertEqual(sut!.rootFolder(), "/tmp/")
        XCTAssertEqual(sut!.baseFolder(), "/tmp/polis/")
        XCTAssertEqual(sut!.sitesFolder(), "/tmp/polis/\(version.description)/polis_sites/")
        XCTAssertEqual(sut!.resourcesFolder(), "/tmp/polis/\(version.description)/polis_resources/")

        XCTAssertEqual(sut!.configurationFilePath(), "/tmp/polis/polis.json")
        XCTAssertEqual(sut!.sitesDirectoryFilePath(), "/tmp/polis/polis_directory.json")
        XCTAssertEqual(sut!.observingSitesDirectoryFilePath(), "/tmp/polis/\(version.description)/polis_sites.json")
        XCTAssertEqual(sut!.resourcesDirectoryFilePath(), "/tmp/polis/\(version.description)/polis_resources.json")

        XCTAssertEqual(sut!.observingSiteFilePath(siteID: siteID.uuidString), "/tmp/polis/\(version.description)/polis_sites/\(siteID.uuidString)/\(siteID.uuidString).json")
        XCTAssertEqual(sut!.resourcesPath(uniqueName: "mead"), "/tmp/polis/\(version.description)/polis_resources/mead/")
        XCTAssertEqual(sut!.observingDataFilePath(withID: dataID, siteID: siteID.uuidString), "/tmp/polis/\(version.description)/polis_sites/\(siteID.uuidString)/\(dataID.uuidString).json")
    }

    func test_PolisStaticResourceFinder_remoteResourceFinder_shouldSucceed() {
        // Given
        let domain = "https://polis.observer/"
        let siteID = UUID()
        let dataID = UUID()
        let sut    = try? PolisRemoteResourceFinder(at: URL(string: domain)!, supportedImplementation: correctImplementation)

        // Then
        XCTAssert((sut != nil))
        XCTAssertEqual(sut!.polisDomain(), domain)
        XCTAssertEqual(sut!.baseURL(), "\(domain)polis/")
        XCTAssertEqual(sut!.sitesURL(), "\(domain)polis/\(version.description)/polis_sites/")
        XCTAssertEqual(sut!.resourcesURL(), "\(domain)polis/\(version.description)/polis_resources/")

        XCTAssertEqual(sut!.configurationURL(), "\(domain)polis/polis.json")
        XCTAssertEqual(sut!.sitesDirectoryURL(), "\(domain)polis/polis_directory.json")
        XCTAssertEqual(sut!.observingSitesDirectoryURL(), "\(domain)polis/\(version.description)/polis_sites.json")
        XCTAssertEqual(sut!.resourcesDirectoryURL(), "\(domain)polis/\(version.description)/polis_resources.json")

        XCTAssertEqual(sut!.observingSiteURL(siteID: siteID.uuidString),
                       "\(domain)polis/\(version.description)/polis_sites/\(siteID.uuidString)/\(siteID.uuidString).json")
        XCTAssertEqual(sut!.resourcesURL(uniqueName: "mead"),
                       "\(domain)polis/\(version.description)/polis_resources/mead/")
        XCTAssertEqual(sut!.observingDataURL(withID: dataID, siteID: siteID.uuidString),
                       "\(domain)polis/\(version.description)/polis_sites/\(siteID.uuidString)/\(dataID.uuidString).json")
    }

    static var allTests = [
        ("test_PolisStaticResourceFinder_creation_shouldSucceed",             test_PolisStaticResourceFinder_creation_shouldSucceed),
        ("test_PolisStaticResourceFinder_foldersAndFiles_shouldSucceed",      test_PolisStaticResourceFinder_foldersAndFiles_shouldSucceed),
        ("test_PolisStaticResourceFinder_remoteResourceFinder_shouldSucceed", test_PolisStaticResourceFinder_remoteResourceFinder_shouldSucceed)
    ]
}


    //MARK: - Templates
    /*
     func test_Type_stateUnderTest_expectedBehavior() throws {
     // Given

     // When

     // Then

     }

     func testExampleWithTearDown() throws {
     print("Starting test.")
     addTeardownBlock {
     print("In first tearDown block.")
     }
     print("In middle of test.")
     addTeardownBlock {
     print("In second tearDown block.")
     }
     print("Finishing test.")
     }

     func testPerformanceExample() throws {

     self.measure {

     }
     }
     */

/* NAMING RULES
 As your skill with testing increases, you might find it useful to adopt Roy Osherove’s naming convention for tests:
 [UnitOfWork_StateUnderTest_ExpectedBehavior].

 If you follow that precisely it would create test method names like this:
 test_Hater_AfterHavingAGoodDay_ShouldNotBeHating().

 *Note:* Mixing PascalCase and snake_case might hurt your head at first, but at least it makes clear the
 UnitOfWork – StateUnderTest – ExpectedBehavior
 separation at a glance. You might also see camelCase being used, which would give
 test_Hater_afterHavingAGoodDay_shouldNotBeHating()
 */
