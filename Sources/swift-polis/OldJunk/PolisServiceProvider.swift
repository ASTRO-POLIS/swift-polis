//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2022 Tuparev Technologies and the ASTRO-POLIS project
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

//MARK: - POLIS Directory Entry -
/// `PolisProviderType` defines different types of POLIS providers.
///
/// The type implements the `Codable` and `CustomStringConvertible` protocols
public enum PolisProviderType {
    /// Only `public` provider should be used in production or by publicly available client apps or websites. Public
    /// providers should run on servers with enough bandwidth and computational power capable of accommodating multiple
    /// parallel client requests every second.
    case `public`

    /// `private` provider's main purpose is to act as a local cache for larger organisations and should not be accessed
    /// from outside. Also organisations like amateur clubs might maintain private providers. They might require user
    /// authentication.
    case `private`

    /// `local` could be used for clients running on mobile devices or desktop apps. It is a disposable local (often
    /// offline) cache.
    case local

    /// `experimental` providers are sandboxes for new developments, and might require authentication for access. They
    /// are allowed to be non-compliant with the POLIS standard.
    case experimental

    /// Only when a `public` server is unreachable, its `mirror` (if available) should be accessed while the main server
    /// is down.
    case mirror(id: String) // The `id` of the service provider being mirrored.
}

/// `PolisDirectoryEntry` encapsulates all information needed to identify a site as a POLIS provider
///
/// `PolisDirectoryEntry` is used to define the Polis provider itself, as well as as an entry in the list of known Polis
/// providers.
///
/// The type implements the `Codable` and `Identifiable` protocols
public struct PolisDirectoryEntry: Identifiable {

    /// `attributes` are marked with "private(set)" on purpose. Only the framework should change the attributes and
    /// potential changes should be done only at specific moments of the lifespan of the entry. Otherwise syncing could
    /// be badly broken.
    public var attributes: PolisItemAttributes

    /// The fully qualified URL of the service provider, e.g. https://polis.observer
    public var url: String

    /// A list of one or more supported implementations
    public var supportedImplementations: [PolisSupportedImplementation]

    /// Defines the type of the POLIS service provider e.g. public, experimental, mirror, ...
    public var providerType: PolisProviderType

    /// POLIS service provider's admin contact
    ///
    /// It is recommended that the contact information exposes no or very limited personal information
    public var contact: PolisAdminContact

    /// `id` is needed to make the structure `Identifiable`
    ///
    /// `id` refers to attributes UUID and should never be changed.
    public var id: UUID { attributes.id }

    public enum PolisDirectoryEntryError: Error {
        case emptyListOfSupportedImplementations
        case noneOfTheRequestedImplementationsIsSupportedByTheFramework
    }

    /// Designated initialiser.
    public init(attributes:               PolisItemAttributes,
                url:                      String,
                providerDescription:      String?,
                supportedImplementations: [PolisSupportedImplementation],
                providerType:             PolisProviderType,
                contact:                  PolisAdminContact) throws {
        guard !supportedImplementations.isEmpty else { throw PolisDirectoryEntryError.emptyListOfSupportedImplementations }

        let suggestedImplementations = Set(supportedImplementations)
        let supportedImplementations = Set(frameworkSupportedImplementation)
        let intersection             = supportedImplementations.intersection(suggestedImplementations)
        let filtered                 = Array(intersection)

        guard !filtered.isEmpty else { throw PolisDirectoryEntryError.noneOfTheRequestedImplementationsIsSupportedByTheFramework }

        self.attributes               = attributes
        self.url                      = url
        self.supportedImplementations = filtered
        self.providerType             = providerType
        self.contact                  = contact
    }
}

/// `PolisDirectory` is the list of all known Polis providers.
///
/// To avoid confusion (and potential syncing errors) it is recommended that the directory does contain the POLIS
/// service provider entry that serves the directory list.
/// The type implements the `Codable` protocol.
public struct PolisDirectory  {
    public var lastUpdate: Date                // Used for syncing
    public var entries: [PolisDirectoryEntry]  // List of all known providers

    /// Designated initialiser.
    /// - Parameters:
    ///   - lastUpdate: if omitted, the current date and time will be used
    ///   - entries: possibly empty list of known POSIL service providers
    public init(lastUpdate: Date = Date(),
                entries: [PolisDirectoryEntry]) {

        //TODO: Only the "Big Bang" provider could have an empty list of entries. All other providers must have at least one entry to the "BigBang". If these conditions are not fulfilled, throw... needs a new Error type. But perhaps this needs to be in the ServiceProvider class? Here we should not have access to the root polis file!
        self.lastUpdate = lastUpdate
        self.entries    = entries
    }
}

/// It is expected, that the list of observatory sites is long and each site's data could be way over 1MB. Therefore a
/// compact list of site references is maintained separately containing only site UUIDs and last update time. It is
/// recommended that clients cache this list and update the observatory data only in case the cache needs to be
/// invalidated (e.g. lastUpdate is changed).
///
/// **Note for Swift developers:** COURAGEOUS and IMPORTANT ASSUMPTION: Types defined in this file and in
/// `ServiceDiscovery.swift` should not have incompatible coding/decoding and API changes in future versions of the
/// standard! All other types could evolve.
/// This is only a quick reference to check if Client's cache has this site and if the site is up-to-date.
public struct ObservatoryReference: Codable, Identifiable {
    public var attributes: PolisItemAttributes
    public var type: PolisObservatoryType

    public var id: UUID { attributes.id }

    public init(attributes: PolisItemAttributes, type: PolisObservatoryType) {
        self.attributes = attributes
        self.type       = type
    }
}

public struct ObservatoryDirectory: Codable {
    public var lastUpdate: Date                   // UTC
    public var entries: [ObservatoryReference]

    public init(lastUpdate: Date, entries: [ObservatoryReference]) {
        self.lastUpdate = lastUpdate
        self.entries    = entries
    }
}

//MARK: - Making types Codable and CustomStringConvertible -

//MARK: PolisProviderType
extension PolisProviderType: Codable, CustomStringConvertible {
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

//MARK: - PolisDirectoryEntry
extension PolisDirectoryEntry: Codable {
    public enum CodingKeys: String, CodingKey {
        case attributes
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

extension ObservatoryDirectory {
    public enum CodingKeys: String, CodingKey {
        case lastUpdate = "last_updated"
        case entries
    }
}
