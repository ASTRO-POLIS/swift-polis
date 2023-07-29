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

// **Note for Swift developers:** COURAGEOUS and IMPORTANT ASSUMPTION: Types defined in this file and in should not have
// incompatible coding/decoding and API changes in future versions of the standard! All other types could evolve.
// The types defined here are only simple lists of IDs and last update dates.

/// `PolisDirectory` is the list of all known Polis providers.
///
/// To avoid confusion (and potential syncing errors) it is required that the directory does contain the POLIS
/// service provider entry that serves the directory list.
public struct PolisDirectory  {

    //MARK: - POLIS Directory Entry

    /// `PolisDirectoryEntry` encapsulates all information needed to identify a site as a POLIS provider.
    ///
    /// `PolisDirectoryEntry` is used to define the Polis provider itself, as well as as an entry in the list of known Polis
    /// providers.
    public struct ProviderDirectoryEntry: Identifiable {

        /// `ProviderType` defines different types of POLIS Providers.
        ///
        /// In general, only `public` and `mirror` types should be used by clients. Astro clubs and other communities might
        /// access `private` providers, but they probably will allow only a restricted access to members only.
        public enum ProviderType: String, Codable {

            /// Only `public` provider should be used in production or by publicly available client apps or websites. Public
            /// providers should run on servers with enough bandwidth and computational power capable of accommodating multiple
            /// parallel client requests every second.
            case `public`

            /// `private` provider's main purpose is to act as a local cache for a larger organisation and should not be accessed
            /// from outside. Also an organisation like amateur clubs might maintain private providers. They might require user
            /// authentication.
            case `private`

            /// `local` could be used for clients running on mobile devices or desktop apps. It is a disposable local (often
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
        /// If your Service Provider cannot reach reliably another Service Provider, first check if this is also observed elsewhere, and if this is the case, only then
        /// change the local reachability status.
        ///
        /// During syncing between Service Providers sync only information about reachable hosts!
        public enum ServiceReachability: String, Codable  {

            /// `reachableAndResponsive` identifies stable and fast Service Provider.
            case reachableAndResponsive = "reachable_and_responsive"

            /// `reachableButSlow` marks reachable but somehow sluggish Service Provider.
            case reachableButSlow       = "reachable_but_slow"

            /// `currentlyUnreachable` marks temporary unreachable Service Provider.
            case currentlyUnreachable   = "currently_unreachable"

            /// `permanentlyUnreachable` marks Service Providers that are down for longer period of time. After ca. 18 months, the data about them could
            /// be deleted permanently
            case permanentlyUnreachable = "permanently_unreachable"
        }

        /// Possible errors while creating a `PolisDirectoryEntry`
        public enum DirectoryEntryError: Error {
            case emptyListOfSupportedImplementations
            case noneOfTheRequestedImplementationsIsSupportedByTheFramework
            case mirrorIdNotAssigned
        }

        /// `id` should never be changed.
        public var id: UUID

        public var mirrorID: UUID?

        /// The reachability status of a Service Provider entry
        public var reachabilityStatus: ServiceReachability

        /// The name of the Service Provider
        public var name: String

        /// Optional short description of the Service Provider
        public var shortDescription: String?

        /// The last update date. Change this only if the data of the provider is really changed.
        public var lastUpdate: Date

        /// The fully qualified URL of the service provider, e.g. https://polis.observer
        public var url: String

        /// A list of one or more supported implementations
        public var supportedImplementations: [PolisImplementation]

        /// Defines the type of the POLIS service provider e.g. public, experimental, mirror, ...
        public var providerType: ProviderType

        /// POLIS service provider's admin contact
        ///
        /// It is recommended that the contact information exposes no or very limited personal information
        public var adminContact: PolisAdminContact

        /// `id` is needed to make the structure `Identifiable`
        ///

        /// Designated initialiser.
        public init(id:                       UUID                = UUID(),
                    mirrorID:                 UUID?               = nil,
                    reachabilityStatus:       ServiceReachability = .currentlyUnreachable,
                    name:                     String,
                    shortDescription:         String?             = nil,
                    lastUpdate:               Date                = Date(),
                    url:                      String,
                    supportedImplementations: [PolisImplementation],
                    providerType:             ProviderType,
                    adminContact:             PolisAdminContact) throws {
            if supportedImplementations.isEmpty               { throw DirectoryEntryError.emptyListOfSupportedImplementations }
            if (providerType == .mirror) && (mirrorID == nil) { throw DirectoryEntryError.mirrorIdNotAssigned }

            let suggestedImplementations = Set(supportedImplementations)
            let supportedImplementations = Set(PolisConstants.frameworkSupportedImplementation)
            let intersection             = supportedImplementations.intersection(suggestedImplementations)
            let filtered                 = Array(intersection)

            guard !filtered.isEmpty else { throw DirectoryEntryError.noneOfTheRequestedImplementationsIsSupportedByTheFramework }

            self.id                       = id
            self.mirrorID                 = mirrorID
            self.reachabilityStatus       = reachabilityStatus
            self.name                     = name
            self.shortDescription         = shortDescription
            self.lastUpdate               = lastUpdate
            self.url                      = url
            self.supportedImplementations = filtered
            self.providerType             = providerType
            self.adminContact             = adminContact
        }
    }

    public var lastUpdate: Date                                   // Used for syncing
    public var providerDirectoryEntries: [ProviderDirectoryEntry] // List of all known providers, including it's own provider entry

    /// Designated initialiser.
    /// - Parameters:
    ///   - lastUpdate: if omitted, the current date and time will be used
    ///   - directoryEntries: possibly empty list of known POSIL service providers. `entries` must contain at least the
    ///   `PolisDirectoryEntry` for its own provider. Otherwise the method returns `nil`.
    public init?(lastUpdate: Date = Date(),
                 providerDirectoryEntries: [ProviderDirectoryEntry]) {
        guard !providerDirectoryEntries.isEmpty else { return nil }

        self.lastUpdate               = lastUpdate
        self.providerDirectoryEntries = providerDirectoryEntries
    }
}

//MARK: - Observing Site Directory -

/// A compact list of all known Observing Sites
public struct PolisObservingSiteDirectory: Codable {

    /// It is expected, that the list of observatory sites is long and each site's data could be way over 1MB. Therefore a
    /// compact list of site references is maintained separately containing only site UUIDs and last update time. It is
    /// recommended that clients cache this list and update the observatory data only in case the cache needs to be
    /// invalidated (e.g. lastUpdate is changed).
    public struct ObservingSiteReference: Codable, Identifiable {
        public var identity: PolisIdentity
        public var observingType: PolisObservingType
        public var parentObservingSiteID: UUID?

        public var id: UUID { identity.id }

        public init(identity: PolisIdentity, observingType: PolisObservingType, parentObservingSiteID: UUID? = nil) {
            self.identity              = identity
            self.observingType         = observingType
            self.parentObservingSiteID = parentObservingSiteID
        }
    }

    public var lastUpdate: Date                                   // UTC
    public var observingSiteReferences: [ObservingSiteReference]

    public init(lastUpdate: Date, observingSiteReferences: [ObservingSiteReference]) {
        self.lastUpdate              = lastUpdate
        self.observingSiteReferences = observingSiteReferences
    }
}

//MARK: - Resources provided by manufacturers -

//TODO: Documentation!
//WARNING: This here is very wrong! What actually is needed is a list of referred devices. Obviously Georg was drunk while writing this!
public struct PolisResourceSiteDirectory: Codable {

    public struct ResourceReference: Codable, Identifiable {
        public var identity: PolisIdentity
        public var uniqueManufacturerName: String
        public var deviceTypes: [PolisDevice.DeviceType]

        public var id: UUID { identity.id }

        public init(identity: PolisIdentity, uniqueName: String, deviceTypes: [PolisDevice.DeviceType] = [PolisDevice.DeviceType]()) {
            self.identity               = identity
            self.uniqueManufacturerName = uniqueName
            self.deviceTypes            = deviceTypes
        }
    }

    public var lastUpdate: Date                        // UTC
    public var resourceReferences: [ResourceReference]

    public init(lastUpdate: Date, resourceReferences: [ResourceReference]) {
        self.lastUpdate         = lastUpdate
        self.resourceReferences = resourceReferences
    }

}

//MARK: - Making types Codable and CustomStringConvertible -


//MARK: - PolisDirectoryEntry
extension PolisDirectory.ProviderDirectoryEntry: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case mirrorID                 = "mirror_id"
        case reachabilityStatus       = "reachability_status"
        case name
        case shortDescription         = "short_description"
        case lastUpdate               = "last_update"
        case url
        case supportedImplementations = "supported_implementations"
        case providerType             = "provider_type"
        case adminContact             = "admin_contact"
    }
}

//MARK: - PolisDirectory
extension PolisDirectory: Codable {
    public enum CodingKeys: String, CodingKey {
        case lastUpdate               = "last_updated"
        case providerDirectoryEntries = "provider_directory_entries"
    }
}

extension PolisObservingSiteDirectory {
    public enum CodingKeys: String, CodingKey {
        case lastUpdate              = "last_updated"
        case observingSiteReferences = "observing_site_references"
    }
}

extension PolisObservingSiteDirectory.ObservingSiteReference {
    public enum CodingKeys: String, CodingKey {
        case identity
        case observingType         = "observing_type"
        case parentObservingSiteID = "parent_observing_site_id"
    }
}

extension PolisResourceSiteDirectory {
    public enum CodingKeys: String, CodingKey {
        case lastUpdate         = "last_updated"
        case resourceReferences = "resource_references"
    }
}

extension PolisResourceSiteDirectory.ResourceReference {
    public enum CodingKeys: String, CodingKey {
        case identity
        case uniqueManufacturerName = "unique_manufacturer_name"
        case deviceTypes            = "device_types"
    }
}
