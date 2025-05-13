//
//  PolisPersisting.swift
//  swift-polis
//
//  Created by Georg Tuparev on 28.03.25.
//

import Foundation

public protocol PolisRemoteSynchronisationProviding {
    func pullChanges() throws
    func pushChanges() throws
}

/// `PolisPersisting` is an API that regulate persistency and syncing for all in-memory objects having local file system representation.
public protocol PolisPersisting {

    var manager: PolisProviderManager! { get set }
    var synchronisationProvider: PolisRemoteSynchronisationProviding? { get set }
    
    /// Saves all changes to the local file system
    ///
    /// The method should compare the POLIS data stored in the file system (or cached) and perform file system changes only in case both datasets differ from
    /// each other.
    /// 
    /// **Note:** if there are in-memory changes this method could change multiple files (and always at least two files).
    func saveChanges() throws

    /// Replaces the in-memory representation of a Polis item with data from the local file system
    func revertToSaved() throws

    /// Deletes the item from both - the memory cache and from the local file system
    func delete() throws

    /// Loading data from all related POLIS files
    func loadWithID(_ id: String) throws -> PolisPersisting

    /// Returns the result of the comparison between the stored POLIS item and the corresponding in-memory representation
    func didChange() -> Bool

    /// This method forces the corresponding `Rep` to load either local or remote detail data, linked to the main type (e.g. Facility)
    ///
    /// **Note:** This method is not async on purpose. If all data is stored locally, the data will be loaded immediately, but in case remote syncing is required,
    /// there will be some delay. Therefore types using `Rep` types should observe status change notifications.
    func loadAllData() throws


}

/// `PersistentItem` is an abstract tat should be always subclassed by all in-memory objects
open class PersistentItem: PolisPersisting {

    // PolisPersisting
    public var manager: PolisProviderManager!
    public var synchronisationProvider: PolisRemoteSynchronisationProviding?

    // Polis Identity defined
    public var id: UUID
    public var externalReferences: [String]?
    public var lastUpdateDate: Date
    public var name: String
    public var localName: String?
    public var abbreviation: String?
    public var shortDescription: String?
    public var startDate: Date?
    public var endDate: Date?
    public var polisRegistrationDate: Date?

    // Polis Item defined
    public var owner: PolisOwner?
    public var parentID: UUID?
    public var automationLabel: String?
    public var lifecycleStatus: PolisLifecycleStatus = PolisLifecycleStatus.unknown
    public var mediaSourceID: UUID?

    //MARK: Non-public API
    var  persistanceReferenceL: PersistentItem!

    init(id: UUID, lastUpdateDate: Date = Date(), name: String) {
        self.id             = id
        self.lastUpdateDate = lastUpdateDate
        self.name           = name
        manager             = PolisProviderManager.currentProviderManager!
    }

    var identity: PolisIdentity {
        get {
            PolisIdentity(id: id,
                          externalReferences: externalReferences,
                          lastUpdateDate: lastUpdateDate,
                          name: name,
                          localName: localName,
                          abbreviation: abbreviation,
                          shortDescription: shortDescription,
                          startDate: startDate,
                          endDate: endDate,
                          polisRegistrationDate: polisRegistrationDate)
        }
        set {
            id                 = newValue.id
            externalReferences = newValue.externalReferences
            lastUpdateDate     = newValue.lastUpdateDate
            name               = newValue.name
            localName          = newValue.localName
            abbreviation       = newValue.abbreviation
            shortDescription   = newValue.shortDescription
            startDate          = newValue.startDate
            endDate            = newValue.endDate
        }
    }

    var item: PolisItem {
        get {
            PolisItem(identity: identity,
                      owner: owner,
                      parentID: parentID,
                      automationLabel: automationLabel,
                      lifecycleStatus: lifecycleStatus,
                      mediaSourceID: mediaSourceID)
        }
        set {
            identity         = newValue.identity
            owner            = newValue.owner
            parentID         = newValue.parentID
            automationLabel  = newValue.automationLabel
            lifecycleStatus  = newValue.lifecycleStatus
            mediaSourceID    = newValue.mediaSourceID
        }
    }
}

open class PersistentAuxiliaryItem: PolisPersisting {
    // PolisPersisting
    public var manager: PolisProviderManager!
    public var synchronisationProvider: PolisRemoteSynchronisationProviding?

    // Identification and containing folder
    public var id: UUID
    public var localFolder: String

    init(id: UUID, localFolder: String) {
        self.id          = id
        self.localFolder = localFolder
        self.manager     = PolisProviderManager.currentProviderManager!
    }
}

// Some useful defaults
extension PolisPersisting {
    public func saveChanges() throws { }
    public func revertToSaved() throws { }
    public func delete() throws { }
    public func loadWithID(_ id: String) throws -> PolisPersisting { self }

    public func didChange() -> Bool { false }

    public func loadAllData() throws { }
}


extension PolisRemoteSynchronisationProviding {
    func pullChanges() throws { }
    func pushChanges() throws { }
}
