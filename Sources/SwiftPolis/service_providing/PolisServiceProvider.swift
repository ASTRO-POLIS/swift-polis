//===----------------------------------------------------------------------===//
//  PolisServiceProvider.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2024 Tuparev Technologies and the ASTRO-POLIS project
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
import SoftwareEtudesUtilities

/// `PolisDirectory` is the list of all known Polis providers.
///
/// To avoid confusion (and potential syncing errors) it is required that the directory does contain the POLIS
/// service provider entry that serves the directory list.
public struct PolisDirectory: Sendable, PolisObject {

    //MARK: - POLIS Directory Entry

    /// `PolisDirectoryEntry` encapsulates all information needed to identify a site as a POLIS provider.
    ///
    /// `PolisDirectoryEntry` is used to define the Polis provider itself, as well as as an entry in the list of known Polis
    /// providers.
    public struct ProviderDirectoryEntry: Identifiable, Equatable, Sendable, PolisObject {

        /// `ProviderType` defines different types of POLIS Providers.
        /// 
        /// In general, only `publicPrimary` and `mirror` types should be used by clients. Astro clubs and other communities might
        /// access `private` providers, but they will probably only allow restricted access to members only.
        public enum ProviderType: String, Codable, Equatable, Sendable {

            /// Only `publicPrimary` provider should be used in production or by publicly available client apps or websites. Public
            /// providers should run on servers with enough bandwidth and computational power capable of accommodating multiple
            /// parallel client requests every second.
            case publicPrimary   = "public_primary"

            /// `publicSecondary` is a provider are Service Providers running on servers  with low bandwidth or insufficiently
            ///  powerful hardware. Examples include university servers, servers at manufacturing sites, or remote facilities with limited
            ///  bandwidth. These providers could be accessed locally and also synced with other providers, but should not be used as
            ///  providers for mobile apps or research networks.
            case publicSecondary = "public_secondary"

            /// A `private` provider's main purpose is to act as a local cache for a larger organisation and should not be accessed
            /// from outside. An organisation like amateur clubs might also maintain private providers. They might require user
            /// authentication.
            case `private`

            /// `local` could be used by client apps running on mobile devices or desktop apps. It is a disposable, local (often
            /// offline) cache.
            case local

            /// `experimental` providers are sandboxes for new developments, and might require authentication for access. They
            /// are allowed to be non-compliant with the POLIS standard.
            case experimental

            /// Only when a `public` provider is unreachable, its `mirror` (if available) should be accessed while the main server
            /// is down.
            case mirror // The `id` of the service provider being mirrored.
        }

        /// `ServiceReachability` indicates the reachability status of other Service Providers
        ///
        /// It is recommended not to change the reachability status too often, because this might escalate to excessive updates of Service Providers. Once every
        /// 24h should be sufficient. Also note, that an external server might be unreachable or slow from one location, but reachable and responsive from another.
        /// If your Service Provider cannot reach another Service Provider reliably, first check if this is also observed elsewhere, and if this is the case, only then
        /// change the local reachability status.
        public enum ServiceReachability: String, Codable, Equatable, Sendable  {

            /// `reachableAndResponsive` identifies stable and fast Service Provider.
            case reachableAndResponsive = "reachable_and_responsive"

            /// `reachableButSlow` marks reachable but somehow sluggish Service Provider.
            case reachableButSlow       = "reachable_but_slow"

            /// `currentlyUnreachable` marks temporary unreachable Service Provider.
            case currentlyUnreachable   = "currently_unreachable"

            /// `permanentlyUnreachable` marks Service Providers that are down for longer period of time. After ca. 18 months, the data could
            /// be deleted permanently
            case permanentlyUnreachable = "permanently_unreachable"

            /// `localUseOnly` should be set automatically for `private` and `local` providers.
            case localUseOnly           = "local_use_only"
        }

        /// Possible errors while creating a `PolisDirectoryEntry`
        public enum DirectoryEntryError: Error {
            case emptyListOfSupportedImplementations
            case noneOfTheRequestedImplementationsIsSupportedByTheFramework
            case mirrorIdNotAssigned
        }

        /// `id` should never be changed
        public internal(set) var id: UUID

        /// The ID of the Service Provider being mirrored
        public var mirrorID: UUID?

        /// The reachability status of a Service Provider entry
        public var reachabilityStatus: ServiceReachability

        /// The name of the Service Provider. It is recommended to use names in English
        public var name: String

        /// Optional short description of the Service Provider. Use English language is recommended.
        public var shortDescription: String?

        /// The last update date. Change this only if the data of the provider is really changed.
        public var lastUpdateTime: Date

        /// The fully qualified URL of the service provider, e.g. https://polis.observer
        public var url: String?

        /// A list of one or more supported implementations
        public var supportedImplementations: [PolisImplementation]

        /// Defines the type of the POLIS service provider e.g. public, experimental, mirror, ...
        public var providerType: ProviderType

        /// POLIS service provider's admin contact
        ///
        /// It is recommended that the contact information exposes no or very limited personal information
        public var contactEmail: String

        /// Designated initialiser.
        public init(id:                       UUID                = UUID(),
                    mirrorID:                 UUID?               = nil,
                    reachabilityStatus:       ServiceReachability = .currentlyUnreachable,
                    name:                     String,
                    shortDescription:         String?             = nil,
                    lastUpdateTime:           Date                = Date(),
                    url:                      String?             = nil,
                    supportedImplementations: [PolisImplementation],
                    providerType:             ProviderType,
                    contactEmail:             String) throws {
            if supportedImplementations.isEmpty               { throw DirectoryEntryError.emptyListOfSupportedImplementations }
            if (providerType == .mirror) && (mirrorID == nil) { throw DirectoryEntryError.mirrorIdNotAssigned }

            let suggestedImplementations = Set(supportedImplementations)
            let supportedImplementations = Set(PolisConstants.polisFrameworkSupportedImplementations)
            let intersection             = supportedImplementations.intersection(suggestedImplementations)
            let filtered                 = Array(intersection)

            guard !filtered.isEmpty else { throw DirectoryEntryError.noneOfTheRequestedImplementationsIsSupportedByTheFramework }

            self.id                       = id
            self.mirrorID                 = mirrorID
            self.reachabilityStatus       = reachabilityStatus
            self.name                     = name
            self.shortDescription         = shortDescription
            self.lastUpdateTime           = lastUpdateTime
            self.url                      = url
            self.supportedImplementations = filtered
            self.providerType             = providerType
            self.contactEmail             = contactEmail
        }

        func polisDataType() -> PolisDataType { .providerDirectoryEntry }

    }

    public var lastUpdateTime: Date                               // Used for syncing
    public var providerDirectoryEntries: [ProviderDirectoryEntry] // List of all known providers, including it's own provider entry

    /// Designated initialiser.
    /// - Parameters:
    ///   - lastUpdate: if omitted, the current date and time will be used
    ///   - directoryEntries: possibly empty list of known POSIL service providers. `entries` must contain at least the
    ///   `PolisDirectoryEntry` for its own provider. Otherwise the method returns `nil`.
    public init?(lastUpdateTime: Date = Date(),
                 providerDirectoryEntries: [ProviderDirectoryEntry]) {
        guard !providerDirectoryEntries.isEmpty else { return nil }

        self.lastUpdateTime           = lastUpdateTime
        self.providerDirectoryEntries = providerDirectoryEntries
    }

    func polisDataType() -> PolisDataType { .providerDirectory }

    //TODO: Move to AppSupport!
//    //MARK: Non-public APIs
//    static var isSynced = false
//    static var syncDate = Date.distantPast
}

//MARK: - Observing Facility Directory -

/// A compact list of all known Observing Facilities
public struct PolisObservingFacilityDirectory: Codable, Sendable, PolisObject {
    

    /// It is expected that the list of observatory facilities is long and each facility's data could be way over 1MB. Therefore a
    /// compact list of facilities references is maintained separately containing only facility's `identity`  It is
    /// recommended that clients cache this list and update the observatory data only in case the cache needs to be
    /// invalidated (e.g. lastUpdate is changed).
    ///
    ///  **Note:** Only root facility (e.g. without a parent facility) should be listed!
    public struct ObservingFacilityReference: Codable, Identifiable, Equatable, Sendable, PolisObject {

        // Identification
        public var identity: PolisIdentity
        public var observingFacilityCode: String?

        // Where in the Solar system
        /// Used if currently located on this SolarSystem Planet, Moon, Asteroid, etc.
        public var placeInTheSolarSystem: PolisPlaceInTheSolarSystem? = .earth

        /// Used if currently orbiting around  this SolarSystem Planet, Moon, Asteroid, etc.
        public var orbitingAroundPlaceInTheSolarSystem: PolisPlaceInTheSolarSystem?

        /// Defines the relationship to the place in the Solar system: fixed on the surface, airborne, rover, unbound, ...
        public var gravitationalBodyRelationship: PolisObservingFacilityLocationType

        /// When the facility is in transition, `startingPointOfFacilityInTransition` defines the starting point (body)
        public var startingPointOfFacilityInTransition: PolisPlaceInTheSolarSystem?

        /// When the facility is in transition, `destinationPointOfFacilityInTransition` defines the destination point (body)
        public var destinationPointOfFacilityInTransition: PolisPlaceInTheSolarSystem?

        /// Many Solar system object are classified by IAU and other organisations, like minor planet codes, etc.
        public var astronomicalCode: String?

        /// Facility main details
        public var facilityDetailsID: UUID?


        /// Depending on the type of the facility, `facilityLocationID` could point to either Earth-Based fixed
        /// location, satellite orbital elements, current position of a Mars rover etc. Facility's details can use
        /// `facilityLocationID` to load the proper data.
        public var facilityLocationDetailsID: UUID?

        public var id: UUID { identity.id }
        
        public init(identity: PolisIdentity,
                    observingFacilityCode: String?                                      = nil,
                    placeInTheSolarSystem: PolisPlaceInTheSolarSystem?                  = .earth,
                    orbitingAroundPlaceInTheSolarSystem: PolisPlaceInTheSolarSystem?    = nil,
                    gravitationalBodyRelationship: PolisObservingFacilityLocationType   = .surfaceFixed,
                    startingPointOfFacilityInTransition: PolisPlaceInTheSolarSystem?    = nil,
                    destinationPointOfFacilityInTransition: PolisPlaceInTheSolarSystem? = nil,
                    astronomicalCode: String?                                           = nil,
                    facilityDetailsID: UUID?                                            = nil,
                    facilityLocationDetailsID: UUID?                                    = nil) {
            self.identity                               = identity
            self.observingFacilityCode                  = observingFacilityCode
            self.placeInTheSolarSystem                  = placeInTheSolarSystem
            self.orbitingAroundPlaceInTheSolarSystem    = orbitingAroundPlaceInTheSolarSystem
            self.gravitationalBodyRelationship          = gravitationalBodyRelationship
            self.startingPointOfFacilityInTransition    = startingPointOfFacilityInTransition
            self.destinationPointOfFacilityInTransition = destinationPointOfFacilityInTransition
            self.astronomicalCode                       = astronomicalCode
            self.facilityDetailsID                      = facilityDetailsID
            self.facilityLocationDetailsID              = facilityLocationDetailsID
        }

        func polisDataType() -> PolisDataType { .observingFacilityReference }

    }

    public var lastUpdateTime: Date // UTC
    public var observingFacilityReferences: [ObservingFacilityReference]

    public init(lastUpdateTime: Date, observingFacilityReferences: [ObservingFacilityReference]) {
        self.lastUpdateTime              = lastUpdateTime
        self.observingFacilityReferences = observingFacilityReferences
    }

    public func facilityReferenceWith(id: UUID) -> ObservingFacilityReference? {
        for reference in observingFacilityReferences {
            if id == reference.identity.id { return reference }
        }
        return nil
    }

    func polisDataType() -> PolisDataType { .observingFacilityDirectory }
}

//MARK: - Making types Codable -

extension PolisDirectory.ProviderDirectoryEntry: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case mirrorID                 = "mirror_id"
        case reachabilityStatus       = "reachability_status"
        case name
        case shortDescription         = "short_description"
        case lastUpdateTime           = "last_update_time"
        case url
        case supportedImplementations = "supported_implementations"
        case providerType             = "provider_type"
        case contactEmail             = "contact_email"
    }
}

extension PolisDirectory: Codable {
    public enum CodingKeys: String, CodingKey {
        case lastUpdateTime           = "last_updated_time"
        case providerDirectoryEntries = "provider_directory_entries"
    }
}

extension PolisObservingFacilityDirectory.ObservingFacilityReference {
    public enum CodingKeys: String, CodingKey {
        case identity
        case observingFacilityCode                  = "observing_facility_code"
        case placeInTheSolarSystem                  = "place_in_the_solar_system"
        case orbitingAroundPlaceInTheSolarSystem    = "orbiting_around_place_in_the_solar_system"
        case gravitationalBodyRelationship          = "gravitational_body_relationship"
        case startingPointOfFacilityInTransition    = "starting_point_of_facility_in_transition"
        case destinationPointOfFacilityInTransition = "destination_point_of_facility_in_transition"
        case astronomicalCode                       = "astronomical_code"
        case facilityDetailsID                      = "facility_details_id"
        case facilityLocationDetailsID              = "facility_location_details_id"
    }
}

extension PolisObservingFacilityDirectory {
    public enum CodingKeys: String, CodingKey {
        case lastUpdateTime              = "last_updated_time"
        case observingFacilityReferences = "observing_facility_references"
    }
}

