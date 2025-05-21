//
//  ObservingFacilityRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.10.24.
//

import Foundation

open class ObservingFacilityRep: PersistentItem {

    //MARK: - Public APIs

    public enum FacilityRepType {
        case fixedEarthBased
    }

    /// Error definitions
    public enum ObservingFacilityRepError: Error {
        case foundFacilityWithTypeMismatch
        case unavailableOrUnreadableLocalData
        case cannotWritePolisFile
        case instanceCannotBeEdited
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
        placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth
    ) throws -> ObservingFacilityRep {
        if let existingFacilityDirectoryEntry = PolisProviderManager.currentProviderManager?.directoryEntryForFacilityWith(id: identity.id) {
            // So, this facility is already registered into the Facility Directory
            if (existingFacilityDirectoryEntry.gravitationalBodyRelationship == .surfaceFixed) &&
                (existingFacilityDirectoryEntry.placeInTheSolarSystem == .earth) {
                // It seams this is an earth-based fixed facility
                let facility = try ObservingFacilityRep(id: identity.id, lastUpdateDate: identity.lastUpdateDate, name: identity.name ?? "<unnamed>")


            }
        }
        else {
            return try ObservingFacilityRep.createObservingFacilityWith(identity: identity,
                                                                        gravitationalBodyRelationship: gravitationalBodyRelationship,
                                                                        placeInTheSolarSystem: placeInTheSolarSystem)
        }
        //TODO: Implement other facility types when framework provides support for them.
        throw ObservingFacilityRepError.foundFacilityWithTypeMismatch
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
    public var earthFixBasedObservingFacilityRep: EarthFixBasedObservingFacilityRep?

    // Arifacts of interest could be also on other solar system bodies (e.g. Apollo landing site)
    public private(set) var artifacts = [ArtifactRep]()

    //MARK: - PolisPersisting implementation -
    public func canEdit() -> Bool {
        //TODO: Implement me!
        manager.isEditable()
    }

    public func saveChanges() throws {
        // 0. Are we allowed to save?
        if !canEdit() { throw ObservingFacilityRepError.instanceCannotBeEdited }
        
        // 1. Check if I am part of the facility directory, and if not - add myself
        let directoryEntry = manager.directoryEntryForFacilityWith(id: self.id)

        if directoryEntry == nil {
            let newEntry       = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)
            let facilityFolder = manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: self.identity.id)

            manager.facilityDirectory.addOrUpdateObservingFacility(reference:newEntry)
            manager?.facilities.append(self)

            if !(fm.fileExists(atPath: facilityFolder, isDirectory: &isDir) && (isDir.boolValue)) {
                try fm.createDirectory(atPath: facilityFolder, withIntermediateDirectories: true)
            }
        }

        jsonData = try jsonEncoder.encode(facilityDetails)

        if fm.fileExists(atPath: detailsPersistenceReference.localPath) {
            try? fm.removeItem(atPath: detailsPersistenceReference.localPath)
        }
        
        if !fm.createFile(atPath: detailsPersistenceReference.localPath, contents: jsonData) {
            throw ObservingFacilityRepError.cannotWritePolisFile
        }
        detailsPersistenceReference.hasLocalCopy = true

        //TODO: Implement me!
    }

    public func revertToSaved() throws {
        //TODO: Implement me!
    }

    public func delete() throws {
        //TODO: Implement me!
    }

    public func loadData() throws {
        let myDataPath = manager.polisFileResourceFinder.observingFacilityFile(observingFacilityID: identity.id)

        jsonData = fm.contents(atPath: myDataPath)
        if let jsonData = jsonData {
            let observingFacility = try JSONDecoder().decode(PolisObservingFacility.self, from: jsonData)
        }
        //TODO: Implement me!
    }

    public func didChange() -> Bool {
        false
        //TODO: Implement me!
    }

    //MARK: Working with artifacts
    public func addArtifact(artifactType: PolisArtifact.ArtifactType, visitingOpportunities: String? = nil, media: MediaSourceRep? = nil) throws {
        let artifactIdentity = PolisIdentity(id: UUID())
        let reference        = try PolisReference(facilityID: self.id, polisObjectID: artifactIdentity.id, representingStoredObjectType: .artifact)
        let artifact         = ArtifactRep(identity: artifactIdentity,
                                           artifactType: artifactType,
                                           visitingOpportunities: visitingOpportunities,
                                           media: media,
                                           facility: self)

        artifact.persistenceReference = reference
        artifacts.append(artifact)
        try artifact.saveChanges()

        if artifactIDs == nil { artifactIDs = [] }
        artifactIDs!.insert(artifactIdentity.id)

        nc.post(name: PolisProviderManager.StatusChangeNotification.facilityDidChangeNotification, object: nil)
    }

    public func removeArtifact(withID artifactID: UUID) throws {
        //TODO: Implement me!
    }


    //MARK: - Non-private APIs -

    var fixedSurfaceEarthBaseDetailsID: UUID?
    var mobileSurfaceEarthBaseDetailsID: UUID?
    var airborneEarthBaseDetailsID: UUID?
    var artifactIDs: Set<UUID>?

    var detailsPersistenceReference: PolisReference!

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

    override init(id: UUID, lastUpdateDate: Date = Date(), name: String) throws {
        try super.init(id: id, lastUpdateDate: lastUpdateDate, name: name)

        detailsPersistenceReference = try PolisReference(facilityID: identity.id, polisObjectID: identity.id)
    }

    func ensureFacilityFolderDoesExist() async throws {
        let path = manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: identity.id)

        if !manager.tryToEnsureFoldersExistence(paths: [path]) {
            PolisLogger.shared.error("Cannot create or access facility folder: \(path)")
            throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder
        }
    }


    //MARK: Private APIs

    private static func createObservingFacilityWith(
        identity: PolisIdentity,
        gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
        placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth
    ) throws -> ObservingFacilityRep {
        let manager = PolisProviderManager.currentProviderManager

        if (gravitationalBodyRelationship == .surfaceFixed) && (placeInTheSolarSystem == .earth) {
            let result = try ObservingFacilityRep(id: identity.id, lastUpdateDate: identity.lastUpdateDate, name: identity.name ?? "<unnamed>")

            result.nc.post(name: PolisProviderManager.StatusChangeNotification.facilityReferenceWillCreateNotification, object: nil)

            result.localName            = identity.localName
            result.abbreviation         = identity.abbreviation
            result.shortDescription     = identity.shortDescription
            result.startDate            = identity.startDate

            try result.saveChanges()
            try manager?.facilityDirectory.flashUsing(manager: manager!)
            result.nc.post(name: PolisProviderManager.StatusChangeNotification.facilityReferenceDidCreateNotification, object: nil)

            return result
        }
      //TODO: Implement me!
      throw ObservingFacilityRepError.foundFacilityWithTypeMismatch
    }

    private static func registerObservingFacilityWith(identity: PolisIdentity,
        gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
        placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth
    ) throws -> ObservingFacilityRep {
        let manager = PolisProviderManager.currentProviderManager

        if (gravitationalBodyRelationship == .surfaceFixed) && (placeInTheSolarSystem == .earth) {

            let result = try ObservingFacilityRep(id: identity.id, lastUpdateDate: identity.lastUpdateDate, name: identity.name ?? "<unnamed>")

            result.detailsPersistenceReference = try PolisReference(facilityID: identity.id, polisObjectID: identity.id)

            result.nc.post(name: PolisProviderManager.StatusChangeNotification.facilityReferenceWillCreateNotification, object: nil)

            result.localName        = identity.localName
            result.abbreviation     = identity.abbreviation
            result.shortDescription = identity.shortDescription
            result.startDate        = identity.startDate

            try result.saveChanges()
            try manager?.facilityDirectory.flashUsing(manager: manager!)
            result.nc.post(name: PolisProviderManager.StatusChangeNotification.facilityReferenceDidCreateNotification, object: nil)

            return result
        }
        //TODO: Implement me!
        throw ObservingFacilityRepError.foundFacilityWithTypeMismatch
    }

}
