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
    public var earthFixBasedObservingFacility: EarthFixBasedObservingFacilityDetails?

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

        do { jsonData = try jsonEncoder.encode(facilityDetails) }
        catch {
            PolisLogger.shared.error("ObservingFacility:saveChanges - Cannot encode facility")
            throw ObservingFacilityError.encodingError
        }

        do {
            if fm.fileExists(atPath: localPath) { try fm.removeItem(atPath: localPath) }
            if !fm.createFile(atPath: localPath, contents: jsonData) {
                PolisLogger.shared.error("ObservingFacility:saveChanges - Cannot create a facility info file: \(localPath!)")
                throw ObservingFacilityError.cannotWritePolisFile
            }

        }
        catch {
            PolisLogger.shared.error("ObservingFacility:saveChanges - Cannot cannot create a facility info file: \(localPath!)")
            throw ObservingFacilityError.cannotWritePolisFile
        }

        localPersistencyStatus = .savedNotSynced
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

    init(id: UUID = UUID(), lastUpdateTime: Date = Date(), name: String) async throws {
        try await super.init(id: id, lastUpdateTime: lastUpdateTime, name: name)

        await finaliseInitialisation()
    }

    init(identity: PolisIdentity, lastUpdateTime: Date = Date()) async throws {
        try await super.init(id: identity.id, lastUpdateTime: lastUpdateTime, name: identity.name ?? "<unknown>")

        await finaliseInitialisation()
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
    private func finaliseInitialisation() async {
        self.representingStoredObjectType = .observingFacility
        self.localPersistencyStatus       = .inMemoryOnly
        self.remotePersistencyStatus      = .noRemoteRepresentation

        self.localPath                    = await ObjectStore.currentObjectStore().fileResourceFinder().observingFacilityFile(observingFacilityID: id)
        self.remoteReadPath               = await ObjectStore.currentObjectStore().remoteResourceFinder().observingFacilityURL(observingFacilityID: id)

        self.polisRegistrationDate       = Date()
        self.lifecycleStatus             = .active
        self.solarSystemBodyName         = placeInTheSolarSystem.rawValue
    }

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
