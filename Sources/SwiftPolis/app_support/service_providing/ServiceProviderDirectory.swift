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

    func addOrReplace(_ entry: PolisDirectory.ProviderDirectoryEntry) {
        let index = providerDirectoryEntries.firstIndex(of: entry)

        if index != nil { providerDirectoryEntries.remove(at: index!) }
        providerDirectoryEntries.append(entry)
    }
    
    //MARK: Implementing PolisObjectPersisting
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.polisProviderDirectoryFile()
    }

    override func setDidChange() async {
        let payload = PolisNotificationPayload(entity: .serviceDirectory, actionType: .update)

        lastUpdateTime        = Date.now
        _hasChanged           = true
        _polisRep.polisObject = directory

        await MainActor.run { NotificationCenter.default.post(PolisObjectDidChange(payload)) }
    }

}
