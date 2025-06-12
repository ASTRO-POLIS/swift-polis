//
//  PolisCommonTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 08/06/2025.
//

import Foundation

public enum PolisObservingFacilityLocationType: String, Codable, CaseIterable, Equatable {
    case surfaceFixed          = "surface_fixed"
    case surfaceMobile         = "surface_mobile"
    case airborneSelfPropelled = "airborne_self_propelled"
    case airborneBallon        = "airborne_ballon"
    case keplerianOrbital      = "keplerian_orbital"
    case nonKeplerianOrbital   = "non_keplerian_orbital"
    case unboundInterplanetary = "unbound_interplanetary"
    case other
}

public enum PolisPlaceInTheSolarSystem: String, Codable, CaseIterable, Equatable {
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
