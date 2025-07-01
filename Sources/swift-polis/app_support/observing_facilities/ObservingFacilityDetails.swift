//
//  ObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.10.24.
//

import Foundation

open class ObservingFacilityDetails: ObjectItem {

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
        case encodingError
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
    public var earthFixBasedObservingFacility: EarthFixedBaseObservingFacilityDetails?

    //MARK: - PolisPersisting implementation -
    public func canEdit() async -> Bool {
        //TODO: Implement me!
        await store.isEditable()
    }

    public func saveChanges() async throws {
        nc.post(name: AppSupportStatusChangeNotification.facilityInfoWillSaveNotification, object: nil)

        // 1. Update Facility Directory
        try await store.addOrUpdateObservingFacilityDirectoryEntry(self)

        // 2. Now try to save the Facility Info
        let facilityFolder = await store.fileResourceFinder().observingFacilityFolder(observingFacilityID: id)

        if !(fm.fileExists(atPath: facilityFolder, isDirectory: &isDir) && (isDir.boolValue)) {
            do    { try fm.createDirectory(atPath: facilityFolder, withIntermediateDirectories: true) }
            catch {
                PolisLogger.shared.error("ObservingFacility:saveChanges - Cannot cannot create a facility directory at: \(facilityFolder)")
                throw ObservingFacilityError.cannotWritePolisFile
            }
        }
        try await facilityDetails.flashUsing(store: store)

        localPersistencyStatus = .savedNotSynced
        nc.post(name: AppSupportStatusChangeNotification.facilityInfoDidSaveNotification, object: nil)

        //TODO: Start saving children data!
    }

    public func revertToSaved() async throws {
        //TODO: Implement me!
    }

    public func delete() async throws {
        //TODO: Implement me!
    }

    public func loadData() async throws {
        nc.post(name: AppSupportStatusChangeNotification.facilityInfoWillLoadNotification, object: self)

        // If the Facility's folder does not exist. the Facility is newly created and in memory only. So skip the loading
        // without throwing an exception.
        let facilityFolder = await store.fileResourceFinder().observingFacilityFolder(observingFacilityID: id)
        if !(fm.fileExists(atPath: facilityFolder, isDirectory: &isDir) && (isDir.boolValue)) { return }

        // Now we assume the Facility folder exist, and it is a bad error if the Details file does not exist
        if !fm.fileExists(atPath: localPath) {
            PolisLogger.shared.error("ObservingFacility:loadData - No local Facility Details found at: \(localPath!)")
            throw ObservingFacilityError.unavailableOrUnreadableLocalData
        }

        self.facilityDetails = try await PolisObservingFacilityDetails.loadFromLocalFileSystemUsing(store: store,
                                                                                                    facilityID: item.identity.id,
                                                                                                    objectType: .observingFacilityDetails) as! PolisObservingFacilityDetails

        // Now load more details like Location, Artifacts, Media, etc.
        try await loadReferencedItems()
        localPersistencyStatus = .savedAndSynced
        
        nc.post(name: AppSupportStatusChangeNotification.facilityInfoDidLoadNotification, object: self)
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

//    var detailsPersistenceReference: PolisReference!

    // Utility properties

    var facilityDetails: PolisObservingFacilityDetails {
        get {
            PolisObservingFacilityDetails(item: self.item,
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

    init(id: UUID = UUID(), lastUpdateTime: Date = Date(), name: String) async throws {
        try await super.init(id: id, lastUpdateTime: lastUpdateTime, name: name)

        try await finaliseInitialisation()
    }

    init(identity: PolisIdentity, lastUpdateTime: Date = Date()) async throws {
        try await super.init(id: identity.id, lastUpdateTime: lastUpdateTime, name: identity.name ?? "<unknown>")

        try await finaliseInitialisation()
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
    private var _allArtifacts: [Artifact]?

    private func finaliseInitialisation() async throws {
        self.representingStoredObjectType = .observingFacilityDetails
        self.localPersistencyStatus       = .inMemoryOnly
        self.remotePersistencyStatus      = .noRemoteRepresentation

        self.localPath                    = await ObjectStore.currentObjectStore().fileResourceFinder().observingFacilityFile(observingFacilityID: id)
        self.remoteReadPath               = try await ObjectStore.currentObjectStore().remoteResourceFinder().observingFacilityURL(observingFacilityID: id)

        self.polisRegistrationDate       = Date()
        self.lifecycleStatus             = .active
        self.solarSystemBodyName         = placeInTheSolarSystem.rawValue
    }

    private func loadReferencedItems() async throws {
        //TODO: Implement me!
    }

    private func saveReferencedItems() async throws {
        //TODO: Implement me!
    }
}

//MARK: Working with Fixed Surface Earth Base Details
public extension ObservingFacilityDetails {
    func addFixedSurfaceEarthBaseDetails() async throws -> EarthFixedBaseObservingFacilityDetails {
        let result    = try await EarthFixedBaseObservingFacilityDetails(facilityID: self.id)
//        let reference = try PolisReference(facilityID: self.id, polisObjectID: result.id, hasLocalCopy: false, representingStoredObjectType: PolisRepresentingStoredObjectType.observingFacility)
//
//        result.fixedSurfaceEarthBaseDetailsPersistenceReference = reference

        //TODO: Implement me!


        return result
    }
}

//MARK: Working with artifacts
public extension ObservingFacilityDetails {
    // Arifacts of interest could be also on other solar system bodies (e.g. Apollo landing site)

    func allArtifacts() throws -> [Artifact] {
//        if _allArtifacts == nil { artifacts = [] }
//        if let artifactIDs = artifactIDs {
//            if artifacts!.count != artifactIDs.count {
//                for artifactID in artifactIDs {
//                    //TODO: Implement me! ... load them...
//                }
//            }
//        }
//
//        return artifacts!
        return []
    }

    func addArtifact(artifactType: PolisArtifact.ArtifactType, visitingOpportunities: String? = nil, mediaID: UUID? = nil) async throws -> Artifact {
        let artifactIdentity = PolisIdentity(id: UUID())
//        let reference        = try PolisReference(facilityID: self.id, polisObjectID: artifactIdentity.id, representingStoredObjectType: .artifact)
        let artifact         = try await Artifact(identity: artifactIdentity,
                                                  facilityID: self.id,
                                                  artifactType: artifactType,
                                                  visitingOpportunities: visitingOpportunities,
                                                  mediaID: mediaID)

//        artifact.persistenceReference = reference
//        if artifacts == nil { artifacts = [] }
//        artifacts!.append(artifact)
//        try artifact.saveChanges()
//
//        if artifactIDs == nil { artifactIDs = [] }
//        artifactIDs!.insert(artifactIdentity.id)

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
