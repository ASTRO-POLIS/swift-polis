//
//  PartyDataPrototypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11.02.26.
//

import Foundation
import SoftwareEtudesUtilities

//MARK: PolisPlace
struct PolisPlaceDataSource {

    static let examplePlaceTemplate = """
{
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
}
"""

}

//MARK: PolisPlace
struct PolisPersonDataSource {

    static let examplePersonTemplate = """
{
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
    "address": \(PolisPlaceDataSource.examplePlaceTemplate),
    "note": "Do not disturb during weekends"
}
"""
}
