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
    public struct DirectoryEntry: Identifiable {

        /// `ProviderType` defines different types of POLIS Providers.
        ///
        /// In general, only `public` and `mirror` types should be used by clients. Astro clubs and other communities might
        /// access `private` providers, but they probably will allow only a restricted access to members only.
        public enum ProviderType {

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
            case mirror(id: String) // The `id` of the service provider being mirrored.
        }

        //TODO: Add docs!
        public enum ServiceReachability: String, Codable  {
            case reachableAndResponsive
            case reachableButSlow
            case currentlyUnreachable
            case permanentlyUnreachable
        }

        /// `id` should never be changed.
        public var id: UUID
        public var reachabilityStatus: ServiceReachability
        public var name: String
        public var shortDescription: String?
        public var lastUpdate: Date

        /// The fully qualified URL of the service provider, e.g. https://polis.observer
        public var url: String

        /// A list of one or more supported implementations
        public var supportedImplementations: [PolisImplementationInfo]

        /// Defines the type of the POLIS service provider e.g. public, experimental, mirror, ...
        public var providerType: ProviderType

        /// POLIS service provider's admin contact
        ///
        /// It is recommended that the contact information exposes no or very limited personal information
        public var contact: PolisAdminContact

        /// `id` is needed to make the structure `Identifiable`
        ///

        /// Possible errors while creating a `PolisDirectoryEntry`
        public enum DirectoryEntryError: Error {
            case emptyListOfSupportedImplementations
            case noneOfTheRequestedImplementationsIsSupportedByTheFramework
        }

        /// Designated initialiser.
        public init(id:                       UUID = UUID(),
                    reachabilityStatus:       ServiceReachability = .currentlyUnreachable,
                    name:                     String,
                    shortDescription:         String? = nil,
                    lastUpdate:               Date = Date(),
                    url:                      String,
                    providerDescription:      String?,
                    supportedImplementations: [PolisImplementationInfo],
                    providerType:             ProviderType,
                    contact:                  PolisAdminContact) throws {
            guard !supportedImplementations.isEmpty else { throw DirectoryEntryError.emptyListOfSupportedImplementations }


            let suggestedImplementations = Set(supportedImplementations)
            let supportedImplementations = Set(frameworkSupportedImplementation)
            let intersection             = supportedImplementations.intersection(suggestedImplementations)
            let filtered                 = Array(intersection)

            guard !filtered.isEmpty else { throw DirectoryEntryError.noneOfTheRequestedImplementationsIsSupportedByTheFramework }

            self.id                       = id
            self.reachabilityStatus       = reachabilityStatus
            self.name                     = name
            self.shortDescription         = shortDescription
            self.lastUpdate               = lastUpdate
            self.url                      = url
            self.supportedImplementations = filtered
            self.providerType             = providerType
            self.contact                  = contact
        }
    }



    public var lastUpdate: Date                // Used for syncing
    public var entries: [DirectoryEntry]  // List of all known providers, including it's own provider entry

    /// Designated initialiser.
    /// - Parameters:
    ///   - lastUpdate: if omitted, the current date and time will be used
    ///   - entries: possibly empty list of known POSIL service providers. `entries` must contain at least the
    ///   `PolisDirectoryEntry` for its own provider. Otherwise the method returns `nil`.
    public init?(lastUpdate: Date = Date(),
                entries: [DirectoryEntry]) {
        guard !entries.isEmpty else { return nil }

        self.lastUpdate = lastUpdate
        self.entries    = entries
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
        public var type: PolisObservingType
        public var parentObservingSiteID: UUID?

        public var id: UUID { identity.id }

        public init(identity: PolisIdentity, type: PolisObservingType, parentObservingSiteID: UUID? = nil) {
            self.identity = identity
            self.type     = type
            self.parentObservingSiteID = parentObservingSiteID
        }
    }

    public var lastUpdate: Date                   // UTC
    public var entries: [ObservingSiteReference]

    public init(lastUpdate: Date, entries: [ObservingSiteReference]) {
        self.lastUpdate = lastUpdate
        self.entries = entries
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

    public var lastUpdate: Date                   // UTC
    public var entries: [ResourceReference]

    public init(lastUpdate: Date, entries: [ResourceReference]) {
        self.lastUpdate = lastUpdate
        self.entries = entries
    }

}

//MARK: - Making types Codable and CustomStringConvertible -

//MARK: PolisProviderType
extension PolisDirectory.DirectoryEntry.ProviderType: Codable, CustomStringConvertible {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base      = try container.decode(ProviderType.self, forKey: .providerType)

        switch base {
            case .public:       self = .public
            case .private:      self = .private
            case .local:        self = .local
            case .experimental: self = .experimental
            case .mirror:
                let mirrorParams = try container.decode(MirrorParams.self, forKey: .mirrorParams)
                self = .mirror(id: mirrorParams.id)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
            case .public:       try container.encode(ProviderType.public,       forKey: .providerType)
            case .private:      try container.encode(ProviderType.private,      forKey: .providerType)
            case .local:        try container.encode(ProviderType.local,        forKey: .providerType)
            case .experimental: try container.encode(ProviderType.experimental, forKey: .providerType)
            case .mirror(let id):
                try container.encode(ProviderType.mirror, forKey: .providerType)
                try container.encode(MirrorParams(id: id), forKey: .mirrorParams)
        }
    }

    public var description: String {
        switch self {
            case .public:         return "public"
            case .private:        return "private"
            case .local:          return "local"
            case .experimental:   return "experimental"
            case .mirror(let id): return "mirror(id: \(id)"
        }
    }

    enum CodingKeys: String, CodingKey {
        case providerType = "type"
        case mirrorParams = "mirror"
    }

    private enum ProviderType: String, Codable { case `public`, `private`, local, experimental, mirror }

    private struct MirrorParams: Codable { let id: String }

}

extension PolisDirectory.DirectoryEntry.ServiceReachability {
    public enum CodingKeys: String, CodingKey {
        case reachableAndResponsive = "reachable_and_responsive"
        case reachableButSlow       = "reachable_but_slow"
        case currentlyUnreachable   = "currently_unreachable"
        case permanentlyUnreachable = "permanently_unreachable"
    }
}

//MARK: - PolisDirectoryEntry
extension PolisDirectory.DirectoryEntry: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case reachabilityStatus       = "reachability_status"
        case name
        case shortDescription         = "short_description"
        case lastUpdate               = "last_update"
        case url
        case supportedImplementations = "supported_implementations"
        case providerType             = "provider_type"
        case contact
    }
}

//MARK: - PolisDirectory
extension PolisDirectory: Codable {
    public enum CodingKeys: String, CodingKey {
        case lastUpdate = "last_updated"
        case entries
    }
}

extension PolisObservingSiteDirectory {
    public enum CodingKeys: String, CodingKey {
        case lastUpdate = "last_updated"
        case entries
    }
}

extension PolisObservingSiteDirectory.ObservingSiteReference {
    public enum CodingKeys: String, CodingKey {
        case identity
        case type
        case parentObservingSiteID = "parent_observing_site_id"
    }
}

extension PolisResourceSiteDirectory {
    public enum CodingKeys: String, CodingKey {
        case lastUpdate = "last_updated"
        case entries
    }
}

extension PolisResourceSiteDirectory.ResourceReference {
    public enum CodingKeys: String, CodingKey {
        case identity
        case uniqueManufacturerName = "unique_manufacturer_name"
        case deviceTypes            = "device_types"
    }
}
