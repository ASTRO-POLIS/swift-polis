//
//  PolisCommonTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 08/06/2025.
//

import Foundation

protocol PolisObject { }

//MARK: - PolisLifecycleStatus -
/// The current status of the POLIS item (object) and its readiness to be used in different environments.
///
/// Each POLIS type (Provider, Observing Facility, Device, etc.) should include `LifecycleStatus` (as part of
/// ``PolisItem``).
///
/// `LifecycleStatus` will also determine the syncing policy as well as the visibility of the POLIS items within client
/// implementations. Implementations should adopt the following behaviours:
/// - `inactive`  - do not sync, but continue monitoring
/// - `active`    - must be synced and monitored
/// - `deleted`   - sync the `PolisItemAttributes` only to prevent secondary propagation of the item and to lock the
/// UUID of the item
///  - `historic` - do not sync, but continue monitoring
/// - `delete`    - delete the item
/// - `suspended` - sync the `PolisItemAttributes`, but do not use the service provider or the observing facility. Suspended
/// is used to mark that the item does not follow the POLIS standard, or violates community rules. Normally entities
/// will be warned first, and if they continue to break standards and rules, they will be deleted.
/// - `unknown`   - do not sync, but continue monitoring
public enum PolisLifecycleStatus: String, Codable, Equatable, Sendable {

    /// `inactive` indicates new, being edited, or in process of being upgraded by the provider(s).
    case inactive

    /// `active` indicates a production provider that is publicly accessible.
    case active

    /// Item still exists and has historical value but is not operational.
    case historic

    /// `deleted` is needed to prevent reappearance of disabled providers or facilities.
    case deleted

    /// After marking an item for deletion, wait for a year (check `lastUpdate`) and start marking the item as
    /// `delete`. After 18 months, remove the deleted items. It is assumed that 1.5 years is enough for all providers
    /// to mark the corresponding item as deleted.
    case delete

    /// `suspended` indicates providers violating the standard (temporary or permanently).
    case suspended

    /// `unknown` indicates a provider with unknown status, and is mostly used when the observing facility or instrument has
    /// unknown status.
    case unknown
}

public enum PolisObservingFacilityLocationType: String, Codable, CaseIterable, Equatable, Sendable {
    case surfaceFixed          = "surface_fixed"
    case surfaceMobile         = "surface_mobile"
    case airborneSelfPropelled = "airborne_self_propelled"
    case airborneBallon        = "airborne_ballon"
    case keplerianOrbital      = "keplerian_orbital"
    case nonKeplerianOrbital   = "non_keplerian_orbital"
    case unboundInterplanetary = "unbound_interplanetary"
    case other
}

public enum PolisPlaceInTheSolarSystem: String, Codable, CaseIterable, Equatable, Sendable {
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

public enum PolisModeOfOperation: String, Codable, Sendable {
    case manual
    case autonomous  // no dynamic schedular
    case remote
    case robotic
    case mixed       // e.g. in case of Network
    case other
    case notApplicable = "not_applicable"
    case unknown
}

public enum PolisElectromagneticSpectrumCoverage: String, Codable, Sendable {
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
