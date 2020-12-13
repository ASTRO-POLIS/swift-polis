import XCTest
@testable import swift_polis

final class ServiceDiscoveryTests: XCTestCase {

    let jsonEncoder = PolisJSONEncoder()
    let jsonDecoder = PolisJSONDecoder()
    var data: Data!
    var string: String!

    func testPolisDataFormat() {
        let j = PolisDataFormat.json
        let x = PolisDataFormat.xml

        XCTAssertFalse(j == x)

        // Encoding and decoding
        data = try? jsonEncoder.encode(j)
        string = String(data: data!, encoding: .utf8)
        let j1 = try! jsonDecoder.decode(PolisDataFormat.self, from: string!.data(using: .utf8)!)
        XCTAssertEqual(j, j1)

        XCTAssertEqual(j.description, "json")
        XCTAssertEqual(x.description, "xml")
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
        ("testPolisDataFormat", testPolisDataFormat)
    ]
}
