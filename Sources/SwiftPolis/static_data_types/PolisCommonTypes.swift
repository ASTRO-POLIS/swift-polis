//===----------------------------------------------------------------------===//
//  PolisCommonTypes.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2026 Tuparev Technologies and the ASTRO-POLIS project
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

/// All strings that might appear in multiple languages are represented by a ``Sting``dictionary, where:
/// - The key is the language code (e.g. `en`, `en-uk`, `de`, etc
/// - The value is the string in the corresponding language
public typealias LocalisableString = [String : String]

/// Marks an object as POLIS objet
///
/// This allows the system to save, sync, update, and delete objects, change their status, and notify observers about the changes
protocol PolisObject: Codable {
    func polisDataType() -> PolisDataType
}

/// Represents the type of POLIS data object.
///
/// `PolisDataType` distinguishes between different kinds of objects managed within the POLIS system. Each case identifies a unique data structure or entity
/// such as a directory, entry,, facility, artifact, etc..
/// This type is used for polymorphic handling, type identification, persistence, and synchronisation of objects in the POLIS infrastructure.
///
/// - Note: Use the appropriate `PolisDataType` when conforming to ``PolisObject`` to ensure correct serialisation, type-based operations, and
///         association with POLIS services.
/// - Important: If a new POLIS object type is introduced, add a new case here and ensure corresponding handling logic exists throughout the stack.
///
/// Cases:
///   - `providerDirectory`: Directory of providers.
///   - `providerDirectoryEntry`: Entry in the provider directory, describing the service provider.
///   - `observingFacilityReference`: Reference to an observing facility.
///   - `observingFacilityDirectory`: Directory of observing facilities.
///   - `identity`: Identity object.
///   - `placeOnEarth`: Geographical place on Earth.
///   - `visitingHours`: Visiting hours for a facility,  observatory, or artifact.
///   - `observingFacility`: Observing facility record.
///   - `observingFacilityDetail`: Detailed information about an observing facility.
///   - `observingFacilityEarthFixedBasedDetails`: Earth-fixed based details for a facility.
///   - `artifact`: Artifact object, like museum, information center, monument, etc.
///   - `mediaSource`: Media source object.
///   - `unknown`: Unknown or unspecified data type.
public enum PolisDataType: String, Codable, Equatable, Hashable, Sendable {
    case providerDirectory                       = "provider_directory"
    case providerDirectoryEntry                  = "provider_directory_entry"

    case observingFacilityReference              = "observing_facility_reference"
    case observingFacilityDirectory              = "observing_facility_directory"


    case identity

    case placeOnEarth                            = "place_on_earth"

    case visitingHours                           = "visiting_hours"

    case observingFacility                       = "observing_facility"
    case observingFacilityDetail                 = "observing_facility_detail"
    case observingFacilityEarthFixedBasedDetails = "observing_facility_earth_fixed_based_details"


    case artifact
    case mediaSource                             = "media_source"

    case unknown
}

//MARK: - PolisLifecycleStatus -
/// The current status of the POLIS identifiable object and its readiness to be used in different environments.
///
/// Each POLIS type (Provider, Observing Facility, Device, etc.) should include `LifecycleStatus` (as part of ``PolisIdentity``).
///
/// `LifecycleStatus` will also determine the syncing policy as well as the visibility of the POLIS items within client implementations. Implementations
/// should adopt the following behaviours:
/// - `inactive`  - do not sync, but continue monitoring
/// - `active`    - must be synced and monitored
///  - `historic` - must be synced and monitored
/// - `deleted`   - sync the POLIS object only to prevent secondary propagation of the item and to lock the
/// UUID of the item
/// - `delete`    - sync the POLIS object only to prevent secondary propagation of the item and to lock the
/// UUID of the item
/// - `suspended` - sync the POLIS Object, but do not use the use it. Suspended is used to mark that the item does not follow the POLIS standard, or violates
/// community rules. Normally entities will be warned first, and if they continue to break standards and rules, they will be deleted.
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

/// Defines the spatial or physical relationship between an observing facility (such as an observatory) and its associated gravitational body (planet, moon, etc).
///
/// This enumeration is used to categorise the primary location context or operational platform of an observing facility within the POLIS system. The value describes
/// whether the facility is fixed to a planetary surface, located in a mobile platform (such as an aircraft or balloon), placed in an orbital configuration, or situated in
/// interplanetary space.
///
/// - Cases:
///   - `surfaceFixed`: The facility is fixed to the surface of a planetary body (e.g., ground-based observatory).
///   - `surfaceMobile`: The facility is mobile on the surface (e.g., vehicle-based platforms, rover, etc.).
///   - `airborneSelfPropelled`: The facility is airborne with its own propulsion (e.g., airplane-based telescopes).
///   - `airborneBallon`: The facility operates from a balloon platform.
///   - `keplerianOrbital`: The facility is in a Keplerian (gravitationally bound) orbit (e.g., satellite observatories).
///   - `nonKeplerianOrbital`: The facility is in a non-Keplerian (actively maintained) orbit (e.g., space station with propulsion).
///   - `unboundInterplanetary`: The facility is not gravitationally bound (e.g., interplanetary probes or flybys).
///   - `other`: Any location type not covered by the above cases.
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

/// Describes the primary astronomical body or class of object with which an observing facility or artifact is associated.
///
/// This enumeration is used to specify the main planetary, dwarf planet, small body, or other Solar System object relevant to a POLIS object, such as an
/// observatory's location. This helps categorise facilities  by their spatial and scientific context.
///
/// - Cases:
///   - `sun`: The Sun.
///   - `mercury`, `venus`, `earth`, `mars`, `jupiter`, `saturn`, `uranus`, `neptune`: The eight classical planets.
///   - `pluto`: Pluto (dwarf planet).
///   - `ceres`, `humea`, `makemake`, `eris`: Notable dwarf planets in the Solar System.
///   - `dwarfPlanet`: Any other dwarf planet not explicitly listed.
///   - `asteroidBeltObject`: Asteroids located in the main asteroid belt.
///   - `kuiperBeltObject`: Objects located in the Kuiper Belt.
///   - `oortCloudObject`: Objects located in the Oort Cloud.
///   - `moon`: Any natural satellite (moon) of a planet or dwarf planet.
///   - `asteroid`: General asteroid not otherwise specified.
///   - `comet`: Any cometary body.
///
/// - Note: This type is extensible to support additional Solar System objects as required by scientific or operational needs.
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
    case humaea      = "Humea"
    case makemake    = "Mamemake"
    case eris        = "Eris"

    // Miscellaneous
    case dwarfPlanet = "dwarf_planet"
    case asteroidBeltObject = "asteroid_belt_object"
    case kuiperBeltObject = "kuiper_belt_object"
    case oortCloudObject = "oort_cloud_object"
    case moon
    case asteroid
    case comet
}

/// Defines the mode of operation (and therefore, the level of automation) of corresponding POLIS Object (e.g. Observatory or Device)
///
/// This enumeration represents the primary control or interaction paradigm under which a facility, observatory, or device functions. The mode of operation affects
///  how the object is accessed, scheduled, and interacted with—covering manual, remote, autonomous, and mixed scenarios.
///
/// - Cases:
///   - `manual`: Operated directly by a human on-site, with no automation.
///   - `autonomous`: Functions automatically with minimal or no human intervention, but without a dynamic scheduler.
///   - `remote`: Controlled by humans at a distance, typically via networked interfaces, but not fully robotic.
///   - `robotic`: Fully robotic operation, with dynamic scheduling and automated task execution.
///   - `mixed`: Supports multiple operation modes (e.g., both manual and remote, or a network with mixed facilities).
///   - `other`: Operation mode does not fit any standard category.
///   - `notApplicable`: The concept of operation mode does not apply to this object.
///   - `unknown`: The operation mode is unknown or has not been specified.
///
/// - Note: The mode of operation helps users and systems understand the scheduling, access, and control capabilities of an object.
///         For example, robotic and autonomous facilities support programmatic scheduling, whereas manual facilities do not.
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

/// Represents the coverage of the electromagnetic spectrum or related detection capabilities for a POLIS object
/// (such as an observatory or device).
///
/// This enumeration is used to categorized the primary detection or observational range of an entity,
/// which could be in different parts of the electromagnetic spectrum or in related fields like gravitational
/// or neutrino detection.
///
/// - Note: The coverage can help users discover facilities or instruments based on scientific needs.
/// - Important: For multi-modal instruments or observatories, select `other` or provide additional description
///              elsewhere as appropriate.
///
/// - Cases:
///   - `gammaRay`: Coverage in the gamma-ray portion of the electromagnetic spectrum.
///   - `xRay`: Coverage in the X-ray portion of the electromagnetic spectrum.
///   - `ultraviolet`: Coverage in the ultraviolet portion of the electromagnetic spectrum.
///   - `optical`: Coverage in the optical (visible light) portion of the electromagnetic spectrum.
///   - `infrared`: Coverage in the infrared portion of the electromagnetic spectrum.
///   - `subMillimeter`: Coverage in the sub-millimeter portion of the electromagnetic spectrum.
///   - `radio`: Coverage in the radio portion of the electromagnetic spectrum.
///   - `gravitational`: Gravitational wave detection capability.
///   - `neutrino`: Neutrino detection capability.
///   - `other`: Other or mixed coverage not listed above.
///   - `unknown`: The spectrum coverage is unknown or not specified.
public enum PolisElectromagneticSpectrumCoverage: String, Codable, Sendable {
    case gammaRay      = "gamma_ray"
    case xRay          = "x_ray"
    case ultraviolet
    case optical
    case infrared
    case subMillimeter = "sub_millimeter"
    case radio
    case gravitational
    case neutrino
    case other
    case unknown
}

//MARK: Useful extensions
extension PolisObject {
    func polisDataType() -> PolisDataType { .unknown }
}
