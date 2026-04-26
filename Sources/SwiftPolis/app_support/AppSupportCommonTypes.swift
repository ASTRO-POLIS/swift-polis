//
//  AppSupportCommonTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 4.02.26.
//

import Foundation

//public struct PolisChangeNotification {
//    // Object Store Notifications
//    /// Sent when  Object Store is ready to be used. It can take some time between  configuring the `ObjectStoreConfigurator` and receiving this
//    /// notification. Special attention is taken to prevent not fully configured object store to be used, but is is strongly recommended nit to try using it before
//    /// this notification is posted.
//    public static let ObjectStoreIsReadyNotification   = Notification.Name("ObjectStoreIsReady")
//
//    /// This notification is posted before the Object Store is fully reset. Such reset could occur if `ObjectStoreConfigurator` is reconfigured.
//    public static let ObjectStoreWillResetNotification = Notification.Name("ObjectStoreWillReset")
//}

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

/// Used to identify the type of the Polis Object to be wrapped for file and sync operations). The String representation
/// us used to customise error messages and reports.
public enum PolisObjectType: String {
    case serviceProvider                         = "POLIS Directory Entry"
    case serviceDirectory                        = "POLIS Directory"
    case observingFacilityDirectory              = "POLIS Observing Facility Directory"

    case observingFacility                       = "POLIS Observing Facility"
    case observingFacilityDetail                 = "POLIS Observing Facility Detail"
    case observingFacilityEarthFixedBasedDetails = "POLIS Observing Facility Earth Fixed Based Details"

    case artifact
    case observatory
    case device

    case placeOnEarth                            = "POLIS Place on Earth"

    case unknown
}


protocol PolisTypeTransformable {
    func polisObject() -> PolisObject
    func polisType() -> PolisObjectType
}
