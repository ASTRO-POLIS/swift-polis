//
//  ServiceProvider.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.02.26.
//

import Foundation
import SoftwareEtudesUtilities

@Observable public final class ServiceProvider: PersistentObject, @unchecked Sendable {

    public private(set) var id: UUID!
    public var mirrorID: UUID?
    public var reachabilityStatus = PolisDirectory.ProviderDirectoryEntry.ServiceReachability.localUseOnly
    public var name = "<unnamed>"
    public var shortDescription: String?
    public var lastUpdateTime = Date.now
    public var url: String?
    public var supportedImplementations: [PolisImplementation] = []
    public var providerType = PolisDirectory.ProviderDirectoryEntry.ProviderType.experimental
    public var contactEmail: String!

    private static func initialLocalPolisFilePath() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.configurationFile()
    }

    //MARK: Internal APIs
    init(_ directoryEntry: PolisDirectory.ProviderDirectoryEntry) async {
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(originalPolisObject: directoryEntry as any PolisObject as any PolisObject,
                                                                 localPath: await ServiceProvider.initialLocalPolisFilePath(),
                                                                 objectType: .serviceProvider)
        id                       = directoryEntry.id
        mirrorID                 = directoryEntry.mirrorID
        reachabilityStatus       = directoryEntry.reachabilityStatus
        name                     = directoryEntry.name
        shortDescription         = directoryEntry.shortDescription
        lastUpdateTime           = directoryEntry.lastUpdateTime
        url                      = directoryEntry.url
        supportedImplementations = directoryEntry.supportedImplementations
        providerType             = directoryEntry.providerType
        contactEmail             = directoryEntry.contactEmail

        await super.init(polisRep: sP)
    }

    var directoryEntry : PolisDirectory.ProviderDirectoryEntry? {
        try? PolisDirectory.ProviderDirectoryEntry(id: id,
                                                   mirrorID: mirrorID,
                                                   reachabilityStatus: reachabilityStatus,
                                                   name: name,
                                                   shortDescription: shortDescription,
                                                   lastUpdateTime: lastUpdateTime,
                                                   url: url,
                                                   supportedImplementations: supportedImplementations,
                                                   providerType: providerType,
                                                   contactEmail: contactEmail)
    }

    //TODO: Implement me!
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.configurationFile()
    }

    //TODO: Implement me!
    override func hasChanged() -> Bool { _hasChanged }

    override func setDidChange() async {
        _hasChanged = true
        let payload = PolisNotificationPayload(entity: .serviceProvider, actionType: .update, id: id)
        await MainActor.run {
            NotificationCenter.default.post(PolisObjectDidChange(payload))
        }
    }

    override func saveToLocalProvider() async throws {
        if _hasChanged {
            do {
                let data = try PrettyJSONEncoder().encode(_polisRep.originalPolisObject)

                if !_fm.createFile(atPath: _polisRep.localPath, contents: data)  {
                    _logger.error("Cannot save POLIS Directory Entry file to: \(_polisRep.localPath)")
                    throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.cannotWriteFileToLocalStore
                }
            }
            catch {
                _logger.error("Error: create POLIS object out of example string")
                throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.cannotCreatePolisObjectFromStringExample
            }
        }
    }

    //TODO: Implement me!
    override func deleteFromLocalProvider() async throws { }

}

