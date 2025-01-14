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
public struct PolisDirectory: StorableItem  {

    //MARK: - POLIS Directory Entry

    /// `PolisDirectoryEntry` encapsulates all information needed to identify a site as a POLIS provider.
    ///
    /// `PolisDirectoryEntry` is used to define the Polis provider itself, as well as as an entry in the list of known Polis
    /// providers.
    public struct ProviderDirectoryEntry: StorableItem, Identifiable {
        /// `ProviderType` defines different types of POLIS Providers.
        ///
        /// In general, only `public` and `mirror` types should be used by clients. Astro clubs and other communities might
        /// access `private` providers, but they will probably only allow restricted access to members only.
        public enum ProviderType: String, Codable {

            /// Only `public` provider should be used in production or by publicly available client apps or websites. Public
            /// providers should run on servers with enough bandwidth and computational power capable of accommodating multiple
            /// parallel client requests every second.
            case `public`

            /// A `private` provider's main purpose is to act as a local cache for a larger organisation and should not be accessed
            /// from outside. An organisation like amateur clubs might also maintain private providers. They might require user
            /// authentication.
            case `private`

            /// `local` could be used for clients running on mobile devices or desktop apps. It is a disposable, local (often
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
        ///
        /// During syncing between Service Providers sync only information about reachable hosts!
        public enum ServiceReachability: String, Codable  {

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
        public var url: String?

        /// A list of one or more supported implementations
        public var supportedImplementations: [PolisImplementation]

        /// Defines the type of the POLIS service provider e.g. public, experimental, mirror, ...
        public var providerType: ProviderType

        /// POLIS service provider's admin contact
        ///
        /// It is recommended that the contact information exposes no or very limited personal information
        public var contact: PolisPerson

        /// Designated initialiser.
        public init(id:                       UUID                = UUID(),
                    mirrorID:                 UUID?               = nil,
                    reachabilityStatus:       ServiceReachability = .currentlyUnreachable,
                    name:                     String,
                    shortDescription:         String?             = nil,
                    lastUpdate:               Date                = Date(),
                    url:                      String?             = nil,
                    supportedImplementations: [PolisImplementation],
                    providerType:             ProviderType,
                    contact:                  PolisPerson) throws {
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
            self.contact                  = contact
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

//MARK: - Observing Facility Directory -
fileprivate let fm = FileManager.default
fileprivate var data: Data?

/// A compact list of all known Observing Facilities
public struct PolisObservingFacilityDirectory: Codable, StorableItem {

    /// It is expected that the list of observatory facilities is long and each facility's data could be way over 1MB. Therefore a
    /// compact list of facilities references is maintained separately containing only facility's `identity`  It is
    /// recommended that clients cache this list and update the observatory data only in case the cache needs to be
    /// invalidated (e.g. lastUpdate is changed).
    ///
    ///  **Note:** Only root facility (e.g. without a parent facility) should be listed!
    public struct ObservingFacilityReference: Codable, Identifiable {
        public var identity: PolisIdentity

        public var id: UUID { identity.id }

        public init(identity: PolisIdentity) {
            self.identity = identity
        }
    }

    public var lastUpdate: Date                                   // UTC
    public var observingFacilityReferences: [ObservingFacilityReference]

    public init(lastUpdate: Date, observingFacilityReferences: [ObservingFacilityReference]) {
        self.lastUpdate                  = lastUpdate
        self.observingFacilityReferences = observingFacilityReferences
    }

    public mutating func addOrUpdateObservingFacility(reference: ObservingFacilityReference) {
        for var ref in observingFacilityReferences {
            if ref.id == reference.id {
                ref.identity.externalReferences    = reference.identity.externalReferences
                ref.identity.lastUpdateDate        = reference.identity.lastUpdateDate
                ref.identity.name                  = reference.identity.name
                ref.identity.localName             = reference.identity.localName
                ref.identity.abbreviation          = reference.identity.abbreviation
                ref.identity.shortDescription      = reference.identity.shortDescription
                ref.identity.startDate             = reference.identity.startDate
                ref.identity.endDate               = reference.identity.endDate
                ref.identity.polisRegistrationDate = reference.identity.polisRegistrationDate

                return
            }
        }
        
        observingFacilityReferences.append(reference)
        lastUpdate = Date.now
    }
}

//MARK: - Making types Codable -

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
        case contact
    }
}

extension PolisDirectory: Codable {
    public enum CodingKeys: String, CodingKey {
        case lastUpdate               = "last_updated"
        case providerDirectoryEntries = "provider_directory_entries"
    }
}

extension PolisObservingFacilityDirectory.ObservingFacilityReference {
    public enum CodingKeys: String, CodingKey {
        case identity
    }
}

extension PolisObservingFacilityDirectory {
    public enum CodingKeys: String, CodingKey {
        case lastUpdate                  = "last_updated"
        case observingFacilityReferences = "observing_facility_references"
    }
}

//MARK: - Implementing the StorableItem protocols -
extension PolisDirectory.ProviderDirectoryEntry {
    static func loadFromLocalFileSystemUsing(manager: PolisProviderManager) throws -> AnyObject {
        let finder = manager.polisFileResourceFinder!
        let path   = finder.configurationFile()
        let fm     = FileManager.default
        let data   = fm.contents(atPath: path)

        guard let data = data else { throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try JSONDecoder().decode(PolisDirectory.ProviderDirectoryEntry.self, from: data)

            return entry as AnyObject
        }
        catch { throw PolisProviderManager.PolisProviderManagerError.cannotDecodePolisType }
    }

    func parentItem() -> (any StorableItem)? { nil }

    mutating func flashUsing(manager: PolisProviderManager) throws {
        let finder = manager.polisFileResourceFinder!
        let path   = finder.configurationFile()

        self.lastUpdate = Date.now

        do    { data = try manager.jsonEncoder.encode(self) }
        catch {
            PolisLogger.shared.error("Cannot encode POLIS Provider Main Configuration Entry")
            throw PolisProviderManager.PolisProviderManagerError.cannotEncodePolisType
        }

        if !fm.createFile(atPath: path, contents: data) {
            PolisLogger.shared.error("Cannot save POLIS Provider Main Configuration Entry to: \(path)")
            throw PolisProviderManager.PolisProviderManagerError.cannotWriteFile
        }
    }
}

extension PolisDirectory {
    static func loadFromLocalFileSystemUsing(manager: PolisProviderManager) throws -> AnyObject {
        let finder = manager.polisFileResourceFinder!
        let path   = finder.polisProviderDirectoryFile()
        let fm     = FileManager.default
        let data   = fm.contents(atPath: path)

        guard let data = data else { throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try JSONDecoder().decode(PolisDirectory.self, from: data)

            return entry as AnyObject
        }
        catch { throw PolisProviderManager.PolisProviderManagerError.cannotDecodePolisType }
    }

    func parentItem() -> (any StorableItem)? { PolisProviderManager.currentProviderManager.polisProviderConfigurationEntry }

    mutating func flashUsing(manager: PolisProviderManager) throws {
        let finder = manager.polisFileResourceFinder!
        let path   = finder.polisProviderDirectoryFile()

        self.lastUpdate = Date.now

        do    { data = try manager.jsonEncoder.encode(self) }
        catch {
            PolisLogger.shared.error("Cannot encode POLIS Directory")
            throw PolisProviderManager.PolisProviderManagerError.cannotEncodePolisType
        }

        if !fm.createFile(atPath: path, contents: data) {
            PolisLogger.shared.error("Cannot save POLIS Directory to: \(path)")
            throw PolisProviderManager.PolisProviderManagerError.cannotWriteFile
        }

        try manager.polisProviderConfigurationEntry.flashUsing(manager: manager)
    }
}

extension PolisObservingFacilityDirectory {
    static func loadFromLocalFileSystemUsing(manager: PolisProviderManager) throws -> AnyObject {
        let finder = manager.polisFileResourceFinder!
        let path   = finder.observingFacilitiesDirectoryFile()
        let fm     = FileManager.default
        let data   = fm.contents(atPath: path)

        guard let data = data else { throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try JSONDecoder().decode(PolisObservingFacilityDirectory.self, from: data)

            return entry as AnyObject
        }
        catch { throw PolisProviderManager.PolisProviderManagerError.cannotDecodePolisType }
    }

    func parentItem() -> (any StorableItem)? { PolisProviderManager.currentProviderManager.polisProviderDirectory }

    mutating func flashUsing(manager: PolisProviderManager) throws {
        let finder = manager.polisFileResourceFinder!
        let path   = finder.observingFacilitiesDirectoryFile()

        self.lastUpdate = Date.now

        do    { data = try manager.jsonEncoder.encode(self) }
        catch {
            PolisLogger.shared.error("Cannot encode POLIS Observing Facility Directory")
            throw PolisProviderManager.PolisProviderManagerError.cannotEncodePolisType
        }

        if !fm.createFile(atPath: path, contents: data) {
            PolisLogger.shared.error("Cannot save POLIS Observing Facility Directory to: \(path)")
            throw PolisProviderManager.PolisProviderManagerError.cannotWriteFile
        }

        try manager.polisProviderConfigurationEntry.flashUsing(manager: manager)
    }
}
