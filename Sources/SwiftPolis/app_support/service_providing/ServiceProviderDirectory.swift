//
//  ServiceProviderDirectory.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25.02.26.
//

import Foundation


@Observable public final class ServiceProviderDirectory: PersistentObject, @unchecked Sendable {

    public var lastUpdateTime = Date.now
    public var providerDirectoryEntries: [PolisDirectory.ProviderDirectoryEntry] = []

    public func addOrUpdateEntry(_ entry: PolisDirectory.ProviderDirectoryEntry) async throws {
        providerDirectoryEntries.removeAll(where: { $0.id == entry.id })
        providerDirectoryEntries.append(entry)

        try await markAsChanged()
    }

    public override func markAsChanged() async throws { try await setDidChange() }

    //MARK: Internal APIs
    init(_ providerDirectory: PolisDirectory) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: providerDirectory as any PolisObject as any PolisObject,
                                                                 localPath: fileResourceFinder.polisProviderDirectoryFile(),
                                                                 objectType: .serviceProvider)

        self.lastUpdateTime           = providerDirectory.lastUpdateTime
        self.providerDirectoryEntries = providerDirectory.providerDirectoryEntries

        await super.init(polisRep: sP)
    }

    var directory: PolisDirectory {
        PolisDirectory(lastUpdateTime: lastUpdateTime, providerDirectoryEntries: providerDirectoryEntries)!
    }

    //MARK: Implementing PolisObjectPersisting
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.polisProviderDirectoryFile()
    }

    //TODO: Implement me!
    //    func polisObject() -> any PolisObject { fatalError("IdentifiablePersistentObject : polisObject not implemented!") }
    //    func polisType() -> PolisObjectType   { fatalError("IdentifiablePersistentObject : polisType not implemented!") }

    override func setDidChange() async throws {
        lastUpdateTime        = Date.now
        _hasChanged           = true
        _polisRep.polisObject = directory

        try await ObjectStore.shared.serviceProvider()?.setDidChange()
        await ObjectStoreCoordinator.shared.post(PolisNotificationPayload(entity: .serviceDirectory, actionType: .update))
    }

}
