//
//  PolisObjectRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation

/// Used to identify the type of the Polis Object to be wrapped for file and sync operations)
enum PolisObjectType {
    case facility
    case facilityDetail
}

/// Represents a POLIS Data Structure
struct PolisObjectRep<PolisObject> {
    let polisObject: PolisObject
    let localPath: String
    let objectType: PolisObjectType
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

@Observable open class PersistentObject: @unchecked Sendable {

    var polisRep: PolisObjectRep<PolisObject>

    init(polisRep: PolisObjectRep<PolisObject>) {
        //TODO: Implement me!
        self.polisRep = PolisObjectRep(polisObject: polisRep as! PolisObject, localPath: "bla", objectType: .facility)
    }
}

