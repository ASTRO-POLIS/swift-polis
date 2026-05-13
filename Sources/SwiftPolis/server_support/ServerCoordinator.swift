//
//  ServerCoordinator.swift
//  swift-polis
//
//  Created by Georg Tuparev on 28.04.26.
//

import Foundation
import Logging

// Big assumption: the POLIS provider (static local data) already exists, it is empty (only required files are present),
// and all dates are set way in the past (e.g. 01.01.2000 00:00h).q

public final class ServerCoordinator {
    
    // MARK: - Singleton
    @MainActor public static let shared = ServerCoordinator()
    
    // Similar to the ObjectStoreCoordinator we need to set stuff like root path, is it test mode
    public static let testingPath = "/Users/Shared/Work/polis_tests"
    @MainActor public static var isTestMode  = false
    
    public enum ServerCoordinatorError: Error {
        case notConfigured
        case dataNotLoaded
    }
    
    private var logger: Logger?
    private init() {}
}

// MARK: - Setup
extension ServerCoordinator {
    
    
    @MainActor public func configure(testMode: Bool = false) async throws {
        ServerCoordinator.isTestMode = testMode
        PolisLogger.setup(
            subsystem:      "com.polis.provider",
            level:          .info,
            includeConsole: true
        )
        self.logger = PolisLogger.logger("com.polis.ServerCoordinator")
        let coordinator = ObjectStoreCoordinator.shared
        let path        = ServerCoordinator.testingPath
        try await coordinator.setPathToPolisFolder(path)
        let description = try await coordinator.objectStoreStatus()
        guard description.status.rawValue >= ObjectStoreStatusType.fullyConfigured.rawValue else {
            logger?.warning("ServerCoordinator: local store not ready at \(path)")
            return
        }
        try await coordinator.loadLocalStore()
        logger?.info("ServerCoordinator: local store loaded from \(path)")
    }
}

//MARK: - Service Providing -
extension ServerCoordinator {

    public func polisServiceProvider() async throws -> PolisDirectory.ProviderDirectoryEntry {
        guard let entry = ObjectStore.shared.serviceProvider()?.directoryEntry else {
            throw ServerCoordinatorError.dataNotLoaded
        }
        return entry
    }

    public func polisServiceProviderDirectory() async throws -> PolisDirectory {
        guard let directory = ObjectStore.shared.serviceProviderDirectory()?.directory else {
            throw ServerCoordinatorError.dataNotLoaded
        }
        return directory
    }
}

extension ServerCoordinator {
    public func updateServiceProvider(_ entry: PolisDirectory.ProviderDirectoryEntry) async throws {
        guard let serviceProvider = ObjectStore.shared.serviceProvider() else {
            throw ServerCoordinatorError.dataNotLoaded
        }

        var hasChanges = false

        if serviceProvider.name != entry.name {
            serviceProvider.name = entry.name
            hasChanges = true
        }
        if serviceProvider.shortDescription != entry.shortDescription {
            serviceProvider.shortDescription = entry.shortDescription
            hasChanges = true
        }
        if serviceProvider.url != entry.url {
            serviceProvider.url = entry.url
            hasChanges = true
        }
        if serviceProvider.reachabilityStatus != entry.reachabilityStatus {
            serviceProvider.reachabilityStatus = entry.reachabilityStatus
            hasChanges = true
        }
        if serviceProvider.providerType != entry.providerType {
            serviceProvider.providerType = entry.providerType
            hasChanges = true
        }
        if serviceProvider.contactEmail != entry.contactEmail {
            serviceProvider.contactEmail = entry.contactEmail
            hasChanges = true
        }
        if serviceProvider.supportedImplementations != entry.supportedImplementations {
            serviceProvider.supportedImplementations = entry.supportedImplementations
            hasChanges = true
        }

        if hasChanges {
            try await serviceProvider.setDidChange()
        }
    }
}

