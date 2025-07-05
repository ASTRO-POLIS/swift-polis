//
//  PolisEarthFixedBaseObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 22/10/2024.
//

import Foundation

public struct PolisEarthFixedBaseObservingFacilityDetails: Identifiable, Codable, Equatable {

    // General info
    public var id: UUID
    public var lastUpdateTime: Date
    public var facilityID: UUID

    // For visitors
    public var visitingHoursID: UUID?
    public var accessRestrictions: String?

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    public var traditionalLandOwners: String?

    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    public var placeID: UUID?

    public init(id: UUID                                              = UUID(),
                lastUpdateTime: Date                                  = Date.now,
                facilityID: UUID,
                visitingHoursID: UUID?                                = nil,
                averageClearNightsPerYear: UInt?                      = nil,
                averageSeeingConditions: PolisPropertyValue?          = nil,
                averageSkyQuality: PolisPropertyValue?                = nil,
                traditionalLandOwners: String?                        = nil,
                dominantWindDirection: PolisDirection.RoughDirection? = nil,
                surfaceSize: PolisPropertyValue?                      = nil,
                placeID: UUID?                                        = nil) {
        self.id                        = id
        self.lastUpdateTime            = lastUpdateTime
        self.facilityID                = facilityID
        self.visitingHoursID           = visitingHoursID
        self.averageClearNightsPerYear = averageClearNightsPerYear
        self.averageSeeingConditions   = averageSeeingConditions
        self.averageSkyQuality         = averageSkyQuality
        self.traditionalLandOwners     = traditionalLandOwners
        self.dominantWindDirection     = dominantWindDirection
        self.surfaceSize               = surfaceSize
        self.placeID                   = placeID
    }
}

public extension PolisEarthFixedBaseObservingFacilityDetails {
    enum CodingKeys: String, CodingKey {
        case id
        case lastUpdateTime            = "last_update_time"
        case facilityID                = "facility_id"
        case visitingHoursID           = "visiting_hours_id"
        case accessRestrictions        = "access_restrictions"
        case averageClearNightsPerYear = "average_clear_nights_per_year"
        case averageSeeingConditions   = "average_seeing_conditions"
        case averageSkyQuality         = "average_sky_quality"
        case traditionalLandOwners     = "traditionalLand_owners"
        case dominantWindDirection     = "'dominant_wind_direction'"
        case surfaceSize               = "surface_size"
        case placeID                   = "place_id"
    }
}
