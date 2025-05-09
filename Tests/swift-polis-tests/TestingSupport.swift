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

    static let testingFolder = "/Users/Shared/Work/polis_tests"

    //MARK: Supporting methods
    static func cleanUpTestingFolder() throws {
        try FileManager.default.removeItem(atPath: testingFolder)
        try FileManager.default.createDirectory(atPath: testingFolder, withIntermediateDirectories: true)
    }

    //MARK: - String for Decoding Data -



    //MARK: - Factory Static Methods -
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

    static func examplePolisItemBAO() -> PolisItem {
        PolisItem(identity: TestingSupport.examplePolisIdentityBAO(),
                  owner: TestingSupport.exampleOwner(),
                  automationLabel: "BAO",
                  lifecycleStatus: .active)
    }

    static func exampleOwner() -> PolisOwner {
        PolisOwner(ownershipType: .government,
                        personalOwnerIDs: Set([UUID(uuidString: "6FDA06D1-9AB1-4EF2-AD13-0DAF28940C52")!]),
                        organisationalOwnerIDs: Set([UUID(uuidString: "2CE0491C-AC1F-4B84-A4C5-D752E9AE95D4")!, UUID(uuidString: "FD0D5301-9C0F-4239-BD52-FAF8DBA2A2EF")!]))
    }

    static func exampleCommunicationChannel() -> PolisCommunicationChannel {
        PolisCommunicationChannel(twitterIDs: ["@CoolAstro", "@GalaxyFarAway"],
                                  mastodonIDs: ["@GalaxyFarAway@mastodon.social"],
                                  whatsappPhoneNumbers: ["+1 900 1234567"],
                                  facebookIDs: ["916735592641"],
                                  instagramIDs: ["GalaxyFarAway"],
                                  skypeIDs: ["cool_astro"])
    }
    
    static func exampleAddress() -> PolisPlace {
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
    
    static func examplePerson() -> PolisPerson {
        PolisPerson(name: "Amon Ra", email: "ra@god.cun", communication: exampleCommunicationChannel(), addressIDs: Set(arrayLiteral: exampleAddress().id))
    }

    static func exampleObservingFacility() -> PolisObservingFacility {
        PolisObservingFacility(item: examplePolisItemBAO(), gravitationalBodyRelationship: PolisObservingFacility.ObservingFacilityLocationType.surfaceFixed, placeInTheSolarSystem: PolisObservingFacility.PlaceInTheSolarSystem.earth)
    }
    
    static func exampleFixedSurfaceEarthBaseDetails() -> PolisFixedSurfaceEarthBaseDetails {
        PolisFixedSurfaceEarthBaseDetails(facility: exampleObservingFacility(),
                                          location: exampleAddress(),
                                          visitingHours: nil,                                                 //FIXME: more data
                                          averageClearNightsPerYear: 211,
                                          averageSeeingConditions: nil,                                       //FIXME: more data
                                          traditionalLandOwners: "A Ferengi tribe",
                                          dominantWindDirection: PolisDirection.RoughDirection.eastNorthEast,
                                          surfaceSize:  nil)                                                  //FIXME: more data
    }

    static func exampleItem() -> PolisItem {
        PolisItem(identity: examplePolisIdentityBAO(),
                  owner: exampleOwner(),
                  parentID: nil,
                  automationLabel: "BAO",
                  lifecycleStatus: PolisLifecycleStatus.active,
                  mediaSourceID: nil)                            //FIXME: more data
    }

}
