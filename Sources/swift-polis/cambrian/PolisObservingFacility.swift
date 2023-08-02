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

public struct PolisObservingFacility: Identifiable {

    // Are Collaborations and Networks not applicable only for observatories? And Arrays? Perhaps this should be called a Facility Type?
    public enum ObservingType: String, Codable {
        case site
        case mobilePlatform = "mobile_platform"
        case collaboration
        case network
        case array
    }

    public enum GravitationalBodyRelationship: String, Codable {
        case surfaceBased = "surface_based"
        case inOrbit      = "in_orbit"
        case unbound
        case other
    }

    public enum PlaceInTheSolarSystem {
        case sun

        // Planets
        case mercury
        case venus
        case earth
        case mars
        case jupiter
        case saturn
        case uranus
        case neptune

        // Kuiper and Asteroid belt
        case pluto
        case ceres
        case haumea
        case makemake
        case eris
        case asteroidBeltObject
        case kuiperBeltObject

        // Miscellaneous
        case moon
        case comet
        case oortCloudObject
    }

    // Identification and type
    public var item: PolisItem
    public var observingType: ObservingType
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
    public var admins: [PolisAdminContact]?
    public var website: URL?
    public var scientificObjectives: String?
    public var history: String?

    // Identifiable protocol compliance
    public var id: UUID { item.identity.id }

}
