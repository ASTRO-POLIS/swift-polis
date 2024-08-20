
import XCTest
import SoftwareEtudesUtilities

@testable import swift_polis
final class _PolisServiceProviderTests: XCTestCase {

    //MARK: - Initialisation -

    //MARK: - Actual tests -


    func test_PolisObservingDirectory_coding_shouldSucceed() throws {
        //TODO: Fix me! 
        // Given
        let astroTechIdentity               = PolisIdentity(name: "AstroTech")
        let astroTechObservingFacilityEntry = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: astroTechIdentity)

        // When
        let sut = PolisObservingFacilityDirectory(lastUpdate: Date(), observingFacilityReferences: [astroTechObservingFacilityEntry])

        // Then
        XCTAssertNotNil(sut)

//        data   = try? jsonEncoder.encode(sut)
//        string = String(data: data!, encoding: .utf8)
//        XCTAssertNoThrow(try jsonDecoder.decode(PolisObservingFacilityDirectory.self, from: string!.data(using: .utf8)!))
    }

    func test_PolisResourceReference_coding_shouldSucceed() throws {
        // Given
        let asa_identity = PolisIdentity(name: "ASA")
        let asa          = PolisResourceDirectory.ResourceReference(identity: asa_identity, uniqueName: "asa", deviceTypes: [.mount])

        // When
        let sut = PolisResourceDirectory(lastUpdate: Date(), resourceReferences: [asa])

        // Then
        XCTAssertNotNil(sut)

//        data   = try? jsonEncoder.encode(sut)
//        string = String(data: data!, encoding: .utf8)
//        XCTAssertNoThrow(try jsonDecoder.decode(PolisResourceDirectory.self, from: string!.data(using: .utf8)!))
   }

    //MARK: - Housekeeping -
    static var allTests = [
        ("test_PolisObservingDirectory_coding_shouldSucceed", test_PolisObservingDirectory_coding_shouldSucceed),
        ("test_PolisResourceReference_coding_shouldSucceed",  test_PolisResourceReference_coding_shouldSucceed),
    ]
}
