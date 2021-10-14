import XCTest
@testable import swift_polis

final class ServiceDiscoveryTests: XCTestCase {

    let jsonEncoder = PolisJSONEncoder()
    let jsonDecoder = PolisJSONDecoder()
    var data: Data!
    var string: String!

    func testPolisProvider() {
        let pub = PolisProviderType.public
        let mir = PolisProviderType.mirror(id: "abc")

        data = try? jsonEncoder.encode(pub)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisProviderType.self, from: string!.data(using: .utf8)!))

        data = try? jsonEncoder.encode(mir)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisProviderType.self, from: string!.data(using: .utf8)!))
    }

    func testCommunicating() {
        let t = PolisCommunication.twitter(userName: "@polis")

        data = try? jsonEncoder.encode(t)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisCommunication.self, from: string!.data(using: .utf8)!))
    }

    func testPolisContact() {
        let c = PolisAdminContact(name: "polis",
                                  email: "polis@observer.net",
                                  mobilePhone: nil,
                                  additionalCommunicationChannels: [PolisCommunication.instagram(userName: "@polis")],
                                  notes: nil)

        data   = try? jsonEncoder.encode(c)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(PolisAdminContact.self, from: string!.data(using: .utf8)!))
    }

    func testPolisDirectoryEntry() {
        let pd = PolisDirectoryEntry(attributes: PolisItemAttributes(name: "polis"),
                                     url: "https://polis.net",
                                     providerDescription: "Polis test",
                                     supportedProtocolLevels: [1, 2],
                                     supportedAPIVersions: ["1.0.0", "1.2.0"],
                                     providerType: PolisProviderType.experimental,
                                     contact: PolisAdminContact(name: "polis",
                                                                email: "polis@observer.net",
                                                                mobilePhone: nil,
                                                                additionalCommunicationChannels: [PolisCommunication.instagram(userName: "@polis")],
                                                                notes: "The admin works only on Sunday")!)

        data   = try? jsonEncoder.encode(pd)
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
        ("testPolisProvider", testPolisProvider),
        ("testCommunicating", testCommunicating),
        ("testPolisContact", testPolisContact),
        ("testPolisDirectoryEntry", testPolisDirectoryEntry),
    ]
}
