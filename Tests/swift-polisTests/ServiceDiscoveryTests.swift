import XCTest
import SoftwareEtudes

@testable import swift_polis
final class ServiceDiscoveryTests: XCTestCase {

    let jsonEncoder = PolisJSONEncoder()
    let jsonDecoder = PolisJSONDecoder()
    var data: Data!
    var string: String!


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
        let pd = try? PolisDirectoryEntry(attributes: PolisItemAttributes(name: "polis"),
                                     url: "https://polis.net",
                                     providerDescription: "Polis test",
                                     supportedImplementations: [],
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
        ("testPolisContact", testPolisContact),
        ("testPolisDirectoryEntry", testPolisDirectoryEntry),
    ]
}
