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
    static func fromLocalData(polisType: PolisObjectType, facilityID: UUID?, objectID: UUID?) async throws -> PolisObjectRep<Any>
    func pathToLocalPolisFile() async -> String
    func hasChanged() -> Bool
    func setDidChange() async
    func saveToLocalProvider() async throws
    func deleteFromLocalProvider() async throws
}

public struct IdentifiableObject: Sendable {
    public let id: UUID
    public var externalReferences: [String]?
    public internal(set) var lastUpdateTime: Date
    public var lifecycleStatus: PolisLifecycleStatus
    public var name: PolisLocalisedText?
    public var abbreviation: String?
    public var shortDescription: PolisLocalisedText?
    public var startTime: Date?
    public var endTime: Date?
    public internal(set) var polisRegistrationTime: Date?

    //MARK: Internal APIs

    /// Designated initialiser
     init(id: UUID                                    = UUID(),
                externalReferences: [String]?         = nil,
                lastUpdateTime: Date                  = Date(),
                lifecycleStatus: PolisLifecycleStatus = .unknown,
                name: PolisLocalisedText?             = nil,
                abbreviation: String?                 = nil,
                shortDescription: PolisLocalisedText? = nil,
                startTime: Date?                      = nil,
                endTime: Date?                        = nil,
                polisRegistrationTime: Date?          = nil) { // No default value on purpose, to require explicit setting if needed.
        self.id                    = id
        self.externalReferences    = externalReferences
        self.lastUpdateTime        = lastUpdateTime
        self.lifecycleStatus       = lifecycleStatus
        self.name                  = name
        self.abbreviation          = abbreviation
        self.shortDescription      = shortDescription
        self.startTime             = startTime
        self.endTime               = endTime
        self.polisRegistrationTime = polisRegistrationTime
    }

    init(identity: PolisIdentity)  {
        self.id                    = identity.id
        self.externalReferences    = identity.externalReferences
        self.lastUpdateTime        = identity.lastUpdateTime
        self.lifecycleStatus       = identity.lifecycleStatus
        self.name                  = PolisLocalisedText(identity.name)
        self.abbreviation          = identity.abbreviation
        self.shortDescription      = PolisLocalisedText(identity.shortDescription)
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
                          name                 : name?.rawValues,
                          abbreviation         : abbreviation,
                          shortDescription     : shortDescription?.rawValues,
                          startTime            : startTime,
                          endTime              : endTime,
                          polisRegistrationTime: polisRegistrationTime)
        }
        set {
            externalReferences    = newValue.externalReferences
            lastUpdateTime        = newValue.lastUpdateTime
            lifecycleStatus       = newValue.lifecycleStatus
            name                  = PolisLocalisedText(newValue.name)
            abbreviation          = newValue.abbreviation
            shortDescription      = PolisLocalisedText(newValue.shortDescription)
            startTime             = newValue.startTime
            endTime               = newValue.endTime
            polisRegistrationTime = newValue.polisRegistrationTime
        }
    }
}

//MARK: - Persistent Object Hierarchy Roots -

//@Observable open class PersistentObject: @unchecked Sendable, PolisObjectPersisting {
@Observable open class IdentifiablePersistentObject: PolisTypeTransformable, @unchecked Sendable {

    var identity: IdentifiableObject!

    // These should be used as private properties. Therefore they have "_" prefix!
    var _polisRep: PolisObjectRep<PolisObject>
    var _hasChanged      = false
    let _fm: FileManager = .default
    var _isDir: ObjCBool = false
    let _logger: Logging.Logger

    init(polisRep: PolisObjectRep<PolisObject>, identity: IdentifiableObject? = nil) async {
        self._polisRep = polisRep
        self.identity  = identity

        self._logger = await ObjectStoreCoordinator.shared.logger()
    }

    // These  methods MUST be overridden!
    func polisObject() -> any PolisObject { fatalError("IdentifiablePersistentObject : polisObject not implemented!") }
    func polisType() -> PolisObjectType   { fatalError("IdentifiablePersistentObject : polisType not implemented!") }


    //MARK: - PolisObjectPersisting partial implementation
    static func fromLocalData(polisType: PolisObjectType, facilityID: UUID? = nil, objectID: UUID? = nil) async throws -> PolisObjectRep<Any> {
        var polisObject: PolisObject?
        var localPath: String?
        let osc = await ObjectStoreCoordinator.shared.fileResourceFinder()!

        switch polisType {
            case .serviceProvider:            localPath = osc.configurationFile()
            case .serviceDirectory:           localPath = osc.polisProviderDirectoryFile()
            case .observingFacilityDirectory: localPath = osc.observingFacilitiesDirectoryFile()
            case .observingFacility:          localPath = osc.observingFacilitiesDirectoryFile() // This is the directory, where we need to find the entry
            case .observingFacilityDetail:
                if let fID = facilityID { localPath = osc.observingFacilityFile(observingFacilityID: fID) }
                else                    { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.missingRequiredID }
            case .observingFacilityEarthFixedBasedDetails:
                if let fID = facilityID,  let objectID = objectID { localPath = osc.observingDataFile(withID: objectID, observingFacilityID: fID) }
                else                                              { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.missingRequiredID }
            case .artifact: break         //TODO: Implement me!
            case .observatory: break      //TODO: Implement me!
            case .device: break           //TODO: Implement me!
            case .placeOnEarth:
                if let fID = facilityID,  let objectID = objectID { localPath = osc.observingDataFile(withID: objectID, observingFacilityID: fID) }
                else                                              { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.missingRequiredID }
            case .unknown: break          //TODO: Implement me!
        }

        polisObject = try await loadPolisObjectOf(type: polisType, atPath: localPath, facilityID: facilityID)
        if let polisObject = polisObject {
            return PolisObjectRep(polisObject: polisObject, localPath: localPath!, objectType: polisType)
        }

        throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unknownError
    }

    func pathToLocalPolisFile() async -> String { "<no path defined>" }
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
                _hasChanged = false
            }
            catch {
                _logger.error("Error: create \(objectDescription) out of example string")
                throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.cannotCreatePolisObjectFromStringExample
            }
        }
    }

    func deleteFromLocalProvider() async throws { }

    //MARK: Private APIs
    private static func loadPolisObjectOf(type: PolisObjectType, atPath: String?, facilityID: UUID? = nil, objectID: UUID? = nil) async throws -> PolisObject {
        let fm: FileManager = .default
        var polisObject: PolisObject!

        if let path = atPath {
            let jsonDecoder = PrettyJSONDecoder()

            if !fm.isReadableFile(atPath: path) { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }
            if let data = fm.contents(atPath: path) {
                do {
                    switch type {
                        case .serviceProvider:            polisObject = try jsonDecoder.decode(PolisDirectory.ProviderDirectoryEntry.self, from: data)
                        case .serviceDirectory:           polisObject = try jsonDecoder.decode(PolisDirectory.self, from: data)
                        case .observingFacilityDirectory: polisObject = try jsonDecoder.decode(PolisObservingFacilityDirectory.self, from: data)
                        case .observingFacility:
                            if let fID = facilityID {
                                let facilityDir = try jsonDecoder.decode(PolisObservingFacilityDirectory.self, from: data)
                                polisObject     = facilityDir.facilityReferenceWith(id: fID)
                            }
                            else { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.missingRequiredID }
                        case .observingFacilityDetail:                 polisObject = try jsonDecoder.decode(PolisObservingFacilityDetails.self, from: data)
                        case .observingFacilityEarthFixedBasedDetails: polisObject = try jsonDecoder.decode(PolisEarthFixedBaseObservingFacilityDetails.self, from: data)
                        case .artifact: break          //TODO: Implement me!
                        case .observatory: break       //TODO: Implement me!
                        case .device: break            //TODO: Implement me!
                        case .placeOnEarth: break      //TODO: Implement me!
                        case .unknown: break           //TODO: Implement me!
                    }
                }
                catch { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.cannotAccessOrCreateStandardPolisFolders }

                return polisObject
            }
            else { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.cannotReadFileFromLocalStore }
        }
        else { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.cannotAccessOrCreateStandardPolisFolders }
    }
}
