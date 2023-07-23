
import XCTest
import SoftwareEtudesUtilities

@testable import swift_polis
final class _PolisServiceProviderTests: XCTestCase {

    //MARK: - Initialisation -

    //MARK: - Actual tests -


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
        ("test_PolisObservingSiteDirectory_coding_shouldSucceed",                 test_PolisObservingSiteDirectory_coding_shouldSucceed),
        ("test_PolisResourceSiteDirectoryResourceReference_coding_shouldSucceed", test_PolisResourceSiteDirectoryResourceReference_coding_shouldSucceed),
    ]
}
