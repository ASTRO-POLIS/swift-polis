//
//  UtilitiesTests.swift
//  
//
//  Created by Georg Tuparev on 05/02/2021.
//

import Foundation

import XCTest
@testable import swift_polis

final class UtilitiesTests: XCTestCase {

    func test_utilityFolderPaths() {
        let sut1 = rootPolisFolder(rootPath: URL(fileURLWithPath: "/tmp"))
        let sut2 = polisSiteDirectory(rootPath: URL(fileURLWithPath: "/tmp/"))

        XCTAssertEqual(sut1.path, "/tmp/polis")
        XCTAssertEqual(sut2.path, "/tmp/polis/polis_sites")
    }

    func test_utilityFilePaths() {
        let sut1 = rootPolisFile(rootPath: URL(fileURLWithPath: "/tmp"))
        let sut2 = rootPolisDirectoryFile(rootPath: URL(fileURLWithPath: "/tmp/"))
        let sut3 = observingSitesDirectoryFile(rootPath: URL(fileURLWithPath: "/tmp/"))
        let sut4 = observingSiteFile(rootPath: URL(fileURLWithPath: "/tmp/"), siteID: "123456")

        XCTAssertEqual(sut1.path, "/tmp/polis/polis.json")
        XCTAssertEqual(sut2.path, "/tmp/polis/polis_directory.json")
        XCTAssertEqual(sut3.path, "/tmp/polis/observing_sites_directory.json")
        XCTAssertEqual(sut4.path, "/tmp/polis/polis_sites/123456.json")
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    static var allTests = [
        ("test_utilityFolderPaths", test_utilityFolderPaths),
        ("test_utilityFilePaths", test_utilityFilePaths),
    ]
}
