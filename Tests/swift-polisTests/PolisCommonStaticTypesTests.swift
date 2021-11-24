//
//  PolisCommonStaticTypesTests.swift
//  
//
//  Created by Georg Tuparev on 21/10/2021.
//

import XCTest
@testable import swift_polis

final class PolisCommonStaticTypesTests: XCTestCase {
 
    private var jsonEncoder: PolisJSONEncoder!
    private var jsonDecoder: PolisJSONDecoder!
    private var data: Data!
    private var string: String!

    func test_polisAttributesCodingAndDecoding() {
        let sut = PolisItemAttributes(status: PolisLifecycleStatus.active, lastUpdate: Date(), name: "TestAttributes", shortDescription: "Testing attributes")

        XCTAssertNotNil(sut)

        data   = try? jsonEncoder.encode(sut)
        string = String(data: data!, encoding: .utf8)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisItemAttributes.self, from: string!.data(using: .utf8)!))
    }

    func test_polisCommunicationCodingAndDecoding() {
        let sut_twitter = PolisCommunication.twitter(userName: "@polis")

        XCTAssertNotNil(sut_twitter)

        data   = try? jsonEncoder.encode(sut_twitter)
        string = String(data: data!, encoding: .utf8)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisCommunication.self, from: string!.data(using: .utf8)!))
    }

    //TODO: Test POLIS Communication versions that expect automatically adding "@" in some of the id's!

    func test_polisProviderCodingAndDecoding() {
        let sut_pub = PolisProviderType.public
        let sut_mir = PolisProviderType.mirror(id: "abc")

        XCTAssertNotNil(sut_pub)
        XCTAssertNotNil(sut_mir)

        data   = try? jsonEncoder.encode(sut_pub)
        string = String(data: data!, encoding: .utf8)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisProviderType.self, from: string!.data(using: .utf8)!))

        data   = try? jsonEncoder.encode(sut_mir)
        string = String(data: data!, encoding: .utf8)

        XCTAssertNoThrow(try jsonDecoder.decode(PolisProviderType.self, from: string!.data(using: .utf8)!))
    }

    override func setUp() {
        super.setUp()

        jsonEncoder = PolisJSONEncoder()
        jsonDecoder = PolisJSONDecoder()
  }
    
    override func tearDown() {
        data = nil
        string = nil
        jsonEncoder = nil
        jsonDecoder = nil
        
        super.tearDown()
    }
    
    static var allTests = [
        ("test_polisAttributesCodingAndDecoding",    test_polisAttributesCodingAndDecoding),
        ("test_polisProviderCodingAndDecoding",      test_polisProviderCodingAndDecoding),
        ("test_polisCommunicationCodingAndDecoding", test_polisCommunicationCodingAndDecoding),
    ]
}
