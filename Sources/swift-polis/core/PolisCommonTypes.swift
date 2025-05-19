//
//  PolisCommonTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 19.02.25.
//

import Foundation

/// Defines the type to be used where to store local data the stored data
public enum PolisRepresentingStoredObjectType: Int, CaseIterable {
    case observingFacility // Cannot be shared, this is the facility Info (Details)
    case observatory       // Can be shared
    case device            // Can be shared
    case artifact          // Cannot be shared
}

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

public enum PolisModeOfOperation: String, Codable {
    case manual
    case autonomous  // no dynamic schedular
    case remote
    case robotic
    case mixed       // e.g. in case of Network
    case other
    case unknown
}

public enum PolisElectromagneticSpectrumCoverage: String, Codable {
    case gammaRay      = "gamma_ray"
    case xRay          = "x_ray"
    case ultraviolet
    case optical
    case infrared
    case subMillimeter = "sub_millimeter"
    case radio
    case gravitational
    case other
    case unknown
    case neutrino
}

public enum PolisSorting {
    case none
    case dateAndTime
    case lastUpdated
}

protocol StorableItem {
    static func loadFromLocalFileSystemUsing(manager: PolisProviderManager) throws -> AnyObject
    func parentItem() -> (any StorableItem)?
    mutating func flashUsing(manager: PolisProviderManager) throws
}


