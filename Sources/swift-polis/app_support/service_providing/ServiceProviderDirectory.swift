//
//  ServiceProviderDirectory.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25.02.26.
//

import Foundation


open class ServiceProviderDirectory: PolisObjectPersisting {

    public var lastUpdateTime = Date.now

    public var providerDirectoryEntries: [PolisDirectory.ProviderDirectoryEntry] = []

    init(_ providerDirectory: PolisDirectory) {
        self.lastUpdateTime = providerDirectory.lastUpdateTime
        self.providerDirectoryEntries = providerDirectory.providerDirectoryEntries

        self._originalPolisRecord = providerDirectory
        self._currentPolisRecord  = providerDirectory
    }

    //MARK: Private APIs
    private var _originalPolisRecord: PolisDirectory?
    private var _currentPolisRecord: PolisDirectory?
}

//
//=====================================================================================================================
//

//MARK: : - PolisObjectPersisting implementation -
public extension ServiceProviderDirectory {
    @MainActor static func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.polisProviderDirectoryFile()
    }

    //TODO: Implement me!
    static func loadFromLocalProvider() async throws -> PolisObjectPersisting { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }

    //TODO: Implement me!
    static func loadFromRemoteProvider() async throws -> PolisObjectPersisting { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }

    //TODO: Implement me!
    func hasChanged() -> Bool { false }

    //TODO: Implement me!
    func saveLocally() async throws { }

    //TODO: Implement me!
    func saveRemotely() async throws { }
}
