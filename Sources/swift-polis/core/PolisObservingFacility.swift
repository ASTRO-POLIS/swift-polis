//
//  PolisObservingFacility2.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25/09/2024.
//

import Foundation

public struct PolisObservingFacility: Identifiable, Codable {

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
        case sun                = "Sun"

        // Planets & Dwarfs
        case mercury            = "Mercury"
        case venus              = "Venus"
        case earth              = "Earth"
        case mars               = "Mars"
        case jupiter            = "Jupiter"
        case saturn             = "Saturn"
        case uranus             = "Uranus"
        case neptune            = "Neptune"
        case pluto              = "Pluto"
        case ceres              = "Ceres"

        // Miscellaneous
        case dwarfPlanet
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

}
