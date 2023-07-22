
import XCTest
import SoftwareEtudesUtilities

@testable import swift_polis
final class _PolisServiceProviderTests: XCTestCase {

    //MARK: - Initialisation -
    private let jsonDataFromDirectoryEntry = """
{
    "supported_implementations": [
        {
            "api_support": "static_data",
            "version": "0.1.0-alpha.1",
            "data_format": "json"
        }
    ],
    "provider_type": {
        "type": "experimental"
    },
    "url": "www.telescope.observer",
    "id": "6084D02F-A110-43A1-ACB4-93D32A42E605",
    "name": "Telescope Observer",
    "short_description": "The original site",
    "last_update": "2022-02-12T20:59:26Z",
    "reachability_status" : "currentlyUnreachable",
    "contact": {
       "id": "6084D02F-A110-43A1-ACB4-93D32A42E606",
       "email_address": "polis@tuparev.com",
        "additional_communication": [
            {
                "twitter": {
                    "username": "@TelescopeObserver"
                },
                "communication_type": "twitter"
            }
        ],
        "note": "The site is experimental, so not need to contact us yet.",
        "name": "TelescopeObserver Admin"
    }
}
"""



    //MARK: - Actual tests -


    func testLoadingPolisDirectoryEntryFromData() {
//TODO: Fix me!        XCTAssertNoThrow(try jsonDecoder.decode(PolisDirectory.DirectoryEntry.self, from: jsonDataFromDirectoryEntry.data(using: .utf8)!))
    }

    func testPolisDirectoryFromStaticData() {
//        let entry   = try? jsonDecoder.decode(PolisDirectory.DirectoryEntry.self, from: jsonDataFromDirectoryEntry.data(using: .utf8)!)
//        let entries = [entry!]
//        let sut     = PolisDirectory(lastUpdate: Date(), entries: entries)
//
//        XCTAssertNotNil(sut)
    }

    func test_PolisObservingSiteDirectory_coding_shouldSucceed() throws {
        //TODO: Fix me! 
        // Given
        let astroTechIdentity           = PolisIdentity(name: "AstroTech")
        let astroTechObservingSiteEntry = PolisObservingSiteDirectory.ObservingSiteReference(identity: astroTechIdentity, type: PolisObservingType.site)

        // When
        let sut = PolisObservingSiteDirectory(lastUpdate: Date(), entries: [astroTechObservingSiteEntry])

        // Then
        XCTAssertNotNil(sut)

//        data   = try? jsonEncoder.encode(sut)
//        string = String(data: data!, encoding: .utf8)
//        XCTAssertNoThrow(try jsonDecoder.decode(PolisObservingSiteDirectory.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisResourceSiteDirectoryResourceReference_coding_shouldSucceed() throws {
        // Given
        let asa_identity = PolisIdentity(name: "ASA")
        let asa          = PolisResourceSiteDirectory.ResourceReference(identity: asa_identity, uniqueName: "asa", deviceTypes: [.mount])

        // When
        let sut = PolisResourceSiteDirectory(lastUpdate: Date(), entries: [asa])

        // Then
        XCTAssertNotNil(sut)

//        data   = try? jsonEncoder.encode(sut)
//        string = String(data: data!, encoding: .utf8)
//        XCTAssertNoThrow(try jsonDecoder.decode(PolisResourceSiteDirectory.self, from: string!.data(using: .utf8)!))
   }

    //MARK: - Housekeeping -
    static var allTests = [
        ("testLoadingPolisDirectoryEntryFromData",                                testLoadingPolisDirectoryEntryFromData),
        ("testPolisDirectoryFromStaticData",                                      testPolisDirectoryFromStaticData),
        ("test_PolisObservingSiteDirectory_coding_shouldSucceed",                 test_PolisObservingSiteDirectory_coding_shouldSucceed),
        ("test_PolisResourceSiteDirectoryResourceReference_coding_shouldSucceed", test_PolisResourceSiteDirectoryResourceReference_coding_shouldSucceed),
    ]
}
