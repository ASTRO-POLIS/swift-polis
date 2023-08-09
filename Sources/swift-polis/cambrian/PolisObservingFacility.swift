//===----------------------------------------------------------------------===//
//  PolisObservingFacility.swift
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

public struct PolisObservingFacility: Identifiable, Codable {

    // Are Collaborations and Networks not applicable only for observatories? And Arrays? Perhaps this should be called a Facility Type?
    public enum ObservingFacilityLocationType: String, Codable {
        case surfaceFixed
        case surfaceMobile
        case airborne
        case keplerianOrbital
        case nonKeplerianOrbital
        case unboundInterplanetary
        case other
//        case collaboration  // config
//        case network        // config
//        case array          // -> observatory
    }

    public enum PlaceInTheSolarSystem: String, Codable {
        case sun                = "Sun"

        // Planets
        case mercury            = "Mercury"
        case venus              = "Venus"
        case earth              = "earth"
        case mars               = "Mars"
        case jupiter            = "Jupiter"
        case saturn             = "Saturn"
        case uranus             = "Uranus"
        case neptune            = "Neptune"

        // Kuiper and Asteroid belt
        case pluto              = "Pluto"
        case ceres              = "Ceres"
        case haumea             = "Humea"
        case makemake           = "Mamemake"
        case eris               = "Eris"
        case asteroidBeltObject = "asteroid_belt_object"
        case kuiperBeltObject   = "kuiper_belt_object"

        // Miscellaneous
        case moon
        case comet
        case oortCloudObject    = "oort_cloud_object"
    }

    //MARK: - Common properties -
    // Identification and type
    public var item: PolisItem
    public var gravitationalBodyRelationship: ObservingFacilityLocationType
    public var placeInTheSolarSystem: PlaceInTheSolarSystem
    public var observingFacilityCode: String?

    // Where in the Solar system
    public var solarSystemBodyName: String?
    public var orbitingAroundPlaceInTheSolarSystemNamed: String?
    public var facilityLocationID: UUID?                                   // Points to dictionary with some predefined (standard) keys
    public var astronomicalCode: String?                                   // Minor planet codes, etc.

    // Relationship to other facilities
    public var parentObservingFacilityID: UUID?
    public var subObservingFacilityIDs: Set<UUID>?

    // Contains
    public var observatoryIDs: Set<UUID>?
    public var deviceIDs: Set<UUID>?

    // When
    public var startDate: Date?
    public var endDate: Date?
    public var polisRegistrationDate: Date?
    public var polisDisconnectionDate: Date?

    // Info
    public var adminContact: PolisAdminContact?
    public var website: URL?
    public var scientificObjectives: String?
    public var history: String?

    // Identifiable protocol compliance
    public var id: UUID { item.identity.id }

    //MARK: Earth-based site properties
    public var openingHours: PolisVisitingHours?
    public var accessRestrictions: String?

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    public var traditionalLandOwners: String?

    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?

    init(item: PolisItem, gravitationalBodyRelationship: ObservingFacilityLocationType, placeInTheSolarSystem: PlaceInTheSolarSystem, observingFacilityCode: String? = nil, solarSystemBodyName: String? = nil, astronomicalCode: String? = nil, orbitingAroundPlaceInTheSolarSystemNamed: String? = nil, facilityLocationID: UUID? = nil, parentObservingFacilityID: UUID? = nil, subObservingFacilityIDs: Set<UUID>? = nil, observatoryIDs: Set<UUID>? = nil, deviceIDs: Set<UUID>? = nil, startDate: Date? = nil, endDate: Date? = nil, polisRegistrationDate: Date? = nil, polisDisconnectionDate: Date? = nil, adminContact: PolisAdminContact? = nil, website: URL? = nil, scientificObjectives: String? = nil, history: String? = nil, openingHours: PolisVisitingHours? = nil, accessRestrictions: String? = nil, averageClearNightsPerYear: UInt? = nil, averageSeeingConditions: PolisPropertyValue? = nil, averageSkyQuality: PolisPropertyValue? = nil, traditionalLandOwners: String? = nil, dominantWindDirection: PolisDirection.RoughDirection? = nil, surfaceSize: PolisPropertyValue? = nil) {
        self.item                                     = item
        self.gravitationalBodyRelationship            = gravitationalBodyRelationship
        self.placeInTheSolarSystem                    = placeInTheSolarSystem
        self.observingFacilityCode                    = observingFacilityCode
        self.solarSystemBodyName                      = solarSystemBodyName
        self.astronomicalCode                         = astronomicalCode
        self.orbitingAroundPlaceInTheSolarSystemNamed = orbitingAroundPlaceInTheSolarSystemNamed
        self.facilityLocationID                       = facilityLocationID
        self.parentObservingFacilityID                = parentObservingFacilityID
        self.subObservingFacilityIDs                  = subObservingFacilityIDs
        self.observatoryIDs                           = observatoryIDs
        self.deviceIDs                                = deviceIDs
        self.startDate                                = startDate
        self.endDate                                  = endDate
        self.polisRegistrationDate                    = polisRegistrationDate
        self.polisDisconnectionDate                   = polisDisconnectionDate
        self.adminContact                             = adminContact
        self.website                                  = website
        self.scientificObjectives                     = scientificObjectives
        self.history                                  = history
        self.openingHours                             = openingHours
        self.accessRestrictions                       = accessRestrictions
        self.averageClearNightsPerYear                = averageClearNightsPerYear
        self.averageSeeingConditions                  = averageSeeingConditions
        self.averageSkyQuality                        = averageSkyQuality
        self.traditionalLandOwners                    = traditionalLandOwners
        self.dominantWindDirection                    = dominantWindDirection
        self.surfaceSize                              = surfaceSize
    }
}


public extension PolisObservingFacility {
    enum CodingKeys: String, CodingKey {
        case item
        case gravitationalBodyRelationship            = "gravitational_body_relationship"
        case placeInTheSolarSystem                    = "place_in_the_solar_system"
        case observingFacilityCode                    = "observing_facility_code"

        // Where in the Solar system
        case solarSystemBodyName                      = "solar_system_body_name"
        case orbitingAroundPlaceInTheSolarSystemNamed = "orbiting_around_place_in_the_solar_system_named"
        case facilityLocationID                       = "facilityLocation_id"
        case astronomicalCode                         = "astronomical_code"

        // Relationship to other facilities
        case parentObservingFacilityID                = "paren_observing_facility_id"
        case subObservingFacilityIDs                  = "sub_observing_facility_ids"

        // Contains
        case observatoryIDs                           = "observatory_ids"
        case deviceIDs                                = "device_ids"

        // When
        case startDate                                = "start_date"
        case endDate                                  = "end_date"
        case polisRegistrationDate                    = "polis_registration_date"
        case polisDisconnectionDate                   = "polis_disconnection_date"

        // Info
        case adminContact                             = "admin_contact"
        case website
        case scientificObjectives                     = "scientific_objectives"
        case history

        case openingHours                             = "opening_hours"
        case accessRestrictions                       = "access_restrictions"
        case averageClearNightsPerYear                = "average_clear_nights_per_year"
        case averageSeeingConditions                  = "average_seeing_conditions"
        case averageSkyQuality                        = "average_sky_quality"
        case traditionalLandOwners                    = "traditional_land_owners"
        case dominantWindDirection                    = "dominant_wind_direction"
        case surfaceSize                              = "surface_size"
    }
}

