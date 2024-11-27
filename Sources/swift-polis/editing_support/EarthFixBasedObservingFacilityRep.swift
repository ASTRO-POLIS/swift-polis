//
//  EarthFixBasedObservingFacilityRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 23/10/2024.
//

import Foundation

open class EarthFixBasedObservingFacilityRep: ObservingFacilityRep {

    public static func registerNewEarthFixBasedFacility(with id: UUID = UUID(), name: String = "Unknown Facility") throws -> EarthFixBasedObservingFacilityRep {
        let result: EarthFixBasedObservingFacilityRep = EarthFixBasedObservingFacilityRep(id: id, name: name)

        //TODO: Implement me!

        return result
    }

    // Address related
    public var street: String?
    public var houseNumber: Int?
    public var houseNumberSuffix: String?
    public var district: String?
    public var place: String?                     // e.g. Mount Wilson
    public var zipCode: String?
    public var province: String?
    public var regionOrState: String?             // Region or state name, e.g. California
    public var regionOrStateCode: String?         // e.g. CA for California

    public var country: String?                   // e.g. Armenia
    public var countryID: String?                 // 2-letter code

    public var continent: PolisPlace.EarthContinent?

    public var eastLongitude: PolisPropertyValue? // degrees
    public var latitude: PolisPropertyValue?      // degrees
    public var altitude: PolisPropertyValue?      // m

    public var addressNote: String?

    public var timeZoneIdentifier: String?        // .. as defined with `TimeZone.knownTimeZoneIdentifiers`

    // General info
    public var openingHours: PolisVisitingHours?
    public var accessRestrictions: String?

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    public var traditionalLandOwners: String?

    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    public override func flush() async throws {
        try await super.flush()

        //TODO: Implement me!
    }

    init(id: UUID,
         name: String,
         street: String?                                       = nil,
         houseNumber: Int?                                     = nil,
         houseNumberSuffix: String?                            = nil,
         district: String?                                     = nil,
         place: String?                                        = nil,
         zipCode: String?                                      = nil,
         province: String?                                     = nil,
         regionOrState: String?                                = nil,
         regionOrStateCode: String?                            = nil,
         country: String?                                      = nil,
         countryID: String?                                    = nil,
         continent: PolisPlace.EarthContinent?                 = nil,
         eastLongitude: PolisPropertyValue?                    = nil,
         latitude: PolisPropertyValue?                         = nil,
         altitude: PolisPropertyValue?                         = nil,
         addressNote: String?                                  = nil,
         timeZoneIdentifier: String?                           = nil,
         openingHours: PolisVisitingHours?                     = nil,
         accessRestrictions: String?                           = nil,
         averageClearNightsPerYear: UInt?                      = nil,
         averageSeeingConditions: PolisPropertyValue?          = nil,
         averageSkyQuality: PolisPropertyValue?                = nil,
         traditionalLandOwners: String?                        = nil,
         dominantWindDirection: PolisDirection.RoughDirection? = nil,
         surfaceSize: PolisPropertyValue?                      = nil) {
        self.street                    = street
        self.houseNumber               = houseNumber
        self.houseNumberSuffix         = houseNumberSuffix
        self.district                  = district
        self.place                     = place
        self.zipCode                   = zipCode
        self.province                  = province
        self.regionOrState             = regionOrState
        self.regionOrStateCode         = regionOrStateCode
        self.country                   = country
        self.countryID                 = countryID
        self.continent                 = continent
        self.eastLongitude             = eastLongitude
        self.latitude                  = latitude
        self.altitude                  = altitude
        self.addressNote               = addressNote
        self.timeZoneIdentifier        = timeZoneIdentifier
        self.openingHours              = openingHours
        self.accessRestrictions        = accessRestrictions
        self.averageClearNightsPerYear = averageClearNightsPerYear
        self.averageSeeingConditions   = averageSeeingConditions
        self.averageSkyQuality         = averageSkyQuality
        self.traditionalLandOwners     = traditionalLandOwners
        self.dominantWindDirection     = dominantWindDirection
        self.surfaceSize               = surfaceSize

        super.init(id: id, name: name)
    }
}
