//
//  PolisPersisting.swift
//  swift-polis
//
//  Created by Georg Tuparev on 28.03.25.
//

import Foundation
import SoftwareEtudesUtilities

public protocol PolisRemoteSynchronisationProviding {
    func pullChanges() throws
    func pushChanges() throws
}

/// `PolisPersisting` is an API that regulate persistency and syncing for all in-memory objects having local file system representation.
public protocol PolisPersisting: Identifiable {

    var manager: PolisProviderManager! { get set }
    var synchronisationProvider: PolisRemoteSynchronisationProviding? { get set }

    /// Defines if a `*Rep` instance can be edited
    ///
    /// Wen instances could be edited:
    ///  - If the the shared ``PolisProviderManager`` is created in a editing mode, and
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
    func saveChanges() throws

    /// Replaces the in-memory representation of a Polis item with data from the local file system
    func revertToSaved() throws

    /// Deletes the item from both - the memory cache and from the local file system
    func delete() throws

    /// This method forces the corresponding `*Rep`instance  to load  locally stored data
    ///
    /// **Notes:**
    ///  - Child instances receive `loadData()` after the parent instance
    ///  - Subclasses call first superclass' `loadData()` prior to their own data loading
    func loadData() throws

    /// Returns the result of the comparison between the locally stored POLIS item and the corresponding in-memory representation
    func didChange() -> Bool

    func setHasChanges(_ hasChanges: Bool)
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

    public func setHasChanges(_ hasChanges: Bool = true) { self.hasChanges = hasChanges }

    //MARK: Non-public API

    // Used by subclasses
    let nc              = NotificationCenter.default
    let fm              = FileManager.default
    var isDir: ObjCBool = false
    var jsonEncoder     = PrettyJSONEncoder()
    var jsonDecoder     = PrettyJSONDecoder()
    var jsonData: Data!

    var hasChanges      = false

    // Persistence support
//    var persistenceReference: PolisReference!

    /// Designated initialiser
    init(id: UUID, lastUpdateDate: Date = Date(), name: String) throws {
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
            name               = newValue.name ?? "<unnamed>"
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
            identity        = newValue.identity
            owner           = newValue.owner
            parentID        = newValue.parentID
            automationLabel = newValue.automationLabel
            lifecycleStatus = newValue.lifecycleStatus
            mediaSourceID   = newValue.mediaSourceID
        }
    }
}

open class PersistentAuxiliaryItem: PolisPersisting {
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

    // Persistence support
    var persistenceReference: PolisReference!

    let nc              = NotificationCenter.default
    let fm              = FileManager.default
    var isDir: ObjCBool = false
    var jsonEncoder     = PrettyJSONEncoder()
    var jsonDecoder     = PrettyJSONDecoder()
    var jsonData: Data!

    var hasChanges      = false
    
    /// Designated initialiser
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
            name               = newValue.name ?? "<unnamed>"
            localName          = newValue.localName
            abbreviation       = newValue.abbreviation
            shortDescription   = newValue.shortDescription
            startDate          = newValue.startDate
            endDate            = newValue.endDate
        }
    }
}

// Some useful defaults
extension PolisPersisting {
    public func canEdit() -> Bool { true }
    public func saveChanges() throws { }
    public func revertToSaved() throws { }
    public func delete() throws { }
    public func loadData() throws { }

    public func didChange() -> Bool { false }
    public func setHasChanges(_ hasChanges: Bool = true) { }
}


extension PolisRemoteSynchronisationProviding {
    func pullChanges() throws { }
    func pushChanges() throws { }
}
