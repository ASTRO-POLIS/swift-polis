//
//  PolisObservingFacility.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25/09/2024.
//

import Foundation

public class PolisObservingFacility: Identifiable, Codable {

    public enum ObservingFacilityLocationType: String, Codable {
        case surfaceFixed          = "surface_fixed"
        case surfaceMobile         = "surface_mobile"
        case airborneSelfPropelled = "airborne_self_propelled"
        case airborneBallon        = "airborne_ballon"
        case keplerianOrbital      = "keplerian_orbital"
        case nonKeplerianOrbital   = "non_keplerian_orbital"
        case unboundInterplanetary = "unbound_interplanetary"
        case other
    }

    public enum PlaceInTheSolarSystem: String, Codable {
        case sun         = "Sun"

        // Planets & Dwarfs
        case mercury     = "Mercury"
        case venus       = "Venus"
        case earth       = "Earth"
        case mars        = "Mars"
        case jupiter     = "Jupiter"
        case saturn      = "Saturn"
        case uranus      = "Uranus"
        case neptune     = "Neptune"
        case pluto       = "Pluto"
        case ceres       = "Ceres"

        // Miscellaneous
        case dwarfPlanet = "dwarf_planet"
        case moon
        case asteroid
        case comet
    }

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

    // Identifiable protocol compliance
    public var id: UUID { item.identity.id }

    // Relationship to other facilities
    public var parentObservingFacilityID: UUID?

    // Contains
    public var observatoryIDs: Set<UUID>?
    public var deviceIDs: Set<UUID>?

    // Info
    public var website: URL?
    public var scientificObjectives: String?
    public var history: String?

    // Facility details UUIDs - one and only one type could be assigned!
    public var fixedSurfaceEarthBaseDetailsID: UUID?
    public var mobileSurfaceEarthBaseDetailsID: UUID?
    public var airborneEarthBaseDetailsID: UUID?

    //TODO: ... and satellites, rovers, ... to be added

    public init(item: PolisItem,
                gravitationalBodyRelationship: ObservingFacilityLocationType,
                placeInTheSolarSystem: PlaceInTheSolarSystem,
                observingFacilityCode: String?                    = nil,
                solarSystemBodyName: String?                      = nil,
                orbitingAroundPlaceInTheSolarSystemNamed: String? = nil,
                facilityLocationID: UUID?                         = nil,
                astronomicalCode: String?                         = nil,
                parentObservingFacilityID: UUID?                  = nil,
                observatoryIDs: Set<UUID>?                        = nil,
                deviceIDs: Set<UUID>?                             = nil,
                website: URL?                                     = nil,
                scientificObjectives: String?                     = nil,
                history: String?                                  = nil,
                fixedSurfaceEarthBaseDetailsID: UUID?             = nil,
                mobileSurfaceEarthBaseDetailsID: UUID?            = nil,
                airborneEarthBaseDetailsID: UUID?                 = nil) {
        self.item                                     = item
        self.gravitationalBodyRelationship            = gravitationalBodyRelationship
        self.placeInTheSolarSystem                    = placeInTheSolarSystem
        self.observingFacilityCode                    = observingFacilityCode
        self.solarSystemBodyName                      = solarSystemBodyName
        self.orbitingAroundPlaceInTheSolarSystemNamed = orbitingAroundPlaceInTheSolarSystemNamed
        self.facilityLocationID                       = facilityLocationID
        self.astronomicalCode                         = astronomicalCode
        self.parentObservingFacilityID                = parentObservingFacilityID
        self.observatoryIDs                           = observatoryIDs
        self.deviceIDs                                = deviceIDs
        self.website                                  = website
        self.scientificObjectives                     = scientificObjectives
        self.history                                  = history
        self.fixedSurfaceEarthBaseDetailsID           = fixedSurfaceEarthBaseDetailsID
        self.mobileSurfaceEarthBaseDetailsID          = mobileSurfaceEarthBaseDetailsID
        self.airborneEarthBaseDetailsID               = airborneEarthBaseDetailsID
    }
}

public extension PolisObservingFacility {
    enum CodingKeys: String, CodingKey {
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
