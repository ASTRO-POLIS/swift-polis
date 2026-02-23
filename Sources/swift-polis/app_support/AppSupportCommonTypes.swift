//
//  AppSupportCommonTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 4.02.26.
//

import Foundation

public protocol PolisObjectPersisting {
    @MainActor static func pathToLocalPolisFile() async -> String
    static func loadFromLocalProvider() async throws -> PolisObjectPersisting
    static func loadFromRemoteProvider() async throws -> PolisObjectPersisting

    func hasChanged() -> Bool
    func saveLocally() async throws
    func saveRemotely() async throws
}

public struct PolisChangeNotification {
    // Object Store Notifications
    /// Sent when  Object Store is ready to be used. It can take some time between  configuring the `ObjectStoreConfigurator` and receiving this
    /// notification. Special attention is taken to prevent not fully configured object store to be used, but is is strongly recommended nit to try using it before
    /// this notification is posted.
    public static let ObjectStoreIsReadyNotification   = Notification.Name("ObjectStoreIsReady")

    /// This notification is posted before the Object Store is fully reset. Such reset could occur if `ObjectStoreConfigurator` is reconfigured.
    public static let ObjectStoreWillResetNotification = Notification.Name("ObjectStoreWillReset")
}

public enum ObjectStoreStatusType: Int, Sendable {
    /// The status when `ObjectStoreCoordinator.shared` is called for the first time
    case notConfigured                        = 0

    /// This is the status when the root path is verified, but no data are stored in the local store
    case rootPathSetAndValid                  = 1

    /// Example: all sub-folders exist, but not all essential files are create
    case folderHierarchyCreated               = 2

    /// Misformated files or missing files
    case misconfiguredOrMissingEssentialFiles = 3

    /// All essential sub-folders and POLIS critical files do exist
    case fullyConfigured                      = 4

    /// The local store is synced with the remote service provider. The sync might be in progress
    case fullyConfiguredAndSynced             = 5
}

//MARK: - Extensions -

// Default implementation, so that the protocol could be adopted step by step
public extension PolisObjectPersisting {
    @MainActor static func pathToLocalPolisFile() async -> String { "" }
    static func loadFromLocalProvider() async throws -> PolisObjectPersisting { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }
    static func loadFromRemoteProvider() async throws -> PolisObjectPersisting { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }

    func hasChanged() -> Bool { false }
    func saveLocally() async throws { }
    func saveRemotely() async throws { }
}
