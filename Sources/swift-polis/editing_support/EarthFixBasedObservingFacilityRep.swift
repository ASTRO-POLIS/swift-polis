//
//  EarthFixBasedObservingFacilityRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 23/10/2024.
//

class EarthFixBasedObservingFacilityRep: ObservingFacilityRep {


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

    public var continent: PolisAddress.EarthContinent?

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

    override func flush() async throws {
        try await super.flush()

        //TODO: Implement me!
    }

}
