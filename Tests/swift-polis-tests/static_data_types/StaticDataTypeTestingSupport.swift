
//===----------------------------------------------------------------------===//
//  StaticDataTypeTestingSupport.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2025 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//
//
//  Created by Georg Tuparev on 08/06/2025.
//

import Foundation
import swift_polis


struct StaticDataTypeTestingSupport {

    //MARK: PolisIdentity
    static func examplePolisIdentityBAO() -> PolisIdentity {
        PolisIdentity(externalReferences:    ["https://bao.am/device?id=1234", "https://bao.am/rtml?dump-1234"],
                      lastUpdateTime:        Date.now,
                      name:                  "Byurakan Astronomical Observatory",
                      localName:             "ՀՀ ԳԱԱ Վ․Հ․ ՀԱՄԲԱՐՁՈՒՄՅԱՆԻ ԱՆՎԱՆ ԲՅՈՒՐԱԿԱՆԻ ԱՍՏՂԱԴԻՏԱՐԱՆ (ԱԶԳԱՅԻՆ ԱՐԺԵՔ)",
                      abbreviation:          "bao",
                      shortDescription:      "Testing BAO site",
                      startTime:             Date.now,
                      endTime:               Date.now,
                      polisRegistrationTime: Date.now)
    }

    static func examplePolisIdentityASA() -> PolisIdentity {
        PolisIdentity(externalReferences:    ["https://www.astrosysteme.com?id=1234", "https://www.astrosysteme.com/dump-1234"],
                      lastUpdateTime:        Date.now,
                      name:                  "Astro Systeme Austria",
                      localName:             "Astro Systeme Osterreich",
                      abbreviation:          "asa",
                      shortDescription:      "Testing ASA site",
                      startTime:             Date.now,
                      endTime:               Date.now,
                      polisRegistrationTime: Date.now)
    }

    //MARK: PolisCommunicationChannel
    static func exampleCommunicationChannel() -> PolisCommunicationChannel {
        PolisCommunicationChannel(twitterIDs: ["@CoolAstro", "@GalaxyFarAway"],
                                  mastodonIDs: ["@GalaxyFarAway@mastodon.social"],
                                  whatsappPhoneNumbers: ["+1 900 1234567"],
                                  facebookIDs: ["916735592641"],
                                  instagramIDs: ["GalaxyFarAway"])
    }



    //MARK: PolisPerson
    static func examplePerson() -> PolisPerson {
        PolisPerson(name: "Amon Ra", email: "ra@god.cun", communication: exampleCommunicationChannel(), addressIDs: Set(arrayLiteral: examplePolisPlace().id))
    }

    //MARK: PolisPlace
    static func examplePolisPlace() -> PolisPlace {
        PolisPlace(attentionOff: "Mrs. Royal Astronomer",
                   houseName: "Galaxy.",
                   street: "Observatory str.",
                   houseNumber: 42,
                   houseNumberSuffix: "a",
                   floor: 1,
                   apartment: "24",
                   district: "Stars",
                   place: "Sun hill",
                   block: "43",
                   zipCode: "ST1234",
                   province: "Star cluster",
                   regionOrState: "California",
                   regionOrSatteCode: "CA",
                   countryID: "AM",
                   poBox: "4242",
                   poBoxZip: "ST1256",
                   posteRestante: "The Observing Man",
                   eastLongitude: PolisPropertyValue(valueKind: .double, value: "75.3", unit: "degrees"),
                   latitude: PolisPropertyValue(valueKind: .double, value: "41.15", unit: "degrees"),
                   altitude: PolisPropertyValue(valueKind: .double, value: "2450", unit: "m"),
                   streetLine1: "1",
                   streetLine2: "2",
                   streetLine3: "3",
                   streetLine4: "4",
                   streetLine5: "5",
                   streetLine6: "6",
                   note: "Send only stars and love")
    }


    //MARK: Private APIs
}
