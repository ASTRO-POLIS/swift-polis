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
    public var lifecycleStatus: PolisLifecycleStatus = .unknown
    public var lastUpdateTime: Date = Date.now

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
        self.lifecycleStatus                     = facility.lifecycleStatus
        self.lastUpdateTime                      = facility.lastUpdateTime
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
                                                                   lifecycleStatus: lifecycleStatus,
                                                                   lastUpdateTime: lastUpdateTime,
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

    override func setDidChange() async {
        lastUpdateTime = Date.now
        _hasChanged = true
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

//MARK: - Working with child types -
extension ObservingFacility {

    /// Returns Observer Facility's Details. If they do not exist yet, a new instance will be create and saved locally
    public func observingFacilityDetails() async throws -> ObservingFacilityDetails {
        //TODO: What if details do exist, but they are available only remotely?

        if _facilityDetailsID == nil {
            //TODO: Create new Details instance and store it.
            let detailsID    = UUID()
            let identity     = PolisIdentity(id: detailsID, name: [PolisConstants.defaultLanguageCode : PolisConstants.unknownObject])
            let polisDetails = PolisObservingFacilityDetails(identity: identity, parentObservingFacilityID: id)
            let details      = await ObservingFacilityDetails(polisDetails)

            _facilityDetailsID = detailsID
            await details.setDidChange()
            try await self.saveToLocalProvider()
            try await details.saveToLocalProvider()
            await setDidChange()

            return details
        }
        else {
            //TODO: Read the locally stored Polis object and create Details instance out of it
            fatalError("Not implemented")
        }
    }
}
