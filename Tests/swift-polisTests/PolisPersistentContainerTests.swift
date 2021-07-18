//
//  PolisPersistentContainerTests.swift
//  
//
//  Created by Georg Tuparev on 16/07/2021.
//

import Foundation

import XCTest
@testable import swift_polis

final class PolisPersistentContainerTests: XCTestCase {

    private static var correctRandomRootFolder = URL(string: "/tmp/\(UUID())")

    func test_initWithWrongRoot_shouldReturnNil() {
        guard let url = URL(string: "file:/does/not/exist") else { XCTFail(); return }

        let sut = PolisPersistentContainer(rootPath: url)
        XCTAssertNil(sut)

        //TODO: Not completely tested, because the class' init is not finished!
    }

    func test_initWithCorrectEmptyRootFolderAndNoCreation_shouldReturnNil() {
        guard let url = PolisPersistentContainerTests.correctRandomRootFolder else { XCTFail(); return }

        let sut = PolisPersistentContainer(rootPath: url)
        XCTAssertNil(sut)


        //TODO: Not completely tested, because the class' init is not finished!
    }

    func test_initWithCorrectEmptyRootFolderAndCreation_shouldReturnNotNil() {
        guard let url = PolisPersistentContainerTests.correctRandomRootFolder else { XCTFail(); return }

        let sut = PolisPersistentContainer(rootPath: url, createIfEmpty: true)
        XCTAssertNotNil(sut)
  }

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
        super.tearDown()

        let fm = FileManager.default

        try? fm.removeItem(atPath: PolisPersistentContainerTests.correctRandomRootFolder!.path)
    }

    static var allTests = [
        ("test_initWithWrongRoot_shouldReturnNil", test_initWithWrongRoot_shouldReturnNil),
        ("test_initWithCorrectEmptyRootFolderAndNoCreation_shouldReturnNil", test_initWithCorrectEmptyRootFolderAndNoCreation_shouldReturnNil),
        ("test_initWithCorrectEmptyRootFolderAndCreation_shouldReturnNotNil", test_initWithCorrectEmptyRootFolderAndCreation_shouldReturnNotNil),
    ]
}
