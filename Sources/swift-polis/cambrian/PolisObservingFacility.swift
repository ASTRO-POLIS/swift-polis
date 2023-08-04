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
    public enum ObservingFacilityType: String, Codable {
        case site
        case mobilePlatform = "mobile_platform"
//        case collaboration  // config
//        case network        // config
//        case array          // -> observatory
    }

    public enum GravitationalBodyRelationship: String, Codable {
        case surfaceBased = "surface_based"
        case inOrbit      = "in_orbit"
        case unbound
        case other
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
    public var observingFacilityType: ObservingFacilityType
    public var gravitationalBodyRelationship: GravitationalBodyRelationship
    public var placeInTheSolarSystem: PlaceInTheSolarSystem
    public var observingFacilityCode: String?

    // Where in the Solar system
    public var solarSystemBodyName: String?                                // Should NOT be optional. Will be fixed with setters/getters ...
    public var astronomicalCode: String?                                   // Minor planet codes, etc.
    public var orbitingAroundPlaceInTheSolarSystem: PlaceInTheSolarSystem? // Optional only in the case of the Sun!
    public var orbitingAroundPlaceInTheSolarSystemNamed: String?           // Optional only in the case of the Sun! Derived, perhaps function?
    public var facilityLocationID: String?                                 // Pints to dictionary with some predefined (standard) keys

    // Relationship to other facilities
    public var parentObservingSiteID: UUID?
    public var subObservingSiteIDs: Set<UUID>?
    public var collaborationObservingSiteIDs: Set<UUID>?

    // Contains
    public var observatoryIDs: Set<UUID>?
    public var deviceIDs: Set<UUID>?
    public var configurationIDs: Set<UUID>?                                // I think this should be only for Observatory?

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
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude]

    public var traditionalLandOwners: String?

}


public extension PolisObservingFacility {
    enum CodingKeys: String, CodingKey {
        case item
        case observingFacilityType
        case gravitationalBodyRelationship
        case placeInTheSolarSystem
        case observingFacilityCode

        // Where in the Solar system
        case solarSystemBodyName
        case astronomicalCode
        case orbitingAroundPlaceInTheSolarSystem
        case orbitingAroundPlaceInTheSolarSystemNamed
        case facilityLocationID

        // Relationship to other facilities
        case parentObservingSiteID
        case subObservingSiteIDs
        case collaborationObservingSiteIDs

        // Contains
        case observatoryIDs
        case deviceIDs
        case configurationIDs

        // When
        case startDate
        case endDate
        case polisRegistrationDate
        case polisDisconnectionDate

        // Info
        case adminContact
        case website
        case scientificObjectives
        case history
    }
}
