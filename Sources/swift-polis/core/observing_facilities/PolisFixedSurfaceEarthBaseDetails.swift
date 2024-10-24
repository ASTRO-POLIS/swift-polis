//
//  PolisFixedSurfaceEarthBaseDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 22/10/2024.
//

import Foundation

public class PolisFixedSurfaceEarthBaseDetails: PolisObservingFacility {

    public var location: PolisAddress?

    // General info
    public var openingHours: PolisVisitingHours?
    public var accessRestrictions: String?

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    public var traditionalLandOwners: String?

    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    public init(location: PolisAddress?                                = nil,
                openingHours: PolisVisitingHours?                      = nil,
                averageClearNightsPerYear: UInt?                       = nil,
                averageSeeingConditions: PolisPropertyValue?           = nil,
                traditionalLandOwners: String?                         = nil,
                dominantWindDirection: PolisDirection.RoughDirection?  = nil,
                surfaceSize: PolisPropertyValue?                       = nil,
                item: PolisItem,
                gravitationalBodyRelationship: ObservingFacilityLocationType,
                placeInTheSolarSystem: PlaceInTheSolarSystem,
                observingFacilityCode: String?                         = nil,
                solarSystemBodyName: String?                           = nil,
                orbitingAroundPlaceInTheSolarSystemNamed: String?      = nil,
                facilityLocationID: UUID?                              = nil,
                astronomicalCode: String?                              = nil,
                parentObservingFacilityID: UUID?                       = nil,
                observatoryIDs: Set<UUID>?                             = nil,
                deviceIDs: Set<UUID>?                                  = nil,
                website: URL?                                          = nil,
                scientificObjectives: String?                          = nil,
                history: String?                                       = nil,
                fixedSurfaceEarthBaseDetailsID: UUID?                  = nil,
                mobileSurfaceEarthBaseDetailsID: UUID?                 = nil,
                airborneEarthBaseDetailsID: UUID?                      = nil) {
        self.location                  = location
        self.openingHours              = openingHours
        self.averageClearNightsPerYear = averageClearNightsPerYear
        self.averageSeeingConditions   = averageSeeingConditions
        self.traditionalLandOwners     = traditionalLandOwners
        self.dominantWindDirection     = dominantWindDirection
        self.surfaceSize               = surfaceSize

        super.init(item: item,
                   gravitationalBodyRelationship: gravitationalBodyRelationship,
                   placeInTheSolarSystem: placeInTheSolarSystem,
                   observingFacilityCode: observingFacilityCode,
                   solarSystemBodyName: solarSystemBodyName,
                   orbitingAroundPlaceInTheSolarSystemNamed: orbitingAroundPlaceInTheSolarSystemNamed,
                   facilityLocationID: facilityLocationID,
                   astronomicalCode: astronomicalCode,
                   parentObservingFacilityID:parentObservingFacilityID,
                   observatoryIDs: observatoryIDs,
                   deviceIDs: deviceIDs,
                   website: website,
                   scientificObjectives: scientificObjectives,
                   history: history,
                   fixedSurfaceEarthBaseDetailsID: fixedSurfaceEarthBaseDetailsID,
                   mobileSurfaceEarthBaseDetailsID: mobileSurfaceEarthBaseDetailsID,
                   airborneEarthBaseDetailsID: airborneEarthBaseDetailsID)
    }

    //MARK: Make Swift compiler happy! 💩
    public required override init(item: PolisItem, gravitationalBodyRelationship: ObservingFacilityLocationType, placeInTheSolarSystem: PlaceInTheSolarSystem, observingFacilityCode: String? = nil, solarSystemBodyName: String? = nil, orbitingAroundPlaceInTheSolarSystemNamed: String? = nil, facilityLocationID: UUID? = nil, astronomicalCode: String? = nil, parentObservingFacilityID: UUID? = nil, observatoryIDs: Set<UUID>? = nil, deviceIDs: Set<UUID>? = nil, website: URL? = nil, scientificObjectives: String? = nil, history: String? = nil, fixedSurfaceEarthBaseDetailsID: UUID? = nil, mobileSurfaceEarthBaseDetailsID: UUID? = nil, airborneEarthBaseDetailsID: UUID? = nil) {
        fatalError("init(item:gravitationalBodyRelationship:placeInTheSolarSystem:observingFacilityCode:solarSystemBodyName:orbitingAroundPlaceInTheSolarSystemNamed:facilityLocationID:astronomicalCode:parentObservingFacilityID:observatoryIDs:deviceIDs:website:scientificObjectives:history:fixedSurfaceEarthBaseDetailsID:mobileSurfaceEarthBaseDetailsID:airborneEarthBaseDetailsID:) has not been implemented")
    }
    
    required public init(from decoder: any Decoder) throws { fatalError("init(from:) has not been implemented") }

}

public extension PolisFixedSurfaceEarthBaseDetails {
    enum CodingKeys: String, CodingKey {
        case location
        case openingHours                             = "opening_hours"
        case accessRestrictions                       = "access_restrictions"
        case averageClearNightsPerYear                = "average_clear_nights_per_year"
        case averageSeeingConditions                  = "average_seeing_conditions"
        case averageSkyQuality                        = "average_sky_quality"
        case traditionalLandOwners                    = "traditionalLand_owners"
        case dominantWindDirection                    = "'dominant_wind_direction'"
        case surfaceSize                              = "surface_size"

        case item
        case gravitationalBodyRelationship            = "gravitational_body_relationship"
        case placeInTheSolarSystem                    = "place_in_the_solar_system"
        case observingFacilityCode                    = "observing_facility_code"
        case solarSystemBodyName                      = "solar_system_body_name"
        case orbitingAroundPlaceInTheSolarSystemNamed = "orbiting_around_place_in_the_solar_system_named"
        case facilityLocationID                       = "facility_location_id"
        case astronomicalCode                         = "astronomical_code"
        case parentObservingFacilityID                = "parent_observing_facility_id"
        case observatoryIDs                           = "observatory_ids"
        case deviceIDs                                = "device_ids"
        case website
        case scientificObjectives                     = "scientific_objectives"
        case history
        case fixedSurfaceEarthBaseDetailsID           = "fixed_surface_earth_base_details_id"
        case mobileSurfaceEarthBaseDetailsID          = "mobile_surface_earth_base_details_id"
        case airborneEarthBaseDetailsID               = "airborne_earth_base_details_id"
    }
}
