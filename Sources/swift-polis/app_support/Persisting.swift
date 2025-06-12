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

    /// Defines if a `*Rep` instance can be edited
    ///
    /// Wen instances could be edited:
    ///  - If the the shared ``ObjectStore`` is created in a editing mode, and
    ///  - If the locally stored instance is synced with the remote instance (if it exists), and
    ///  - If the locally stored instance (if exists) is equal to the in-memory copy
    func canEdit() -> Bool

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

    /// This method forces the corresponding `*Rep`instance  to load  locally stored data
    ///
    /// **Notes:**
    ///  - Child instances receive `loadData()` after the parent instance
    ///  - If the instance has reference to more local data, this should be scheduled to be loaded and notifications should be observed
    func loadData() async throws

    /// Returns the result of the comparison between the locally stored POLIS item and the corresponding in-memory representation
    func didChange() -> Bool

    /// The place to write local changes before the client app closes the `ObjectStore`
    func prepareToCloseTheObjectStore() async throws
}

// Some useful default implementations
extension Persisting {
    public func canEdit()                      -> Bool { false } // Better be on the safe side
    public func saveChanges()                  async throws { }
    public func revertToSaved()                async throws { }
    public func delete()                       async throws { }
    public func loadData()                     async throws { }

    public func didChange()                    -> Bool { false }

    public func prepareToCloseTheObjectStore() async throws { }
}


//MARK: - Persistent Object -
open class PersistentObject: Persisting {
    static var store: ObjectStore?
    static var synchronisationProvider: RemoteSynchronisationProviding?

    static var polisFileResourceFinder: PolisFileResourceFinder!
    static var polisRemoteResourceFinder: PolisRemoteResourceFinder!
    static var auxiliaryServiceHosts = [String : String]()
    static var remoteWriteAPI: String?


    public var id: UUID
    public var lastUpdateTime: Date

    
    public static func createPersistentObject() -> PersistentObject {
        //TODO: Implement me!
        return PersistentObject()
    }

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

    var localPath: String!
    var remoteReadPath: String!
    var remoteWriteAPI: String? // The push (PUT) remote API with body of the corresponding JSON representation

    var localPersistencyStatus  = LocalPersistencyStatus.unowned
    var remotePersistencyStatus = RemotePersistencyStatus.unowned

    let nc              = NotificationCenter.default
    let fm              = FileManager.default
    var isDir: ObjCBool = false
    var jsonEncoder     = PrettyJSONEncoder()
    var jsonDecoder     = PrettyJSONDecoder()
    var jsonData: Data!

    init(id: UUID = UUID(), lastUpdateTime: Date = Date.now) {
        self.id             = id
        self.lastUpdateTime = lastUpdateTime
    }
}

open class IdentifiableObject: PersistentObject {
    // Polis Identity defined
    public var externalReferences: [String]?
    public var name: String
    public var localName: String?
    public var abbreviation: String?
    public var shortDescription: String?
    public var startDate: Date?
    public var endDate: Date?
    public var polisRegistrationDate: Date?

    /// Designated initialiser
    init(id: UUID, lastUpdateDate: Date = Date(), name: String) throws {
        self.name = name
        super.init(id: id, lastUpdateTime: lastUpdateDate)
    }

}
