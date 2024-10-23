//
//  PolisFixedSurfaceEarthBaseDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 22/10/2024.
//

public class PolisFixedSurfaceEarthBaseDetails: PolisObservingFacility {

    public var address: PolisAddress?

    // General info
    public var openingHours: PolisVisitingHours?
    public var accessRestrictions: String?

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    public var traditionalLandOwners: String?

    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    //TODO: Init

    //TODO: Coding extension

}
