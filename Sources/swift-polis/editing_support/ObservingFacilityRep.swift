//
//  ObservingFacilityRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.10.24.
//

import Foundation

open class ObservingFacilityRep: PersistentItem {

    //MARK: Error definitions
    public enum ObservingFacilityRepError: Error {
        case foundFacilityWithTypeMismatch
        case unavailableOrUnreadableLocalData
    }

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
    public var artifactIDs: Set<UUID>?

    //MARK: - PolisPersisting implementation -
    /// This  method saves possible changes only in the facility directory.
    ///
    /// Subclasses should manage  facility details and auxiliary types related to the facility.
    public override func saveChanges() throws {
        // 1. Check if I am part of the facility directory, and if not - add myself
        if let directoryEntry = manager.directoryEntryForFacilityWith(id: self.id) {
            let savedIdentity = directoryEntry.identity

            if savedIdentity != identity { manager.facilityDirectory.addOrUpdateObservingFacility(reference: directoryEntry) }
        }
        else {
            let newEntry = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)

            manager.facilityDirectory.addOrUpdateObservingFacility(reference:newEntry)
        }
    }

    public override func revertToSaved() throws {
        //TODO: Implement me!
    }

    public override func delete() throws {
        //TODO: Implement me!
    }

    public override func didChange() -> Bool {
        //TODO: Implement me!
        false
    }





    /// This is used to update the in memory objects and (possibly) POLIS related files in the local file system.
    ///
    /// To reflect the changes to the local copy of  POLIS files, use ``StorableItem``'s `flashUsing(manager: )` method.
//    public func flush() async throws {
//        let provider = PolisProviderManager.currentProviderManager!
//
//        // Identity
//        let dirEntry = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)
//
//        provider.facilityDirectory.addOrUpdateObservingFacility(reference: dirEntry)
//        try provider.flush(item: provider.facilityDirectory)
//
//        // Details
//        let facilityDetails                                      = PolisObservingFacility(item: item,
//                                                                                          gravitationalBodyRelationship: gravitationalBodyRelationship,
//                                                                                          placeInTheSolarSystem: placeInTheSolarSystem)
//        facilityDetails.observingFacilityCode                    = observingFacilityCode
//        facilityDetails.solarSystemBodyName                      = solarSystemBodyName
//        facilityDetails.orbitingAroundPlaceInTheSolarSystemNamed = orbitingAroundPlaceInTheSolarSystemNamed
//        facilityDetails.facilityLocationID                       = facilityLocationID
//        facilityDetails.astronomicalCode                         = astronomicalCode
//
//        //TODO: This should be rewritten when the PolisFacility implements StorableItem
//        try await ensureFacilityFolderDoesExist()
//
//        let detailsPath = manager.polisFileResourceFinder.observingFacilityFile(observingFacilityID: identity.id)
//
//        do {
//            let data = try manager.jsonEncoder.encode(facilityDetails)
//            //TODO: remove later solution will be found
//            let path = "file://\(detailsPath)"
//            try data.write(to: URL(string: path.normalisedFolderPath())!)
//        }
//        catch {
//            PolisLogger.shared.error("Cannot encode or save facility details to: \(detailsPath)")
//            throw PolisProviderManager.PolisProviderManagerError.cannotWriteFile
//        }
//    }

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
            PolisLogger.shared.error("Cannot create or access facility forlder: \(path)")
            throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder
        }
    }


    //MARK: Private APIs
    private static func createObservingFacilityWith(
        identity: PolisIdentity,
        gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
        placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth
    ) throws -> ObservingFacilityRep {
        if (gravitationalBodyRelationship == .surfaceFixed) && (placeInTheSolarSystem == .earth) {
            var result = EarthFixBasedObservingFacilityRep(id: identity.id, lastUpdateDate: identity.lastUpdateDate, name: identity.name)

            result.localName        = identity.localName
            result.abbreviation     = identity.abbreviation
            result.shortDescription = identity.shortDescription
            result.startDate        = identity.startDate

            //TODO: Implement me!
//            result.manager.facilityDetails.append(result)
        }
      //TODO: Implement me!
      throw ObservingFacilityRepError.foundFacilityWithTypeMismatch
    }
}

