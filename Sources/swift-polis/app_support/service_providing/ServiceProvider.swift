//
//  ServiceProvider.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.02.26.
//

import Foundation

open class ServiceProvider: PolisObjectPersisting {

    public private(set) var id: UUID!
    public var mirrorID: UUID?
    public var reachabilityStatus = PolisDirectory.ProviderDirectoryEntry.ServiceReachability.localUseOnly
    public var name = "<unnamed>"
    public var shortDescription: String?
    public var lastUpdateTime = Date.now
    public var url: String?
    public var supportedImplementations: [PolisImplementation] = []
    public var providerType = PolisDirectory.ProviderDirectoryEntry.ProviderType.experimental
    //TODO: Implement me!    public var contact: Person

    //MARK: Internal APIs
    init(_ directoryEntry: PolisDirectory.ProviderDirectoryEntry) {
        self._originalPolisRecord = directoryEntry

        updateFromDirectoryEntry(directoryEntry)
    }

    //MARK: Private APIs
    private var _originalPolisRecord: PolisDirectory.ProviderDirectoryEntry?
    private var _currentPolisRecord: PolisDirectory.ProviderDirectoryEntry?

    private func updateFromDirectoryEntry(_ directoryEntry: PolisDirectory.ProviderDirectoryEntry) {
        id                       = directoryEntry.id
        mirrorID                 = directoryEntry.mirrorID
        reachabilityStatus       = directoryEntry.reachabilityStatus
        name                     = directoryEntry.name
        shortDescription         = directoryEntry.shortDescription
        lastUpdateTime           = directoryEntry.lastUpdateTime
        url                      = directoryEntry.url
        supportedImplementations = directoryEntry.supportedImplementations
        providerType             = directoryEntry.providerType

        _currentPolisRecord      = directoryEntry
    }
}

//
//=====================================================================================================================
//

//MARK: : - PolisObjectPersisting implementation - 
public extension ServiceProvider {
    @MainActor static func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.polisProviderDirectoryFile()
    }

    static func loadFromLocalProvider() async throws -> PolisObjectPersisting { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }
    static func loadFromRemoteProvider() async throws -> PolisObjectPersisting { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }

    func hasChanged() -> Bool { false }
    func saveLocally() async throws { }
    func saveRemotely() async throws { }

}
