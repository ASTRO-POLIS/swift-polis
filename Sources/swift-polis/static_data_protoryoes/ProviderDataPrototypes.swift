//
//  ProviderDataPrototypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 9.02.26.
//

import Foundation
import SoftwareEtudesUtilities

//MARK: PolisImplementation
struct PolisImplementationDataSource {

    static let currentFrameworkVersionTemplate = """
{
    "data_format": "json",
    "api_support": "static_data",
    "version": "0.1.0-alpha.1"
}
"""

    static func latestPolisImplementation() -> PolisImplementation { PolisConstants.polisFrameworkSupportedImplementations.last! }

    static func examplePolisImplementation() -> PolisImplementation { PolisImplementation(dataFormat: .json, apiSupport: .staticData,  version: SemanticVersion(majorNumber: 0, minorNumber: 5, patchNumber: 0, preReleaseVersion: "beta-1") ) }

    static func dataBasedPolisImplementation() throws -> PolisImplementation { try jsonDecoder.decode(PolisImplementation.self, from: currentFrameworkVersionTemplate.data(using: .utf8)!) }

    // Private APIs
    static private let jsonDecoder = PrettyJSONDecoder()
}

struct ServiceProviderDataSource {

    static let exampleServiceProviderTemplate = """
{
    "id": "090E3F63-EF2A-4123-8518-77D5664EAA01",
    "mirror_id": "62B5E7C7-4A90-4569-9B13-4AEF324441E4",
    "reachability_status": "reachable_and_responsive",
    "name": "Polis Observer",
    "short_description": "Observing the Universe",
    "last_update_time": "2023-07-22T12:10:06Z",
    "url": "https://universe.net",
    "supported_implementations": [ \(PolisImplementationDataSource.currentFrameworkVersionTemplate) ],
    "provider_type": "mirror",
    "contact_email": "contact@example.com"
}
"""

    static let bigBangServiceProviderTemplate = """
{
    "id": "090E3F63-EF2A-4123-8518-88D5664EAA01",
    "reachability_status": "reachable_and_responsive",
    "name": "POLIS Big Bang",
    "short_description": "Polis Origin",
    "last_update_time": "2026-03-01T12:10:06Z",
    "url": "https://polis.observer",
    "supported_implementations": [
        {
            "api_support": "static_data",
            "version": "0.1.0-alpha.1",
            "data_format": "json"
        }
    ],
    "provider_type": "public_primary",
    "contact_email": "polis@tuparev.com",
    "note": "Do not disturb during weekends"
    }
}
"""

    static let defaultServiceProviderTemplate = """
{
    "id": "090E3F63-EF2A-4123-8518-88D777EAA01",
    "reachability_status": "reachable_and_responsive",
    "name": "Example Provider",
    "short_description": "POLIS Service Provider",
    "last_update_time": "2026-03-01T12:10:06Z",
    "url": "https://example.polis",
    "supported_implementations": [
        {
            "api_support": "static_data",
            "version": "0.1.0",
            "data_format": "json"
        }
    ],
    "provider_type": "public_secondary",
    "contact_email": "polis@example.com",
    "note": "Do not disturb during weekends"
    }
}
"""

    static func completePolisDirectoryEntryExample() throws -> PolisDirectory.ProviderDirectoryEntry { try jsonDecoder.decode(PolisDirectory.ProviderDirectoryEntry.self, from: exampleServiceProviderTemplate.data(using: .utf8)!) }

    static func bigBangPolisDirectoryEntryExample() throws -> PolisDirectory.ProviderDirectoryEntry { try jsonDecoder.decode(PolisDirectory.ProviderDirectoryEntry.self, from: bigBangServiceProviderTemplate.data(using: .utf8)!) }

    /// Default provider is any provider prototype different from BigBang POLIS Root (primary provider)
    static func defaultPolisDirectoryEntryExample() throws -> PolisDirectory.ProviderDirectoryEntry { try jsonDecoder.decode(PolisDirectory.ProviderDirectoryEntry.self, from: defaultServiceProviderTemplate.data(using: .utf8)!) }

    // Private APIs
    static private let jsonDecoder = PrettyJSONDecoder()
}
