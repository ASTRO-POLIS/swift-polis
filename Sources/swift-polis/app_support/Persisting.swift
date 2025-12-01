//
//  Persisting.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11/06/2025.
//

import Foundation
import SoftwareEtudesUtilities

public protocol RemoteSynchronisationProviding {
    func pullChanges() async throws
    func pushChanges() async throws
}

//MARK: - Persisting -
/// `PolisPersisting` is an API that regulate persistency and syncing for all in-memory objects having local file system representation.
public protocol Persisting: Identifiable {
    /// Indicates if the object is in a process of being edited
    var isEditing: Bool { get }

    /// Defines if a `*Rep` instance can be edited
    ///
    /// Wen instances could be edited:
    ///  - If the the shared ``ObjectStore`` is created in a editing mode, and
    ///  - If the locally stored instance is synced with the remote instance (if it exists), and
    ///  - If the locally stored instance (if exists) is equal to the in-memory copy
    func canEdit() async -> Bool

    /// Marks the beginning of an editing session of the object
    func startEditing() async throws

    /// Marks the end of an editing session of the object
    func finishEditing() async throws

    /// Saves all changes to the local file system
    ///
    /// The method should compare the POLIS data stored in the file system (or cached) and perform file system changes only in case both datasets differ from
    /// each other.
    ///
    /// **Notes:**
    ///  - Child instances (e.g. location, device, etc) receive `saveChanges()` after the parent instance (e.g. the facility) saves its changes
    ///  - Subclasses call superclass' `saveChanges()` prior saving its own changes
    func saveChanges() async throws

    /// Replaces the in-memory representation of a Polis item with data from the local file system
    func revertToSaved() async throws

    /// Deletes the item from both - the memory cache and from the local file system
    func delete() async throws

    /// This method forces the corresponding instance  to load  locally stored data
    ///
    /// **Notes:**
    ///  - Child instances receive `loadData()` after the parent instance (if applicable)
    ///  - If the instance has reference to more local data, this should be scheduled to be loaded and notifications should be observed
    ///  - No exception is thrown if local data does not exist
    func loadData() async throws

    /// Returns the result of the comparison between the locally stored POLIS item and the corresponding in-memory representation
    func didChange() async -> Bool

    /// The place to write local changes before the client app closes the `ObjectStore`
    func prepareToCloseTheObjectStore() async throws
}


//MARK: - PersistenObject -
open class PersistentObject: Persisting {
    @MainActor static var synchronisationProvider: RemoteSynchronisationProviding?

    @MainActor static var polisFileResourceFinder: PolisFileResourceFinder!
    @MainActor static var polisRemoteResourceFinder: PolisRemoteResourceFinder!
    static let auxiliaryServiceHosts = [String : String]()
    @MainActor static var remoteWriteAPI: String?


    public var id: UUID
    public var lastUpdateTime: Date
    public var lifecycleStatus: PolisLifecycleStatus

    public internal(set) var isEditing = false

    public func startEditing() async throws {
        if await canEdit() { isEditing = true }
        else               { throw ObjectStore.ObjectStoreError.objectCannotBeEdited }
    }

    public func finishEditing() async throws { isEditing = false }

    //MARK: Non-public APIs
    enum LocalPersistencyStatus {
        case unowned
        case inMemoryOnly
        case savedNotSynced
        case savedAndSynced
    }

    enum RemotePersistencyStatus {
        case unowned
        case noRemoteRepresentation
        case remoteRepresentationNotSynced
        case remoteRepresentationAndSynced
    }

    enum PersistentObjectError: Error {
        case referenceTypeNotImplemented
        case missingFacilityID
    }

    var localPath: String!
    var remoteReadPath: String!
    var remoteWriteAPI: String? // The push (PUT) remote API with body of the corresponding JSON representation

    var representingStoredObjectType = RepresentingStoredObjectType.unknown
    var fileType                     = PolisImplementation.DataFormat.json

    var localPersistencyStatus  = LocalPersistencyStatus.unowned
    var remotePersistencyStatus = RemotePersistencyStatus.unowned

    let nc              = NotificationCenter.default
    let fm              = FileManager.default
    var isDir: ObjCBool = false
    var jsonEncoder     = PrettyJSONEncoder()
    var jsonDecoder     = PrettyJSONDecoder()
    var jsonData: Data!

    init(id: UUID                                                   = UUID(),
         lastUpdateTime: Date                                       = Date.now,
         lifecycleStatus: PolisLifecycleStatus                      = .unknown,
         facilityID: UUID?                                          = nil,
         representingStoredObjectType: RepresentingStoredObjectType = .observingFacilityDetails,
         fileType: PolisImplementation.DataFormat                   = .json) throws {
        var facilityIDString = facilityID?.uuidString
        let polisIdString    = id.uuidString

        self.id              = id
        self.lastUpdateTime  = lastUpdateTime
        self.lifecycleStatus = lifecycleStatus

        switch representingStoredObjectType {
            case .observingFacilityDetails:
                let fileName   = "\(facilityIDString!)/\(polisIdString).\(fileType)"

                facilityIDString = id.uuidString
                localPath        = "\(PersistentObject.polisFileResourceFinder.observingFacilitiesFolder())\(fileName)"
                remoteReadPath   = "\(PersistentObject.polisRemoteResourceFinder.polisProviderDirectoryURL())\(fileName)"
            case .artifact, .place:
                if let facilityID = facilityID {
                    let fileName = "\(polisIdString).\(fileType)"

                    localPath      = "\(PersistentObject.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: facilityID))\(fileName)"
                    remoteReadPath = "\(PersistentObject.polisRemoteResourceFinder.observingFacilityURL(observingFacilityID: facilityID))\(fileName)"
                }
                else { throw PersistentObjectError.missingFacilityID }
            default: throw PersistentObjectError.referenceTypeNotImplemented
        }

        self.representingStoredObjectType = representingStoredObjectType
        self.fileType                     = fileType
    }

    //MARK: Private API
}

//MARK: - IdentifiableObject -
open class IdentifiableObject: PersistentObject {
    // Polis Identity defined
    public var externalReferences: [String]?
    public var name: String
    public var localName: String?
    public var abbreviation: String?
    public var shortDescription: String?
    public var startTime: Date?
    public var endTime: Date?
    public var polisRegistrationTime: Date?

    /// Designated initialiser
    init(id: UUID                                                   = UUID(),
         lastUpdateTime: Date                                       = Date(),
         name: String,
         facilityID: UUID?                                          = nil,
         representingStoredObjectType: RepresentingStoredObjectType = .observingFacilityDetails,
         fileType: PolisImplementation.DataFormat                   = .json) throws {
        self.name = name
        try super.init(id: id,
                             lastUpdateTime: lastUpdateTime,
                             facilityID: facilityID,
                             representingStoredObjectType: representingStoredObjectType,
                             fileType: fileType)
    }

    var identity: PolisIdentity {
        get {
            PolisIdentity(id: id,
                          externalReferences: externalReferences,
                          lastUpdateTime: lastUpdateTime,
                          lifecycleStatus: lifecycleStatus,
                          name: name,
                          localName: localName,
                          abbreviation: abbreviation,
                          shortDescription: shortDescription,
                          startTime: startTime,
                          endTime: endTime,
                          polisRegistrationTime: polisRegistrationTime)
        }
        set {
            id                    = newValue.id
            externalReferences    = newValue.externalReferences
            lastUpdateTime        = newValue.lastUpdateTime
            name                  = newValue.name ?? "<unnamed>"
            lifecycleStatus       = newValue.lifecycleStatus
            localName             = newValue.localName
            abbreviation          = newValue.abbreviation
            shortDescription      = newValue.shortDescription
            startTime             = newValue.startTime
            endTime               = newValue.endTime
            polisRegistrationTime = newValue.polisRegistrationTime
        }
    }
}

//MARK: - ObjectItem -
open class ObjectItem: IdentifiableObject {
    public var owner: PolisOwner?
    public var parentID: UUID?
    public var automationLabel: String?
    public var mediaSourceID: UUID?

    var item: PolisItem {
        get {
            PolisItem(identity: identity,
                      owner: owner,
                      parentID: parentID,
                      automationLabel: automationLabel,
                      mediaSourceID: mediaSourceID)
        }
        set {
            identity        = newValue.identity
            owner           = newValue.owner
            parentID        = newValue.parentID
            automationLabel = newValue.automationLabel
            mediaSourceID   = newValue.mediaSourceID
        }
    }
}

//MARK:  - Some useful default implementations for Persisting protocol -
extension Persisting {
    public func canEdit()                      async -> Bool { false } // Better be on the safe side
    public func startEditing()                 async throws { }
    public func finishEditing()                async throws { }

    public func saveChanges()                  async throws { }
    public func revertToSaved()                async throws { }
    public func delete()                       async throws { }
    public func loadData()                     async throws { }

    public func didChange()                    async -> Bool { false }

    public func prepareToCloseTheObjectStore() async throws { }
}


//MARK: - Default implementation of RemoteSynchronisationProviding -
extension RemoteSynchronisationProviding {
    func pullChanges() async throws { }
    func pushChanges() async throws { }
}
