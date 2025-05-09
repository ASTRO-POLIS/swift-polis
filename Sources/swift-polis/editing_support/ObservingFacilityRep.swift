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
    }

    public static func findOrRegisterObservingFacilityWith(
        identity: PolisIdentity,
        gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
        placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth
    ) throws -> ObservingFacilityRep {
        throw ObservingFacilityRepError.foundFacilityWithTypeMismatch
    }

    // Polis Observing Facility Details defined
    public var gravitationalBodyRelationship = PolisObservingFacilityLocationType.surfaceFixed
    public var placeInTheSolarSystem         = PolisPlaceInTheSolarSystem.earth
    public var observingFacilityCode: String?
    public var solarSystemBodyName: String?
    public var orbitingAroundPlaceInTheSolarSystemNamed: String?

    // Points to dictionary with some predefined (standard) keys
    public var facilityLocationID: UUID?

    // Minor planet codes, etc.
    public var astronomicalCode: String?

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

    //TODO: Move to the Polis type!
    func ensureFacilityFolderDoesExist() async throws {
        let path = manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: identity.id)

        if !manager.tryToEnsureFoldersExistence(paths: [path]) {
            PolisLogger.shared.error("Cannot create or access facility forlder: \(path)")
            throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder
        }
    }


    override init(id: UUID, lastUpdateDate: Date = Date(), name: String) {
        super.init(id: id, lastUpdateDate: lastUpdateDate, name: name)
    }

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
}

