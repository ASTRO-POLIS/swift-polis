//
//  PolisCommonsTests.swift
//  
//
//  Created by Georg Tuparev on 18/11/2021.
//

import XCTest
@testable import swift_polis

final class PolisCommonsTests: XCTestCase {

    let jsonEncoder = PolisJSONEncoder()
    let jsonDecoder = PolisJSONDecoder()
    var data: Data!
    var string: String!

    func test_polisDataFormat() {
        let sutJSON = PolisDataFormat.json
        let sutXML  = PolisDataFormat.xml

        XCTAssertNotEqual(sutJSON, sutXML)
        XCTAssertEqual(sutJSON.rawValue, "json")
        XCTAssertEqual(sutXML.rawValue, "xml")
    }

    func test_polisAPISupport() {
        let sutStaticData        = PolisAPISupport.staticData
        let sutDynamicStatus     = PolisAPISupport.dynamicStatus
        let sutDynamicScheduling = PolisAPISupport.dynamicScheduling

        XCTAssertNotEqual(sutStaticData, sutDynamicScheduling)

        XCTAssertEqual(sutStaticData.rawValue,        "staticData")
        XCTAssertEqual(sutDynamicStatus.rawValue,     "dynamicStatus")
        XCTAssertEqual(sutDynamicScheduling.rawValue, "dynamicScheduling")

        data   = try? jsonEncoder.encode(sutStaticData)
        string = String(data: data!, encoding: .utf8)
        XCTAssertEqual(string, "\"static_data\"")
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAPISupport.self, from: string!.data(using: .utf8)!))
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()

        data = nil
        string = nil
    }

    static var allTests = [
        ("test_polisDataFormat", test_polisDataFormat),
        ("test_polisAPISupport", test_polisAPISupport)
    ]
}
