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

    // Parent Facility & Facility concrete type details
    public var facility: ObservingFacility!
    public var earthFixBasedObservingFacility: EarthFixedBaseObservingFacilityDetails?


    //MARK: - Non-private APIs -

    var fixedSurfaceEarthBaseDetailsID: UUID?    //TODO: Load data
    var mobileSurfaceEarthBaseDetailsID: UUID?   //TODO: Load data
    var airborneEarthBaseDetailsID: UUID?        //TODO: Load data

    var artifactIDs: Set<UUID>?                  //TODO: Load data

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

    init(id: UUID = UUID(), lastUpdateTime: Date = Date(), name: String = PolisConstants.unknownObject) throws {
        try super.init(id: id, lastUpdateTime: lastUpdateTime, name: name, facilityID: id)

        finaliseInitialisation()
    }

    init(identity: PolisIdentity, lastUpdateTime: Date = Date()) throws {
        try super.init(id: identity.id, lastUpdateTime: lastUpdateTime, name: identity.name ?? PolisConstants.unknownObject)

        finaliseInitialisation()
    }

    //MARK: Private APIs
    private let logger = SEPolisLogger.logger("ObservingFacility")
    private var _originalFacilityDetails: PolisObservingFacilityDetails!
    private var _allArtifacts = [Artifact]()

    private func finaliseInitialisation() {
        self.representingStoredObjectType = .observingFacilityDetails
        self.localPersistencyStatus       = .inMemoryOnly
        self.remotePersistencyStatus      = .noRemoteRepresentation

        self.localPath                    = PersistentObject.polisFileResourceFinder.observingFacilityFile(observingFacilityID: id)
        self.remoteReadPath               = PersistentObject.polisRemoteResourceFinder.observingFacilityURL(observingFacilityID: id)

        self.polisRegistrationTime       = Date()
        self.lifecycleStatus             = .active
        self.solarSystemBodyName         = placeInTheSolarSystem.rawValue

        _originalFacilityDetails         = self.facilityDetails
    }


}

//MARK: Working with EarthFixedBaseObservingFacilityDetails
public extension ObservingFacilityDetails {

    func addEarthFixedBaseObservingFacilityDetails() async throws -> EarthFixedBaseObservingFacilityDetails {
        guard (earthFixBasedObservingFacility == nil) || (fixedSurfaceEarthBaseDetailsID == nil)  else {
            logger.error("addEarthFixedBaseObservingFacilityDetails - EarthFixedBaseObservingFacilityDetails already exists")
            throw ObjectStore.ObjectStoreError.polisObjectOfTheTypeAlreadyExists
        }

        let result = try await EarthFixedBaseObservingFacilityDetails(facility: facility)

        fixedSurfaceEarthBaseDetailsID = result.id
        earthFixBasedObservingFacility = result

        try await result.saveChanges()

        return result
    }
}
//MARK: Working with artifacts
public extension ObservingFacilityDetails {
    // Arifacts of interest could be also on other solar system bodies (e.g. Apollo landing site)

    func allArtifacts() async throws -> [Artifact] {
        if let artifactIDs = artifactIDs {
            if _allArtifacts.count != artifactIDs.count {
                var newArtifacts: [Artifact] = []

                for artifactID in artifactIDs {
                    if artifactWithID(artifactID) == nil {
                        let pA   = try await PolisArtifact.loadFromLocalFileSystemUsing(store:  ObjectStore.sharedObjectStore, facilityID: item.identity.id, objectID: artifactID)
                        let newA = try Artifact(storedArtifact: pA as! PolisArtifact, facility: facility)
                        newArtifacts.append(newA)
                    }
                }
                for anA in newArtifacts { _allArtifacts.append(anA) }
            }
        }

        return _allArtifacts
    }

    func addArtifact(artifactType: PolisArtifact.ArtifactType, visitingOpportunities: String? = nil, mediaID: UUID? = nil) async throws -> Artifact {
        let artifactIdentity = PolisIdentity(id: UUID())
        let artifact         = try Artifact(identity: artifactIdentity,
                                            facility: facility,
                                            artifactType: artifactType,
                                            visitingOpportunities: visitingOpportunities,
                                            mediaID: mediaID)
        try await artifact.saveChanges()

        _allArtifacts.append(artifact)

        if artifactIDs == nil { artifactIDs = [] }
        artifactIDs!.insert(artifactIdentity.id)
        try await saveChanges()

        return artifact
    }

    func removeArtifact(withID artifactID: UUID) throws {
        //TODO: Implement me!
    }

    private func artifactWithID(_ artifactID: UUID) -> Artifact? {
        for artifact in _allArtifacts {
            if artifact.identity.id == artifactID { return artifact }
        }
        return nil
    }

}


//MARK: - Persisting -
//TODO: Implement me!
extension ObservingFacilityDetails {

    public func canEdit() async -> Bool {
        do    { try await ensureIKnowMyFacility() }
        catch {
            logger.error("canEdit - Could not ensure I know my facility!")
            return false
        }

        return await facility.canEdit()
    }

    public func saveChanges() async throws {
        try await ensureIKnowMyFacility()
        
        // Make sure all non-nil leaf objects are saved. If they are changed, we will know this
        for artifact in try await allArtifacts() {
            try await artifact.saveChanges()
        }
        if earthFixBasedObservingFacility != nil { try await earthFixBasedObservingFacility!.saveChanges() }
        //TODO: Load other types of facilities when they are implemented

        // Now if I am changed, save my data
        if await didChange() || (localPersistencyStatus == .inMemoryOnly) {
            nc.post(name: AppSupportStatusChangeNotification.facilityDetailsWillSaveNotification, object: nil)

            // Let the parent facility that we did change
            facility.lastUpdateTime = Date.now

            // Make sure my directory exist, and if not - create it
            let facilityFolder = await  ObjectStore.sharedObjectStore.fileResourceFinder().observingFacilityFolder(observingFacilityID: id)

            if !(fm.fileExists(atPath: facilityFolder, isDirectory: &isDir) && (isDir.boolValue)) {
                do    { try fm.createDirectory(atPath: facilityFolder, withIntermediateDirectories: true) }
                catch {
                    logger.error("saveChanges - Cannot create a facility directory at: \(facilityFolder)")
                    throw ObservingFacilityError.cannotWritePolisFile
                }
            }

            // Write data to disc
            try await facilityDetails.flashUsing(store:  ObjectStore.sharedObjectStore)

            // Change my object status
            localPersistencyStatus = .savedNotSynced

            //TODO: Save Referenced Items!

            nc.post(name: AppSupportStatusChangeNotification.facilityDetailsDidSaveNotification, object: nil)
        }
    }

    public func revertToSaved() async throws {
        //TODO: Implement me!
    }

    public func delete() async throws {
        //TODO: Implement me!
    }

    public func loadData() async throws {
        nc.post(name: AppSupportStatusChangeNotification.facilityDetailsWillLoadNotification, object: self)

        // If the Facility's folder does not exist. the Facility is newly created and in memory only. So skip the loading
        // without throwing an exception.
        let facilityFolder = await ObjectStore.sharedObjectStore.fileResourceFinder().observingFacilityFolder(observingFacilityID: id)
        if !(fm.fileExists(atPath: facilityFolder, isDirectory: &isDir) && (isDir.boolValue)) { return }

        // Now we assume the Facility folder exist, and it is a bad error if the Details file does not exist
        if !fm.fileExists(atPath: localPath) {
            logger.error("loadData - No local Facility Details found at: \(localPath!)")
            throw ObservingFacilityError.unavailableOrUnreadableLocalData
        }

        self.facilityDetails = try await PolisObservingFacilityDetails.loadFromLocalFileSystemUsing(store: ObjectStore.sharedObjectStore,
                                                                                                    facilityID: item.identity.id,
                                                                                                    objectType: .observingFacilityDetails) as! PolisObservingFacilityDetails

        // Now load more details like Location, Artifacts, Media, etc.
        try await loadReferencedItems()
        localPersistencyStatus = .savedAndSynced

        nc.post(name: AppSupportStatusChangeNotification.facilityDetailsDidLoadNotification, object: self)
        nc.post(name: AppSupportStatusChangeNotification.facilityDidChangeNotification, object: facility)
    }

    public func didChange() async-> Bool { _originalFacilityDetails != self.facilityDetails }

    private func ensureIKnowMyFacility() async throws {
        if self.facility != nil                                                      { return }
        guard let possibleFacility = await ObjectStore.sharedObjectStore.facilityWithId(id) else { throw ObjectStore.ObjectStoreError.objectWithIDNotFound }

        self.facility = possibleFacility
    }

    private func loadReferencedItems() async throws {
        // Load artifacts. The call below has the side-effect to load them.
        _ = try await allArtifacts()

        Task {
            // Load EarthFixedBaseObservingFacilityDetails
            if fixedSurfaceEarthBaseDetailsID != nil {
                let polisObject = try await PolisEarthFixedBaseObservingFacilityDetails.loadFromLocalFileSystemUsing(store: ObjectStore.sharedObjectStore,
                                                                                                                     facilityID: item.identity.id,
                                                                                                                     objectID: fixedSurfaceEarthBaseDetailsID) as! PolisEarthFixedBaseObservingFacilityDetails
                earthFixBasedObservingFacility = try await EarthFixedBaseObservingFacilityDetails(earthFixedBaseObservingFacilityDetails: polisObject)
            }
        }
    }

    private func saveReferencedItems() async throws {
        //TODO: Implement me!
    }

}

