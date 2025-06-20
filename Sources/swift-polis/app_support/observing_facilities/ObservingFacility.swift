//
//  ObservingFacility.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.10.24.
//

import Foundation

open class ObservingFacility: ObjectItem {

    //MARK: - Public APIs

    public enum FacilityRepType {
        case fixedEarthBased
    }

    /// Error definitions
    public enum ObservingFacilityError: Error {
        case foundFacilityWithTypeMismatch
        case unavailableOrUnreadableLocalData
        case cannotWritePolisFile
        case instanceCannotBeEdited
        case providerManagerNotInitialized
    }
    
    /// Finds an existing or creates a new `ObservingFacility` instance of a corresponding type
    ///
    /// In case of facility type mismatch, an exception will be thrown. The facility that is returned might be not be fully initiated. Call `loadData()` and observe
    /// status change notifications.
    /// - Parameters:
    ///   - identity: a facility identity as it is described as entry of the facility directory
    ///   - gravitationalBodyRelationship: e.g. surface fixed, satellite, rover, etc.
    ///   - placeInTheSolarSystem: e.g.  Earth, Mars, Sun, ...
    /// - Returns: in most (all) cases returns a concrete `ObservingFacilityRep` subclass
    public static func findOrRegisterObservingFacilityWith(
        identity: PolisIdentity,
        gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
        placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth,
        autoload: Bool                                                    = true
    ) throws -> ObservingFacility {

//        if let store = PersistentObject.store {

//            if let existingFacilityDirectoryEntry = store.directoryEntryForFacilityWith(id: identity.id) {
//                // So, this facility is already registered into the Facility Directory
//                if (existingFacilityDirectoryEntry.gravitationalBodyRelationship == .surfaceFixed) &&
//                    (existingFacilityDirectoryEntry.placeInTheSolarSystem == .earth) {
//                    // It seams this is an earth-based fixed facility
//                    let facility = try ObservingFacilityRep(id: identity.id, lastUpdateDate: identity.lastUpdateDate, name: identity.name ?? "<unnamed>")
//
//                    facility.facilityType = .fixedEarthBased
//                    manager.facilities.append(facility)
//
//                    return facility
//                }
//                else { throw ObservingFacilityError.foundFacilityWithTypeMismatch }
//            }
//            else {
//                return try ObservingFacility.createObservingFacilityWith(identity: identity,
//                                                                            gravitationalBodyRelationship: gravitationalBodyRelationship,
//                                                                            placeInTheSolarSystem: placeInTheSolarSystem)
//            }
//        }
//        else { throw ObservingFacilityError.providerManagerNotInitialized }
        //TODO: Implement other facility types when framework provides support for them.

        throw ObservingFacilityError.providerManagerNotInitialized   //FIXME: !!! Remove this, normal return is needed!
    }

    /// Defines the facility type based on the values of `gravitationalBodyRelationship` and `placeInTheSolarSystem`
    public private(set) var facilityType = FacilityRepType.fixedEarthBased

    // Defined by the PolisObservingFacilityDirectory.ObservingFacilityReference
    public var gravitationalBodyRelationship = PolisObservingFacilityLocationType.surfaceFixed
    public var placeInTheSolarSystem         = PolisPlaceInTheSolarSystem.earth

    // Identification
    public var observingFacilityCode: String?

    // Where in the Solar system
    public var solarSystemBodyName: String?
    public var orbitingAroundPlaceInTheSolarSystemNamed: String?
    public var facilityLocationID: UUID?
    public var astronomicalCode: String? // Minor planet codes, etc.

    // Relationship to other facilities
    public var parentObservingFacilityID: UUID?

    // Contains
    public var observatoryIDs: Set<UUID>?
    public var deviceIDs: Set<UUID>?

    // Info
    public var website: URL?
    public var scientificObjectives: String?
    public var history: String?

    // Facility concrete type details
    public var earthFixBasedObservingFacility: EarthFixBasedObservingFacilityDetails?

    //MARK: - PolisPersisting implementation -
    public func canEdit() async -> Bool {
        //TODO: Implement me!
        await store.isEditable()
    }

    public func saveChanges() async throws {
        nc.post(name: AppSupportStatusChangeNotification.facilityInfoWillSaveNotification, object: nil)

        // 1. Update Facility Directory
        var directoryEntry = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity,
                                                                                        gravitationalBodyRelationship: gravitationalBodyRelationship,
                                                                                        placeInTheSolarSystem: placeInTheSolarSystem)
        try await store.addOrUpdateObservingFacility(reference: directoryEntry)

        // 2. Now try to save the Facility Info


        //FIXME: We need a new hasChanges and canEdit!
        // 0. Are we allowed to save and is there anything to change?
//        nc.post(name: StatusChangeNotification.facilityInfoWillSaveNotification, object: nil)
//
//        // 1. Check if I am part of the facility directory, and if not - add myself
//        let directoryEntry = manager.directoryEntryForFacilityWith(id: self.id)
//
//        if directoryEntry == nil {
//            let newEntry       = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)
//            let facilityFolder = manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: self.identity.id)
//
//            manager.facilityDirectory.addOrUpdateObservingFacility(reference:newEntry)
//            manager?.facilities.append(self)
//
//            if !(fm.fileExists(atPath: facilityFolder, isDirectory: &isDir) && (isDir.boolValue)) {
//                try fm.createDirectory(atPath: facilityFolder, withIntermediateDirectories: true)
//            }
//        }
//
////        Task {
//            jsonData = try jsonEncoder.encode(facilityDetails)
//
//            if fm.fileExists(atPath: detailsPersistenceReference.localPath) {
//                try? fm.removeItem(atPath: detailsPersistenceReference.localPath)
//            }
//
//            if !fm.createFile(atPath: detailsPersistenceReference.localPath, contents: jsonData) {
//                throw ObservingFacilityRepError.cannotWritePolisFile
//            }
//
//            detailsPersistenceReference.hasLocalCopy                     = true
//            detailsPersistenceReference.dataStatus.existenceStatusLocal  = .created
//            detailsPersistenceReference.dataStatus.existenceStatusRemote = .unknown
//            detailsPersistenceReference.dataStatus.loadingStatus         = .loadedNotSynced
////        }
        nc.post(name: AppSupportStatusChangeNotification.facilityInfoDidSaveNotification, object: nil)

    }

    public func revertToSaved() async throws {
        //TODO: Implement me!
    }

    public func delete() async throws {
        //TODO: Implement me!
    }

    public func loadData() async throws {
        let myDataPath = await store.fileResourceFinder().observingFacilityFile(observingFacilityID: identity.id)

        if !fm.fileExists(atPath: myDataPath) { throw ObservingFacilityError.unavailableOrUnreadableLocalData }

        Task {
            nc.post(name: AppSupportStatusChangeNotification.facilityInfoWillLoadNotification, object: self)

            jsonData = fm.contents(atPath: myDataPath)
            if let jsonData = jsonData {
                do {
                    let observingFacility = try JSONDecoder().decode(PolisObservingFacility.self, from: jsonData)

                    self.facilityDetails = observingFacility
                } catch {
                    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> !!!!!!!!!!!")
                }
            }
//            detailsPersistenceReference.hasLocalCopy                     = true
//            detailsPersistenceReference.dataStatus.existenceStatusLocal  = .created
//            detailsPersistenceReference.dataStatus.existenceStatusRemote = .unknown
//            detailsPersistenceReference.dataStatus.loadingStatus         = .loadedNotSynced

            nc.post(name: AppSupportStatusChangeNotification.facilityInfoDidLoadNotification, object: self)

            loadReferencedItems()
        }
    }

    public func didChange() async-> Bool {
        false
        //TODO: Implement me!
    }

    //MARK: - Non-private APIs -

    var fixedSurfaceEarthBaseDetailsID: UUID?    //TODO: Load data
    var mobileSurfaceEarthBaseDetailsID: UUID?   //TODO: Load data
    var airborneEarthBaseDetailsID: UUID?        //TODO: Load data

    var artifactIDs: Set<UUID>?                  //TODO: Load data
    private(set) var artifacts: [Artifact]?      //TODO: Load data

//    var detailsPersistenceReference: PolisReference!

    // Utility properties

    var facilityDetails: PolisObservingFacility {
        get {
            PolisObservingFacility(item: self.item,
                                   observingFacilityCode:observingFacilityCode,
                                   solarSystemBodyName: solarSystemBodyName,
                                   orbitingAroundPlaceInTheSolarSystemNamed: orbitingAroundPlaceInTheSolarSystemNamed,
                                   facilityLocationID: facilityLocationID,
                                   astronomicalCode:astronomicalCode,
                                   parentObservingFacilityID: parentObservingFacilityID,
                                   observatoryIDs: observatoryIDs,
                                   deviceIDs: deviceIDs,
                                   website: website,
                                   scientificObjectives: scientificObjectives,
                                   history: history,
                                   fixedSurfaceEarthBaseDetailsID: fixedSurfaceEarthBaseDetailsID,
                                   mobileSurfaceEarthBaseDetailsID: mobileSurfaceEarthBaseDetailsID,
                                   airborneEarthBaseDetailsID: airborneEarthBaseDetailsID,
                                   artifactIDs: artifactIDs)
        }
        set {
            item                                     = newValue.item
            observingFacilityCode                    = newValue.observingFacilityCode
            solarSystemBodyName                      = newValue.solarSystemBodyName
            orbitingAroundPlaceInTheSolarSystemNamed = newValue.orbitingAroundPlaceInTheSolarSystemNamed
            facilityLocationID                       = newValue.facilityLocationID
            astronomicalCode                         = newValue.astronomicalCode
            parentObservingFacilityID                = newValue.parentObservingFacilityID
            observatoryIDs                           = newValue.observatoryIDs
            deviceIDs                                = newValue.deviceIDs
            website                                  = newValue.website
            scientificObjectives                     = newValue.scientificObjectives
            history                                  = newValue.history
            fixedSurfaceEarthBaseDetailsID           = newValue.fixedSurfaceEarthBaseDetailsID
            mobileSurfaceEarthBaseDetailsID          = newValue.mobileSurfaceEarthBaseDetailsID
            airborneEarthBaseDetailsID               = newValue.airborneEarthBaseDetailsID
            artifactIDs                              = newValue.artifactIDs
      }
    }

    init(id: UUID, lastUpdateTime: Date = Date(), name: String) async throws {
        try await super.init(id: id, lastUpdateTime: lastUpdateTime, name: name)

//        detailsPersistenceReference = try PolisReference(facilityID: identity.id, polisObjectID: identity.id)
//        setHasChanges()
    }

    func ensureFacilityFolderDoesExist() async throws {
//        let path = manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: identity.id)
//
//        if !manager.tryToEnsureFoldersExistence(paths: [path]) {
//            PolisLogger.shared.error("Cannot create or access facility folder: \(path)")
//            throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder
//        }
    }


    //MARK: Private APIs

//    private static func createObservingFacilityWith(
//        identity: PolisIdentity,
//        gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
//        placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth
//    ) async throws -> ObservingFacility {
//        if (gravitationalBodyRelationship == .surfaceFixed) && (placeInTheSolarSystem == .earth) {
//            let result = try await ObservingFacility(id: identity.id, lastUpdateTime: identity.lastUpdateTime, name: identity.name ?? "<unnamed>")
//
////            result.nc.post(name: StatusChangeNotification.facilityReferenceWillCreateNotification, object: nil)
////
////            result.localName            = identity.localName
////            result.abbreviation         = identity.abbreviation
////            result.shortDescription     = identity.shortDescription
////            result.startDate            = identity.startDate
////            result.nc.post(name: StatusChangeNotification.facilityReferenceDidCreateNotification, object: result)
////
////            result.nc.post(name: StatusChangeNotification.facilityInfoWillCreateNotification, object: nil)
////            try result.saveChanges()
////            try manager?.facilityDirectory.flashUsing(manager: manager!)
////            result.nc.post(name: StatusChangeNotification.facilityInfoDidCreateNotification, object: result)
//
//            return result
//        }
//      //TODO: Implement me!
//      throw ObservingFacilityError.foundFacilityWithTypeMismatch
//    }

    private func loadReferencedItems() {
        //TODO: Implement me!
    }
}

//MARK: Working with Fixed Surface Earth Base Details
public extension ObservingFacility {
    func addFixedSurfaceEarthBaseDetails() async throws -> EarthFixBasedObservingFacilityDetails {
        let result    = try await EarthFixBasedObservingFacilityDetails(id: UUID(), facilityID: self.id)
//        let reference = try PolisReference(facilityID: self.id, polisObjectID: result.id, hasLocalCopy: false, representingStoredObjectType: PolisRepresentingStoredObjectType.observingFacility)
//
//        result.fixedSurfaceEarthBaseDetailsPersistenceReference = reference

        //TODO: Implement me!


        return result
    }
}

//MARK: Working with artifacts
public extension ObservingFacility {
    // Arifacts of interest could be also on other solar system bodies (e.g. Apollo landing site)

    func allArtifacts() throws -> [Artifact] {
        if artifacts == nil { artifacts = [] }
        if let artifactIDs = artifactIDs {
            if artifacts!.count != artifactIDs.count {
                for artifactID in artifactIDs {
                    //TODO: Implement me! ... load them...
                }
            }
        }

        return artifacts!
    }

    func addArtifact(artifactType: PolisArtifact.ArtifactType, visitingOpportunities: String? = nil, mediaID: UUID? = nil) async throws -> Artifact {
        let artifactIdentity = PolisIdentity(id: UUID())
//        let reference        = try PolisReference(facilityID: self.id, polisObjectID: artifactIdentity.id, representingStoredObjectType: .artifact)
        let artifact         = try await Artifact(identity: artifactIdentity,
                                               artifactType: artifactType,
                                               visitingOpportunities: visitingOpportunities,
                                               mediaID: mediaID,
                                               facility: self)

//        artifact.persistenceReference = reference
//        if artifacts == nil { artifacts = [] }
//        artifacts!.append(artifact)
//        try artifact.saveChanges()
//
//        if artifactIDs == nil { artifactIDs = [] }
//        artifactIDs!.insert(artifactIdentity.id)
//
//        nc.post(name: StatusChangeNotification.facilityDidChangeNotification, object: nil)

        return artifact
    }

    func removeArtifact(withID artifactID: UUID) throws {
        //TODO: Implement me!
    }

    private func artifactWithID(_ artifactID: UUID) throws -> Artifact? {
        for artifact in try self.allArtifacts() {
            if artifact.identity.id == artifactID { return artifact }
        }
        return nil
    }

}
