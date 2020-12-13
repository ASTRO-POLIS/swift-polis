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

    func testPolisProvider() {
        let pub = PolisProvider.public
        let mir = PolisProvider.mirror(identifier: "abc")

        data = try? jsonEncoder.encode(pub)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisProvider.self, from: string!.data(using: .utf8)!))

        data = try? jsonEncoder.encode(mir)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisProvider.self, from: string!.data(using: .utf8)!))
    }

    func testCommunicating() {
        let t = Communicating.twitter(userName: "@polis")

        data = try? jsonEncoder.encode(t)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(Communicating.self, from: string!.data(using: .utf8)!))
    }

    func testPolisContact() {
        let c = PolisContact(name: "polis", email: "polis@observer.net", additionalContacts: [Communicating.instagram(userName: "@polis")])

        data = try? jsonEncoder.encode(c)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisContact.self, from: string!.data(using: .utf8)!))
    }

    func testPolisDirectoryEntry() {
        let pd = PolisDirectoryEntry(identifier: "abcd",
                                     name: "polis",
                                     lastUpdate: Date(),
                                     domain: "https://polis.net",
                                     providerDescription: "Polis test",
                                     supportedProtocolLevels: [1, 2],
                                     supportedAPIVersions: ["1.0.0", "1.2.0"],
                                     supportedFormats: [PolisDataFormat.xml],
                                     providerType: PolisProvider.experimental,
                                     contact: PolisContact(name: "polis",
                                                           email: "polis@observer.net",
                                                           additionalContacts: [Communicating.instagram(userName: "@polis")]))

        data = try? jsonEncoder.encode(pd)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectoryEntry.self, from: string!.data(using: .utf8)!))
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
        ("testPolisDataFormat", testPolisDataFormat),
        ("testPolisProvider", testPolisProvider),
        ("testCommunicating", testCommunicating),
        ("testPolisContact", testPolisContact),
        ("testPolisDirectoryEntry", testPolisDirectoryEntry),
    ]
}
