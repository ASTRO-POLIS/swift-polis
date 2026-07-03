//
//  IdentityDataPrototypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 3.07.26.
//

import Foundation
import SoftwareEtudesUtilities

struct PolisIdentitySource {

    public static let identityFoByurakanObservatoryTemplate = """
{
    "id": "776E7D44-6307-4511-9857-6BE8EBE1252B",
    "external_references": [
       "https://bao.am/device?id=1234",
       "https://bao.am/rtml?dump-1234"
    ],
    "last_update_time": "2025-10-24T06:17:24Z",
    "lifecycle_status": "active",
    "name": [ 
       { "en": "Byurakan Astronomical Observatory" },
       { "am": "ՀՀ ԳԱԱ Վ․Հ․ ՀԱՄԲԱՐՁՈՒՄՅԱՆԻ ԱՆՎԱՆ ԲՅՈՒՐԱԿԱՆԻ ԱՍՏՂԱԴԻՏԱՐԱՆ (ԱԶԳԱՅԻՆ ԱՐԺԵՔ)" }
    ],
    "abbreviation": "bao",
    "short_description": [ { "en": "Testing BAO site" } ],
    "start_time": "1952-10-24T06:17:24Z",
    "end_time": "2125-10-24T06:17:24Z",
    "polis_registration_time": "2025-10-24T06:17:24Z"
}
"""
}
