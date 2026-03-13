//
//  ObservingFacility.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation

@Observable public class ObservingFacility: PersistentObject, @unchecked Sendable {

    // Identification
    public var id: UUID
    public var observingFacilityCode: String?

    // Where in the Solar system
    public var placeInTheSolarSystem: PolisPlaceInTheSolarSystem = .earth
    public var gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed
    public var orbitingAroundPlaceInTheSolarSystem: PolisPlaceInTheSolarSystem? = .sun
    public var astronomicalCode: String?                                   // Minor planet codes, etc.
    public var facilityLocationID: UUID?

    //TODO: Here we need to list additional objects like Details, Artifacts, Locations, SubFacilities, Observatories, and Devices. All of them should be optional


    //MARK: Internal APIs
    init(_ facility: PolisObservingFacilityDirectory.ObservingFacilityReference) async {
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: facility as any PolisObject as any PolisObject,
                                                                 localPath: "",    // We do not need a path. Data is stored into the Facility Directory!
                                                                 objectType: .observingFacility)

        self.id                                  = facility.id
        self.observingFacilityCode               = facility.observingFacilityCode
        self.placeInTheSolarSystem               = facility.placeInTheSolarSystem
        self.gravitationalBodyRelationship       = facility.gravitationalBodyRelationship
        self.orbitingAroundPlaceInTheSolarSystem = facility.orbitingAroundPlaceInTheSolarSystem
        self.astronomicalCode                    = facility.astronomicalCode
        self.facilityLocationID                  = facility.facilityLocationID
        self._facilityDetailsID                  = facility.facilityDetailsID
        
        await super.init(polisRep: sP)
    }

    var facilityReference: PolisObservingFacilityDirectory.ObservingFacilityReference {
        PolisObservingFacilityDirectory.ObservingFacilityReference(id: id,
                                                                   observingFacilityCode: observingFacilityCode,
                                                                   placeInTheSolarSystem: placeInTheSolarSystem,
                                                                   gravitationalBodyRelationship: gravitationalBodyRelationship,
                                                                   orbitingAroundPlaceInTheSolarSystem: orbitingAroundPlaceInTheSolarSystem,
                                                                   astronomicalCode: astronomicalCode,
                                                                   facilityLocationID: facilityLocationID,
                                                                   facilityDetailsID: _facilityDetailsID)
    }

    //MARK: PolisObjectPersisting

    /// This is used to determine the Facility's folder
    override func pathToLocalPolisFile() async -> String {
        let rF = await ObjectStoreCoordinator.shared.fileResourceFinder()

        return rF!.observingFacilityFolder(observingFacilityID: id)
    }

    /// The basic data for this facility are stored into the facility directory. Therefore no file needs to be saved. But
    /// if `_hasChanges == true` the method should guarantee, that at least the facility folder exists.
    override func saveToLocalProvider() async throws {
        let path = await pathToLocalPolisFile()

        if !(_fm.fileExists(atPath: path, isDirectory: &_isDir) && (_isDir.boolValue)) {
            do    { try _fm.createDirectory(atPath: path, withIntermediateDirectories: true) }
            catch { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.fileIO }
        }
    }

    //MARK: Private APIs
    // Facility details
    private var _facilityDetailsID: UUID?

}

