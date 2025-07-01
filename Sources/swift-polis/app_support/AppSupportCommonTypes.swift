//
//  AppSupportCommonTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 08/06/2025.
//

import Foundation

protocol StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore, facilityID: UUID?, objectID: UUID?, objectType: RepresentingStoredObjectType?) async throws -> AnyObject
    static func removeFromLocalFileSystemUsing(store: ObjectStore) async throws

    func parentItem(store: ObjectStore) async throws -> (any StorableItem)?
    func flashUsing(store: ObjectStore) async throws
}

public struct AppSupportStatusChangeNotification {
    // Object Store Notifications
    public static let ObjectStoreWillCreateNotification = Notification.Name("ObjectStoreWillCreate")    // ✅ Object is the ObjectStore
    public static let ObjectStoreDidCreateNotification  = Notification.Name("ObjectStoreDidCreate")     // ✅ Object is the ObjectStore
    public static let ObjectStoreWillLoadNotification   = Notification.Name("ObjectStoreWillLoad")      // ✅ Object is the ObjectStore
    public static let ObjectStoreDidLoadNotification    = Notification.Name("ObjectStoreDidLoad")       // ✅ Object is the ObjectStore
    public static let ObjectStoreWillRemoveNotification = Notification.Name("ObjectStoreWillRemove")    // ✅ Object is the ObjectStore
    public static let ObjectStoreDidRemoveNotification  = Notification.Name("ObjectStoreWillRemove")    // ✅ Object is the ObjectStore
    public static let ObjectStoreWillCloseNotification  = Notification.Name("ObjectStoreWillClose")     // ✅ Object is the ObjectStore
    public static let ObjectStoreDidCloseNotification   = Notification.Name("ObjectStoreDidClose")      // ✅ Object is nil

    // Facility Info
    public static let facilityInfoWillSaveNotification      = Notification.Name("facilityInfoWillSave")  // ✅ Object is nil
    public static let facilityInfoDidSaveNotification       = Notification.Name("facilityInfoDidSave")   // ✅ Object is the ObservingFacilityRep
    public static let facilityInfoWillLoadNotification      = Notification.Name("facilityInfoWillLoad")  // ✅ Object nil
    public static let facilityInfoDidLoadNotification       = Notification.Name("facilityInfoDidLoad")   // ✅ Object is the ObservingFacilityRep

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


/// Defines the type to be used where to store local data the stored data
public enum RepresentingStoredObjectType: Int, CaseIterable {
    case unknown
    case observingFacilityDetails // Cannot be shared, this is the facility Info (Details)
    case place                    // Cannot be shared
    case observatory              // Can be shared
    case device                   // Can be shared
    case artifact                 // Cannot be shared
}

//MARK: - StorableItem useful default implementation -
extension StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore, facilityID: UUID? = nil, objectID: UUID? = nil, objectType: RepresentingStoredObjectType? = nil) async throws -> AnyObject {
        throw ObjectStore.ObjectStoreError.fileIO
    }

    static func removeFromLocalFileSystemUsing(store: ObjectStore) async throws { }

    func parentItem(store: ObjectStore) async throws -> (any StorableItem)? { nil }
    func flashUsing(store: ObjectStore) async throws { }
}
