//
//  AppSupportCommonTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 4.02.26.
//

import Foundation

public struct PolisChangeNotification {
    // Object Store Notifications
    /// Sent when  Object Store is ready to be used. It can take some time between  configuring the `ObjectStoreConfigurator` and receiving this
    /// notification. Special attention is taken to prevent not fully configured object store to be used, but is is strongly recommended nit to try using it before
    /// this notification is posted.
    public static let ObjectStoreIsReadyNotification   = Notification.Name("ObjectStoreIsReady")

    /// This notification is posted before the Object Store is fully reset. Such reset could occur if `ObjectStoreConfigurator` is reconfigured.
    public static let ObjectStoreWillResetNotification = Notification.Name("ObjectStoreWillReset")

}

public enum ObjectStoreStatusType: Sendable {
    case unknown               // The status when `ObjectStoreCoordinator.shared` is called for the first time
    case notConfigured         // This is the status when the root path is verified, but no data are stored in the local store
    case partiallyConfigured   // Example: all sub-folders exist, but not all essential files are create
    case fullyConfigured       // All essential sub-folders and POLIS critical files do exist
    case configuredAndSynced   // The local store is synced with the remote service provider. The sync might be in progress
    case misconfigured         // Missing sub-folders files, or misformated files
}

