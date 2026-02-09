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
    "supported_implementations": [
        {
            "api_support": "static_data",
            "version": "0.5.0",
            "data_format": "json"
        }
    ],
    "provider_type": "mirror",
    "contact": {
        "name": "Amon Ra",
        "email": "ra@god.nu",
        "communication": {
            "instagram_ids": [
                "GalaxyFarAway"
            ],
            "twitter_ids": [
                "@CoolAstro",
                "@GalaxyFarAway"
            ],
            "whatsapp_phone_numbers": [
                "+1 900 1234567"
            ],
            "mastodon_ids": [
                "@GalaxyFarAway@mastodon.social"
            ],
            "facebook_ids": [
                "916735592641"
            ]
        },
        "address": {
           "attention_off": "Mrs. Imperial Astronomer",
           "street": "Observatory str.",
           "region_or_state": "California",
           "poste_restante": "The Observing Man",
           "house_number_suffix": "a",
           "note": "Send only stars and love",
           "po_box": "4242",
           "district": "Stars",
           "street_line_6": "6",
           "block": "43",
           "place": "Sun hill",
           "region_or_state_code": "CA",
           "street_line_5": "5",
           "province": "Star cluster",
           "street_line_1": "1",
           "east_longitude": {
              "unit": "degrees",
              "value": "75.3",
              "value_kind": "double"
           },
           "apartment": "24",
           "latitude": {
              "value": "41.15",
              "unit": "degrees",
              "value_kind": "double"
          },
          "street_line_2": "2",
          "house_name": "Galaxy.",
          "street_line_4": "4",
          "floor": 1,
          "country_id": "AM",
          "altitude": {
              "value": "2450",
              "value_kind": "double",
              "unit": "m"
          },
          "po_box_zip": "ST1256",
          "house_number": 42,
          "street_line_3": "3",
          "zip_code": "ST1234"
        },
        "note": "Do not disturb during weekends"
    }
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
    "contact": {
        "name": "POLIS Admin",
        "email": "polis@tuparev.com",
        "communication": {
        },
        "address": {
           "street": "Sofijski geroj",
           "house_number_suffix": "b",
           "apartment": "27",
          "floor": 4,
          "country_id": "BG",
          "house_number": 3,
          "zip_code": "1612"
        },
        "note": "Do not disturb during weekends"
    }
}
"""

    
}
