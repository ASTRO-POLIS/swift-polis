//===----------------------------------------------------------------------===//
//  TestingSupport.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//

import Foundation
import swift_polis

struct TestingSupport {
    
    static func examplePolisIdentityBAO() -> PolisIdentity {
        PolisIdentity(externalReferences:    ["https://bao.am/device?id=1234", "https://bao.am/rtml?dump-1234"],
                      lastUpdateDate:        Date(),
                      name:                  "Byurakan Astronomical Observatory",
                      localName:             "ՀՀ ԳԱԱ Վ․Հ․ ՀԱՄԲԱՐՁՈՒՄՅԱՆԻ ԱՆՎԱՆ ԲՅՈՒՐԱԿԱՆԻ ԱՍՏՂԱԴԻՏԱՐԱՆ (ԱԶԳԱՅԻՆ ԱՐԺԵՔ)",
                      abbreviation:          "bao",
                      shortDescription:      "Testing BAO site",
                      startDate:             Date.now,
                      endDate:               Date.now,
                      polisRegistrationDate: Date.now
        )
    }
    
    static func exampleCommunicationChannel() -> PolisCommunicationChannel {
        PolisCommunicationChannel(twitterIDs: ["@CoolAstro", "@GalaxyFarAway"],
                                  mastodonIDs: ["@GalaxyFarAway@mastodon.social"],
                                  whatsappPhoneNumbers: ["+1 900 1234567"],
                                  facebookIDs: ["916735592641"],
                                  instagramIDs: ["GalaxyFarAway"],
                                  skypeIDs: ["cool_astro"])
    }
    
    static func exampleAddress() -> PolisAddress {
        PolisAddress(attentionOff: "Mrs. Royal Astronomer",
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
    
    static func examplePerson() -> PolisPerson {
        PolisPerson(name: "Amon Ra", email: "ra@god.cun", communication: exampleCommunicationChannel(), address: exampleAddress())
    }
    
}
