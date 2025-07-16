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

    // Facility
    public static let facilityWillSaveNotification   = Notification.Name("facilityWillSave")    // ✅ Object is the Facility
    public static let facilityDidSaveNotification    = Notification.Name("facilityDidSave")     // ✅ Object is the Facility
    public static let facilityWillLoadNotification   = Notification.Name("facilityWillLoad")    // ✅ Object is the Facility
    public static let facilityDidLoadNotification    = Notification.Name("facilityDidLoad")     // ✅ Object is the Facility
    public static let facilityWillChangeNotification = Notification.Name("facilityWillChange")  // Object is the Facility
    public static let facilityDidChangeNotification  = Notification.Name("facilityDidChange")   // Object is the Facility

    // Facility Details
    public static let facilityDetailsWillSaveNotification = Notification.Name("facilityDetailsWillSave")  // ✅ Object is the Facility Details
    public static let facilityDetailsDidSaveNotification  = Notification.Name("facilityDetailsDidSave")   // ✅ Object is the Facility Details
    public static let facilityDetailsWillLoadNotification = Notification.Name("facilityDetailsWillLoad")  // Object is the Facility Details
    public static let facilityDetailsDidLoadNotification  = Notification.Name("facilityDetailsDidLoad")   // Object is the Facility Details

    // Earth Based Facility Details
    public static let earthBasedFacilityWillSaveNotification = Notification.Name("earthBasedFacilityWillSave") // ✅ Object is the Facility
    public static let earthBasedFacilityDidSaveNotification  = Notification.Name("earthBasedFacilityDidSave")  // ✅ Object is the Facility
    public static let earthBasedFacilityWillLoadNotification = Notification.Name("earthBasedFacilityWillLoad") // ✅ Object is the Facility
    public static let earthBasedFacilityDidLoadNotification  = Notification.Name("earthBasedFacilityDidLoad")  // ✅ Object is the Facility

    // Artifacts
    public static let artifactWillSaveNotification = Notification.Name("artifactWillSave")   // ✅ Object is the ArtifactRep
    public static let artifactDidSaveNotification  = Notification.Name("artifactDidSave")    // ✅ Object is the ArtifactRep
    public static let artifactWillLoadNotification = Notification.Name("artifactWillLoad")   // ✅ Object is the ArtifactRep
    public static let artifactDidLoadNotification  = Notification.Name("artifactDidLoad")    // ✅ Object is the ArtifactRep
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
