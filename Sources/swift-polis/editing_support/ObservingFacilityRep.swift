//
//  ObservingFacilityRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.10.24.
//

import Foundation

open class ObservingFacilityRep: PersistentItem {

    //MARK: - Public APIs

    /// Error definitions
    public enum ObservingFacilityRepError: Error {
        case foundFacilityWithTypeMismatch
        case unavailableOrUnreadableLocalData
        case cannotWritePolisFile
    }
    
    /// Finds an existing or creates a new `ObservingFacility`
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
            if (existingFacilityDirectoryEntry.gravitationalBodyRelationship == .surfaceFixed) &&
                (existingFacilityDirectoryEntry.placeInTheSolarSystem == .earth) {
                return try EarthFixBasedObservingFacilityRep.registerFacilityWithExisting(identity: identity)
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

    // Facility details UUIDs - one and only one type could be assigned!
    public var fixedSurfaceEarthBaseDetailsID: UUID?
    public var mobileSurfaceEarthBaseDetailsID: UUID?
    public var airborneEarthBaseDetailsID: UUID?

    // Arifacts of interest could be also on other solar system bodies (e.g. Apollo landing site)
    public private(set) var artifacts = [ArtifactRep]()

    //MARK: - PolisPersisting implementation -
    /// This  method saves possible changes only in the facility directory.
    ///
    /// Subclasses should manage  facility details and auxiliary types related to the facility.
    public func saveChanges() throws {
        // 1. Check if I am part of the facility directory, and if not - add myself
        if let directoryEntry = manager.directoryEntryForFacilityWith(id: self.id) {
            let savedIdentity = directoryEntry.identity

            if savedIdentity != identity { manager.facilityDirectory.addOrUpdateObservingFacility(reference: directoryEntry) }
        }
        else {
            let newEntry       = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)
            let facilityFolder = manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: self.identity.id)

            manager.facilityDirectory.addOrUpdateObservingFacility(reference:newEntry)
            manager?.facilities.append(self)

            if !(fm.fileExists(atPath: facilityFolder, isDirectory: &isDir) && (isDir.boolValue)) {
                try fm.createDirectory(atPath: facilityFolder, withIntermediateDirectories: true)
            }
        }

        jsonData = try jsonEncoder.encode(facilityDetails)

        if fm.fileExists(atPath: persistenceReference.localPath) {
            try? fm.removeItem(atPath: persistenceReference.localPath)
        }
        
        if !fm.createFile(atPath: persistenceReference.localPath, contents: jsonData) {
            throw ObservingFacilityRepError.cannotWritePolisFile
        }
        persistenceReference.hasLocalCopy = true

        //TODO: Implement me!
    }

    public func revertToSaved() throws {
        //TODO: Implement me!
    }

    public func delete() throws {
        //TODO: Implement me!
    }

    public func loadWithID(_ id: String) throws -> any PolisPersisting { self }

    public func didChange() -> Bool {
        //TODO: Implement me!
        false
    }

    public func loadAllData() throws {
        let myDataPath = manager.polisFileResourceFinder.observingFacilityFile(observingFacilityID: identity.id)

        jsonData = fm.contents(atPath: myDataPath)
        if let jsonData = jsonData {
            let observingFacility = try JSONDecoder().decode(PolisObservingFacility.self, from: jsonData)
        }
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
    var artifactIDs: Set<UUID>?

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

    func ensureFacilityFolderDoesExist() async throws {
        let path = manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: identity.id)

        if !manager.tryToEnsureFoldersExistence(paths: [path]) {
            PolisLogger.shared.error("Cannot create or access facility folder: \(path)")
            throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder
        }
    }


    //MARK: Private APIs
    // Utility properties

    private static func createObservingFacilityWith(
        identity: PolisIdentity,
        gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
        placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth
    ) throws -> ObservingFacilityRep {
        let manager = PolisProviderManager.currentProviderManager

        if (gravitationalBodyRelationship == .surfaceFixed) && (placeInTheSolarSystem == .earth) {

            let result = EarthFixBasedObservingFacilityRep(id: identity.id, lastUpdateDate: identity.lastUpdateDate, name: identity.name ?? "<unnamed>")
            let ref    = try PolisReference(facilityID: identity.id, polisObjectID: identity.id)

            result.nc.post(name: PolisProviderManager.StatusChangeNotification.facilityReferenceWillCreateNotification, object: nil)

            result.persistenceReference = ref
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
}
