//
//  ObservingFacility.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation

@Observable public class ObservingFacility: IdentifiablePersistentObject, @unchecked Sendable {

    public var gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed
    public var placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth

    public var id: UUID { identity.id }

    //TODO: Here we need to list additional objects like Details, Artifacts, Locations, SubFacilities, Observatories, and Devices. All of them should be optional


    //MARK: Internal APIs
    var facilityReference: PolisObservingFacilityDirectory.ObservingFacilityReference {
        PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity.identity,
                                                                   gravitationalBodyRelationship: gravitationalBodyRelationship,
                                                                   placeInTheSolarSystem: placeInTheSolarSystem)
    }

    init(identity: IdentifiableObject,
         gravitationalBodyRelationship: PolisObservingFacilityLocationType,
         placeInTheSolarSystem: PolisPlaceInTheSolarSystem,
         isNewFacility: Bool = false) {
        self.gravitationalBodyRelationship = gravitationalBodyRelationship
        self.placeInTheSolarSystem         = placeInTheSolarSystem

        super.init(identity: identity)
        self._hasChanged = isNewFacility
    }

    //MARK: Private APIs


    //MARK: PolisObjectPersisting
    override func pathToLocalPolisFile() async -> String {
        let rF = await ObjectStoreCoordinator.shared.fileResourceFinder()

        return rF!.observingFacilityFolder(observingFacilityID: identity.id)
    }

    override func hasChanged() -> Bool { false }

    /// The basic data for this facility are stored into the facility directory. Therefore no file needs to be saved. But
    /// if `_hasChanges == true` the method should guarantee, that at least the facility folder exists.
    override func saveToLocalProvider() async throws {
        let path = await pathToLocalPolisFile()

        if !(_fm.fileExists(atPath: path, isDirectory: &_isDir) && (_isDir.boolValue)) {
            do    { try _fm.createDirectory(atPath: path, withIntermediateDirectories: true) }
            catch { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.fileIO }
        }
    }

    override func deleteFromLocalProvider() async throws { }

}

