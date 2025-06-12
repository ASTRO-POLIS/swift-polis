//
//  AppSupportCommonTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 08/06/2025.
//

import Foundation

protocol StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore) async throws -> AnyObject
    static func removeFromLocalFileSystemUsing(store: ObjectStore) async throws

    func parentItem(store: ObjectStore) async -> (any StorableItem)?
    mutating func flashUsing(store: ObjectStore) async throws
}

public struct AppSupportStatusChangeNotification {
    // Object Store Notifications
    public static let ObjectStoreWillCreateNotification = Notification.Name("ObjectStoreWillCreate")    // ✅ Object is the ObjectStore
    public static let ObjectStoreDidCreateNotification  = Notification.Name("ObjectStoreDidCreate")     // ✅ Object is the ObjectStore
    public static let ObjectStoreWillRemoveNotification = Notification.Name("ObjectStoreWillRemove")    // ✅ Object is the ObjectStore
    public static let ObjectStoreDidRemoveNotification  = Notification.Name("ObjectStoreWillRemove")    // ✅ Object is the ObjectStore
}

//public struct StatusChangeNotification {
//    // Provider related
//    public static let providerWillCreateNotification        = Notification.Name("providerWillCreate")        // ✅ Object is the Manager
//    public static let providerDidCreateNotification         = Notification.Name("providerWDidCreate")        // ✅ Object is the Manager
//
//    public static let providerWillLoadLocalDataNotification = Notification.Name("providerWillLoadLocalData") // ✅ Object is the Manager
//    public static let providerDidLoadLocalDataNotification  = Notification.Name("providerDidLoadLocalData")  // ✅ Object is the Manager
//
//    // Facility reference related
//    public static let facilityReferenceWillCreateNotification = Notification.Name("facilityReferenceWillCreate") // ✅ Object is nil
//    public static let facilityReferenceDidCreateNotification  = Notification.Name("facilityReferenceDidCreate")  // ✅Object is the ObservingFacilityReference
//
//    // Facility detail (info) reference related
//    public static let facilityInfoWillCreateNotification    = Notification.Name("facilityInfoWillCreate")    // ✅ Object is nil
//    public static let facilityInfoDidCreateNotification     = Notification.Name("facilityInfoDidCreate")     // ✅ Object is the ObservingFacilityRep
//    public static let facilityInfoWillSaveNotification      = Notification.Name("facilityInfoWillSave")      // ✅ Object is nil
//    public static let facilityInfoDidSaveNotification       = Notification.Name("facilityInfoDidSave")       // ✅ Object is the ObservingFacilityRep
//    public static let facilityInfoWillLoadNotification      = Notification.Name("facilityInfoWillLoad")      // ✅ Object nil
//    public static let facilityInfoDidLoadNotification       = Notification.Name("facilityInfoDidLoad")       // ✅ Object is the ObservingFacilityRep
//
//    //TODO: These are Erth Based notifications
//    public static let facilityDetailWillLoadNotification    = Notification.Name("facilityDetailWillLoad")    // Object ObservingFacilityRep
//    public static let facilityDetailDidLoadNotification     = Notification.Name("facilityDetailDidLoad")     // Object is the ObservingFacilityRep
//    public static let facilityDetailsWillCreateNotification = Notification.Name("facilityDetailsWillCreate") // Object is nil
//    public static let facilityDetailsDidCreateNotification  = Notification.Name("facilityDetailsDidCreate")  // Object is the ObservingFacilityRep
//
//    public static let facilityDidChangeNotification         = Notification.Name("facilityInfoDidChange")     // Object is the ObservingFacilityRep
//
//    // Artifacts
//    public static let artifactWillCreateNotification       = Notification.Name("artifactWillCreate")         // ✅ Object is nil
//    public static let artifactDidCreateNotification        = Notification.Name("artifactDidCreate")          // ✅ Object is the ArtifactRep
//    public static let artifactWillChangeNotification       = Notification.Name("artifactWillChange")         // Object is the ArtifactRep
//    public static let artifactDidChangeNotification        = Notification.Name("artifactDidChange")          // Object is the ArtifactRep
//
//}
