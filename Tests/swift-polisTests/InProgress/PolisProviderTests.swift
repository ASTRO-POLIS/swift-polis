//
//  PolisProviderTests.swift
//  
//
//  Created by Georg Tuparev on 29/08/2022.
//

import XCTest

class PolisProviderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

//    func testPolisProviderCodingAndDecoding() {
//        let sut_pub = PolisProviderType.public
//        let sut_mir = PolisProviderType.mirror(id: "abc")
//
//        XCTAssertNotNil(sut_pub)
//        XCTAssertNotNil(sut_mir)
//
//        data   = try? jsonEncoder.encode(sut_pub)
//        string = String(data: data!, encoding: .utf8)
//
//        XCTAssertNoThrow(try jsonDecoder.decode(PolisProviderType.self, from: string!.data(using: .utf8)!))
//
//        data   = try? jsonEncoder.encode(sut_mir)
//        string = String(data: data!, encoding: .utf8)
//
//        XCTAssertNoThrow(try jsonDecoder.decode(PolisProviderType.self, from: string!.data(using: .utf8)!))
//    }

//    func testPolisManufacturerCodingAndDecoding() {
//        let sut_attributes = PolisIdentification(id: UUID(), status: PolisIdentification.LifecycleStatus.inactive, lastUpdate: Date(), name: "Apple", automationLabel: "APPL")
//        let sut_admin      = PolisAdminContact(name: "Tim Cook", email: "tim@apple.com", additionalCommunicationChannels: [PolisAdminContact.Communication](), notes: "The big boss")
//        let sut            = PolisManufacturer(identification: sut_attributes, uniqueName: "apple", url: URL(string: "https://www.apple.com"), contact: sut_admin)
//
//        XCTAssertNotNil(sut)
//
//        data   = try? jsonEncoder.encode(sut)
//        string = String(data: data!, encoding: .utf8)
//        XCTAssertNoThrow(try jsonDecoder.decode(PolisManufacturer.self, from: string!.data(using: .utf8)!))
//    }
//

}
