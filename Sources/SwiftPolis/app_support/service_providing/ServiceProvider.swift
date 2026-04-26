//
//  ServiceProvider.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.02.26.
//

import Foundation
import SoftwareEtudesUtilities

@Observable public final class ServiceProvider: IdentifiablePersistentObject, @unchecked Sendable {

    public private(set) var id: UUID!
    public var mirrorID: UUID?
    public var reachabilityStatus                              = PolisDirectory.ProviderDirectoryEntry.ServiceReachability.localUseOnly
    public var name                                            = "<unnamed>"
    public var shortDescription: String?
    public var lastUpdateTime                                  = Date.now
    public var url: String?
    public var supportedImplementations: [PolisImplementation] = []
    public var providerType                                    = PolisDirectory.ProviderDirectoryEntry.ProviderType.experimental
    public var contactEmail: String!

    //MARK: Internal APIs
    init(_ directoryEntry: PolisDirectory.ProviderDirectoryEntry) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: directoryEntry as any PolisObject as any PolisObject,
                                                                 localPath: fileResourceFinder.configurationFile(),
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

    //MARK: Public APIs

    /// Returns `lastUpdateTime` as an ISO 8601 formatted string (UTC).
    public func getLastUpdate() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: lastUpdateTime)
    }

    //MARK: Implementing PolisObjectPersisting
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.configurationFile()
    }

    override func setDidChange() async {
        let payload   = PolisNotificationPayload(entity: .serviceProvider, actionType: .update, id: id)
        let directory = await ObjectStoreCoordinator.shared.serviceProviderDirectory()

        lastUpdateTime        = Date.now
        _hasChanged           = true
        _polisRep.polisObject = directoryEntry!

        if directory != nil {
            directory!.addOrReplace(directoryEntry!)
            await directory!.setDidChange()
        }

        await MainActor.run { NotificationCenter.default.post(PolisObjectDidChange(payload)) }
    }
}

