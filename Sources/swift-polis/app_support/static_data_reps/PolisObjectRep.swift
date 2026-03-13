//
//  PolisObjectRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation
import Logging
import SoftwareEtudesLogging
import SoftwareEtudesUtilities

/// Used to identify the type of the Polis Object to be wrapped for file and sync operations). The String representation
/// us used to customise error messages and reports.
public enum PolisObjectType: String {
    case serviceProvider            = "POLIS Directory Entry"
    case serviceDirectory           = "POLIS Directory"
    case observingFacilityDirectory = "POLIS Observing Facility Directory"
    case observingFacility
    case observingFacilityDetail
    case artifact
    case observatory
    case device
    case locationObEarth

    case unknown
}

/// Represents any POLIS Data Structure
struct PolisObjectRep<PolisObject> {
    var polisObject: PolisObject
    let localPath: String
    let objectType: PolisObjectType

    init(polisObject: PolisObject, localPath: String, objectType: PolisObjectType) {
        self.polisObject = polisObject
        self.localPath   = localPath
        self.objectType  = objectType
    }

    mutating func updateCurrentPolisObject(_ newObject: PolisObject) { polisObject = newObject }
}

protocol PolisObjectPersisting {
    func pathToLocalPolisFile() async -> String
    func hasChanged() -> Bool
    func setDidChange() async
    func saveToLocalProvider() async throws
    func deleteFromLocalProvider() async throws
}

public struct IdentifiableObject: Sendable {
    // Polis Identity defined
    public var id: UUID
    public var externalReferences: [String]?
    public var lastUpdateTime: Date
    public var lifecycleStatus: PolisLifecycleStatus
    
    public var name: String
    public var localName: String?
    public var abbreviation: String?
    public var shortDescription: String?
    public var startTime: Date?
    public var endTime: Date?
    public var polisRegistrationTime: Date?

    /// Designated initialiser
    public init(id: UUID                              = UUID(),
                lastUpdateTime: Date                  = Date(),
                lifecycleStatus: PolisLifecycleStatus = .unknown,
                name: String,
                externalReferences: [String]?         = nil,
                localName: String?                    = nil,
                abbreviation: String?                 = nil,
                shortDescription: String?             = nil,
                startTime: Date?                      = nil,
                endTime: Date?                        = nil,
                polisRegistrationTime: Date?          = nil) {
        self.id                    = id
        self.lastUpdateTime        = lastUpdateTime
        self.lifecycleStatus       = lifecycleStatus
        self.name                  = name
        self.externalReferences    = externalReferences
        self.localName             = localName
        self.abbreviation          = abbreviation
        self.shortDescription      = shortDescription
        self.startTime             = startTime
        self.endTime               = endTime
        self.polisRegistrationTime = polisRegistrationTime
    }

    public init(identity: PolisIdentity)  {
        self.id                    = identity.id
        self.lastUpdateTime        = identity.lastUpdateTime
        self.lifecycleStatus       = identity.lifecycleStatus
        self.name                  = identity.name ?? "<unnamed>"
        self.externalReferences    = identity.externalReferences
        self.localName             = identity.localName
        self.abbreviation          = identity.abbreviation
        self.shortDescription      = identity.shortDescription
        self.startTime             = identity.startTime
        self.endTime               = identity.endTime
        self.polisRegistrationTime = identity.polisRegistrationTime
    }

    var identity: PolisIdentity {
        get {
            PolisIdentity(id                   : id,
                          externalReferences   : externalReferences,
                          lastUpdateTime       : lastUpdateTime,
                          lifecycleStatus      : lifecycleStatus,
                          name                 : name,
                          localName            : localName,
                          abbreviation         : abbreviation,
                          shortDescription     : shortDescription,
                          startTime            : startTime,
                          endTime              : endTime,
                          polisRegistrationTime: polisRegistrationTime)
        }
        set {
            externalReferences                = newValue.externalReferences
            name                              = newValue.name ?? "<unnamed>"
            localName                         = newValue.localName
            abbreviation                      = newValue.abbreviation
            shortDescription                  = newValue.shortDescription
            startTime                         = newValue.startTime
            endTime                           = newValue.endTime
            polisRegistrationTime             = newValue.polisRegistrationTime
        }
    }

}

//MARK: - ObjectItem -
public struct ObjectItem: Sendable {
    public var identifiableObject: IdentifiableObject
    public var owner             : PolisOwner?
    public var parentID          : UUID?
    public var automationLabel   : String?
    public var mediaSourceID     : UUID?

    public init(identifiableObject: IdentifiableObject,
                owner             : PolisOwner? = nil,
                parentID          : UUID?       = nil,
                automationLabel   : String?     = nil,
                mediaSourceID     : UUID?       = nil) {
        self.identifiableObject = identifiableObject
        self.owner              = owner
        self.parentID           = parentID
        self.automationLabel    = automationLabel
        self.mediaSourceID      = mediaSourceID
    }

    var item: PolisItem {
        get {
            PolisItem(identity       : identifiableObject.identity,
                      owner          : owner,
                      parentID       : parentID,
                      automationLabel: automationLabel,
                      mediaSourceID  : mediaSourceID)
        }
        set {
            identifiableObject.identity = newValue.identity
            owner                       = newValue.owner
            parentID                    = newValue.parentID
            automationLabel             = newValue.automationLabel
            mediaSourceID               = newValue.mediaSourceID
        }
    }
}

//MARK: - Persistent Object Hierarchy Roots -

@Observable open class PersistentObject: @unchecked Sendable, PolisObjectPersisting {

    // These should be used as private properties. Therefore they have "_" prefix!
    var _polisRep: PolisObjectRep<PolisObject>
    var _hasChanged      = false
    let _fm: FileManager = .default
    var _isDir: ObjCBool = false
    let _logger: Logging.Logger

    init(polisRep: PolisObjectRep<PolisObject>) async {
        self._polisRep = polisRep
        self._logger = await ObjectStoreCoordinator.shared.logger()
    }

    //MARK: - PolisObjectPersisting partial implementation
    func pathToLocalPolisFile() async -> String { "" }
    func hasChanged() -> Bool { _hasChanged }
    func setDidChange() async { _hasChanged = true }

    func saveToLocalProvider() async throws {
        if _hasChanged {
            let objectDescription = _polisRep.objectType.rawValue

            do {
                let data = try PrettyJSONEncoder().encode(_polisRep.polisObject)

                if !_fm.createFile(atPath: _polisRep.localPath, contents: data)  {
                    _logger.error("Error: cannot save \(objectDescription) file to: \(_polisRep.localPath)")
                    throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.cannotWriteFileToLocalStore
                }
            }
            catch {
                _logger.error("Error: create \(objectDescription) out of example string")
                throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.cannotCreatePolisObjectFromStringExample
            }
        }
    }

    func deleteFromLocalProvider() async throws { }
}

@Observable open class IdentifiablePersistentObject: PersistentObject, @unchecked Sendable {

    var identity: IdentifiableObject

    init(identity: IdentifiableObject) async {
        self.identity = identity
        // Provide a placeholder PolisObjectRep since this subclass doesn't yet manage a concrete PolisObject.
        let placeholderRep = PolisObjectRep<PolisObject>(polisObject: DummyPolisType(), localPath: "", objectType: .unknown)
        await super.init(polisRep: placeholderRep)
    }
}

struct DummyPolisType: PolisObject {
    var polisDataType = PolisDataType.unknown
}
