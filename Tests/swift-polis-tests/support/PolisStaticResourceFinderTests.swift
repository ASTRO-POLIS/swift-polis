//===----//===----------------------------------------------------------------------===//
//  PolisStaticResourceFinderTests.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2024 Tuparev Technologies and the ASTRO-POLIS project
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
        let facilityID = UUID()
        let dataID     = UUID()
        let sut        = try? PolisFileResourceFinder(at: URL(fileURLWithPath: "/tmp"),  supportedImplementation: correctImplementation)

        // Then
        XCTAssert((sut != nil))
        XCTAssertEqual(sut!.rootFolder(), "/tmp/")
        XCTAssertEqual(sut!.baseFolder(), "/tmp/polis/")
        XCTAssertEqual(sut!.observingFacilitiesFolder(), "/tmp/polis/\(version.description)/polis_observing_facilities/")
        XCTAssertEqual(sut!.resourcesFolder(), "/tmp/polis/\(version.description)/polis_resources/")

        XCTAssertEqual(sut!.configurationFile(), "/tmp/polis/polis.json")
        XCTAssertEqual(sut!.polisProviderDirectoryFile(), "/tmp/polis/polis_directory.json")
        XCTAssertEqual(sut!.observingFacilitiesDirectoryFile(), "/tmp/polis/\(version.description)/polis_observing_facilities.json")
        XCTAssertEqual(sut!.resourcesDirectoryFile(), "/tmp/polis/\(version.description)/polis_resources.json")

        XCTAssertEqual(sut!.observingFacilityFile(observingFacilityID: facilityID), "/tmp/polis/\(version.description)/polis_observing_facilities/\(facilityID.uuidString)/\(facilityID.uuidString).json")
        XCTAssertEqual(sut!.observingDataFile(withID: dataID, observingFacilityID: facilityID), "/tmp/polis/\(version.description)/polis_observing_facilities/\(facilityID.uuidString)/\(dataID.uuidString).json")
    }

    func test_PolisStaticResourceFinder_remoteResourceFinder_shouldSucceed() {
        // Given
        let domain     = "https://polis.observer/"
        let facilityID = UUID()
        let dataID     = UUID()
        let sut        = try? PolisRemoteResourceFinder(at: URL(string: domain)!, supportedImplementation: correctImplementation)

        // Then
        XCTAssert((sut != nil))
        XCTAssertEqual(sut!.polisDomain(), domain)
        XCTAssertEqual(sut!.baseURL(), "\(domain)polis/")
        XCTAssertEqual(sut!.observingFacilitiesURL(), "\(domain)polis/\(version.description)/polis_observing_facilities/")
        XCTAssertEqual(sut!.resourcesURL(), "\(domain)polis/\(version.description)/polis_resources/")

        XCTAssertEqual(sut!.configurationURL(), "\(domain)polis/polis.json")
        XCTAssertEqual(sut!.polisProviderDirectoryURL(), "\(domain)polis/polis_directory.json")
        XCTAssertEqual(sut!.observingFacilitiesDirectoryURL(), "\(domain)polis/\(version.description)/polis_observing_facilities.json")

        XCTAssertEqual(sut!.observingFacilityURL(observingFacilityID: facilityID),
                       "\(domain)polis/\(version.description)/polis_observing_facilities/\(facilityID)/\(facilityID.uuidString).json")
        XCTAssertEqual(sut!.observingDataURL(withID: dataID, observingFacilityID: facilityID),
                       "\(domain)polis/\(version.description)/polis_observing_facilities/\(facilityID.uuidString)/\(dataID.uuidString).json")
    }

    static var allTests = [
        ("test_PolisStaticResourceFinder_creation_shouldSucceed",             test_PolisStaticResourceFinder_creation_shouldSucceed),
        ("test_PolisStaticResourceFinder_foldersAndFiles_shouldSucceed",      test_PolisStaticResourceFinder_foldersAndFiles_shouldSucceed),
        ("test_PolisStaticResourceFinder_remoteResourceFinder_shouldSucceed", test_PolisStaticResourceFinder_remoteResourceFinder_shouldSucceed)
    ]
}
