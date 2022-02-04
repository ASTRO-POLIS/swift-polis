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

import XCTest
@testable import swift_polis

final class PolisPersistentContainerTests: XCTestCase {

    private static var correctRandomRootFolder = URL(string: "/tmp/\(UUID())")

//    func test_initWithWrongRoot_shouldReturnNil() {
//        guard let url = URL(string: "file:/does/not/exist") else { XCTFail(); return }
//
//        let sut = PolisPersistentContainer(rootPath: url)
//        XCTAssertNil(sut)
//
//        //TODO: Not completely tested, because the class' init is not finished!
//    }
//
//    func test_initWithCorrectEmptyRootFolderAndNoCreation_shouldReturnNil() {
//        guard let url = PolisPersistentContainerTests.correctRandomRootFolder else { XCTFail(); return }
//
//        let sut = PolisPersistentContainer(rootPath: url)
//        XCTAssertNil(sut)
//
//
//        //TODO: Not completely tested, because the class' init is not finished!
//    }
//
//    func test_initWithCorrectEmptyRootFolderAndCreation_shouldReturnNotNil() {
//        guard let url = PolisPersistentContainerTests.correctRandomRootFolder else { XCTFail(); return }
//
//        let sut1 = PolisPersistentContainer(rootPath: url, createIfEmpty: true)  // First create a new service provider
//        let sut2 = PolisPersistentContainer(rootPath: url)                       // Now read the newly created provider
//
//        XCTAssertNotNil(sut1)
//        XCTAssertNotNil(sut2)
//  }
//
    override func setUp() {
        let fm               = FileManager.default
        var isDir: ObjCBool  = false

        super.setUp()

        let urlToCreate = PolisPersistentContainerTests.correctRandomRootFolder!.path

        if !fm.fileExists(atPath: urlToCreate, isDirectory: &isDir) {
            do    { try fm.createDirectory(atPath: urlToCreate, withIntermediateDirectories: true, attributes: nil) }
            catch {
                print(">>>> Exception thrown (cannot create root and observing sites polis folders): \(error)")
            }
        }

    }

    override func tearDown() {
        let fm = FileManager.default

        try? fm.removeItem(atPath: PolisPersistentContainerTests.correctRandomRootFolder!.path)

        super.tearDown()
    }

//    static var allTests = [
//        ("test_initWithWrongRoot_shouldReturnNil", test_initWithWrongRoot_shouldReturnNil),
//        ("test_initWithCorrectEmptyRootFolderAndNoCreation_shouldReturnNil", test_initWithCorrectEmptyRootFolderAndNoCreation_shouldReturnNil),
//        ("test_initWithCorrectEmptyRootFolderAndCreation_shouldReturnNotNil", test_initWithCorrectEmptyRootFolderAndCreation_shouldReturnNotNil),
//    ]
}
