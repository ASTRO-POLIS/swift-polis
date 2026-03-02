//
//  ServiceProvider.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.02.26.
//

import Foundation

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

    //MARK: Internal APIs
    init(_ directoryEntry: PolisDirectory.ProviderDirectoryEntry) {
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(originalPolisObject: directoryEntry as! any PolisObject as any PolisObject,
                                                                 localPath: "",
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

        super.init(polisRep: sP)
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

    @MainActor static func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.configurationFile()
    }

    //TODO: Implement me!
    @MainActor static func loadFromLocalProvider() async throws -> PolisObjectPersisting { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }

    //TODO: Implement me!
    @MainActor static func loadFromRemoteProvider() async throws -> PolisObjectPersisting { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }

    //TODO: Implement me!
    override func hasChanged() -> Bool { false }

    override func saveToLocalProvider() async throws {
        if _hasChanged {
            let payload = PolisNotificationPayload(entity: .serviceProvider, actionType: .update, id: id)
            await MainActor.run {
                NotificationCenter.default.post(PolisObjectDidChange(payload))
            }
        }
    }

    //TODO: Implement me!
    func deleteFromLocalProvider() async throws { }

}

