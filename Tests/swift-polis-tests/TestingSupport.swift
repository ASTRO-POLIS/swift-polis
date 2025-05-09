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
    static let onlyANoteVisitingHours = """
{
   "id": "65BEF6F8-C383-40D4-9E53-B4517ACD348E",
   "only_group_visits": false,
   "note": "For group and individual visits, please call the observatory office every working day between 14:00h and 16:00h."
}
""".data(using: .utf8)!

    static let everyYearEveryMonthEverySundayVisitingHours = """
{
   "id": "65BEF6F8-C383-40D4-9E53-B4517ACD348E",
   "visiting_possibilities": [
      {
         "applicable_weekdays": ["Sunday"],
         "only_group_visits": true,
         "is_repeating": true
      },
   ],
   "note": "Please call before visiting."
}
""".data(using: .utf8)!

    // In 2024 and 2025, between July and September, every Saturday between 14:00 and 16:00 (only for groups), and every Sunday between
    // 9:00 and 12:00 and between 14:00 and 17:00.
    static let complexVisitingHoursVisitingHours = """
{
   "id": "65BEF6F8-C383-40D4-9E53-B4517ACD348E",
   "visiting_possibilities": [
      {
         "applicable_years": [2024, 2025],
         "applicable_months": [7, 8, 9],
         "applicable_weekdays": ["Saturday"],
         "visiting_period": [ { "from": "14:00", "to": "16:00" } ],
         "only_group_visits": true,
         "is_repeating": true
      },
      {
         "applicable_years": [2024, 2025],
         "applicable_months": [7, 8, 9],
         "applicable_weekdays": ["Sunday"],
         "visiting_period": [ { "from": "09:00", "to": "12:00" }, { "from": "14:00", "to": "16:00" } ],
         "only_group_visits": false,
         "is_repeating": true
      }
   ],
   "note": "By or after heavy rain, the road to the observatory could be closed. Check the weather forcast before planning your visit."
}
""".data(using: .utf8)!



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
