//
//  ObservingFacility.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation

@Observable public class ObservingFacility: IdentifiablePersistentObject, @unchecked Sendable {

    public enum ObservingFacilityTypeSpecificDetailType {
        case main
        case fixedBaseEarthObservingFacility
        case unowned
    }

    // Identification
    public var observingFacilityCode: String?

    // Where in the Solar system
    public internal(set) var placeInTheSolarSystem: PolisPlaceInTheSolarSystem? = .earth
    public internal(set) var orbitingAroundPlaceInTheSolarSystem: PolisPlaceInTheSolarSystem?
    public internal(set) var gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed
    public var startingPointOfFacilityInTransition: PolisPlaceInTheSolarSystem?
    public var destinationPointOfFacilityInTransition: PolisPlaceInTheSolarSystem?

    public var astronomicalCode: String?                                   // Minor planet codes, etc.
    public var observingFacilityTypeSpecificDetailType = ObservingFacilityTypeSpecificDetailType.main

    //MARK: Convenience methods
    public func solarSystemBodyName() -> String                        { placeInTheSolarSystem?.rawValue ?? "N/A" }
    public func orbitingAroundPlaceInTheSolarSystemName() -> String    { orbitingAroundPlaceInTheSolarSystem?.rawValue ?? "N/A" }
    public func startingPointOfFacilityInTransitionName() -> String    { startingPointOfFacilityInTransition?.rawValue ?? "N/A" }
    public func destinationPointOfFacilityInTransitionName() -> String { destinationPointOfFacilityInTransition?.rawValue ?? "N/A" }

    /// Guarantees that the facility will be saved locally and optionally also remotely
    public override func markAsChanged() async throws {
        let facilityDirectory = ObjectStore.shared.observingFacilityDirectory()

        await facilityDirectory?.addOrUpdateFacility(self)
        //FIXME: I think we do not need this!
        //        await ObjectStoreCoordinator.shared.didChange(object: self, ofType: .observingFacility)
        try await setDidChange()
    }

    //MARK: Internal APIs
    init(_ facility: PolisObservingFacilityDirectory.ObservingFacilityReference) async {
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: facility as any PolisObject as any PolisObject,
                                                                 localPath: "",    // We do not need a path. Data is stored into the Facility Directory!
                                                                 objectType: .observingFacility)

        self.observingFacilityCode                  = facility.observingFacilityCode

        self.placeInTheSolarSystem                  = facility.placeInTheSolarSystem
        self.orbitingAroundPlaceInTheSolarSystem    = facility.orbitingAroundPlaceInTheSolarSystem
        self.gravitationalBodyRelationship          = facility.gravitationalBodyRelationship
        self.startingPointOfFacilityInTransition    = facility.startingPointOfFacilityInTransition
        self.destinationPointOfFacilityInTransition = facility.destinationPointOfFacilityInTransition

        self.astronomicalCode                       = facility.astronomicalCode

        self.facilityDetailsID                      = facility.facilityDetailsID
        self.facilityLocationDetailsID              = facility.facilityLocationDetailsID

        await super.init(polisRep: sP, identity: IdentifiableObject(identity: facility.identity))

//        //TODO: When we implement more types, this needs to be enhanced.
//        if (facility.placeInTheSolarSystem == .earth) && (facility.gravitationalBodyRelationship == .surfaceFixed) {
//            self.observingFacilityTypeSpecificDetailType = .fixedBaseEarthObservingFacility
//
//            let earthFacility = await FixedBaseObservingFacilityDetails(facility: self)
//
//            self.facilityDetailsID  = earthFacility.id
//            self.facilityLocationDetailsID = earthFacility.placeOnEarth().id //FIXME: This seams to be wrong?
//
//            await earthFacility.setDidChange()
//        }
 }
    var facilityDetailsID: UUID?
    var facilityLocationDetailsID: UUID?

    var facilityReference: PolisObservingFacilityDirectory.ObservingFacilityReference {
        PolisObservingFacilityDirectory.ObservingFacilityReference(identity: _identity.identity,
                                                                   observingFacilityCode: observingFacilityCode,
                                                                   placeInTheSolarSystem: placeInTheSolarSystem,
                                                                   orbitingAroundPlaceInTheSolarSystem: orbitingAroundPlaceInTheSolarSystem,
                                                                   gravitationalBodyRelationship: gravitationalBodyRelationship,
                                                                   startingPointOfFacilityInTransition: startingPointOfFacilityInTransition,
                                                                   destinationPointOfFacilityInTransition: destinationPointOfFacilityInTransition,
                                                                   astronomicalCode: astronomicalCode,
                                                                   facilityDetailsID: facilityDetailsID,
                                                                   facilityLocationDetailsID: facilityLocationDetailsID)
    }

    //MARK: PolisObjectPersisting

    /// This is used to determine the Facility's folder
    override func pathToLocalPolisFile() async -> String {
        let rF = await ObjectStoreCoordinator.shared.fileResourceFinder()

        return rF!.observingFacilityFolder(observingFacilityID: _identity.id)
    }

    override func setDidChange() async throws {
        _identity.lastUpdateTime = Date.now
        _hasChanged              = true

        await ObjectStoreCoordinator.shared.post(PolisNotificationPayload(entity: .observingFacility, actionType: .update, id: _identity.id))
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

}

//MARK: - Working with child types -
extension ObservingFacility {
    
    /// Reads an existing ``ObservingFacilityDetails`` or generates one if there is no locally stored data.
    ///
    /// Current implementation does not check if there is an existing remote details file.
    /// - Returns: ``ObservingFacilityDetails`` instance or `nil` if cannot be read or generated.
    public func observingFacilityDetails() async throws -> ObservingFacilityDetails? {
        do {
            let polisObjectRep = try await Self.fromLocalData(polisType: .observingFacilityDetail, facilityID: _identity.id, objectID: facilityDetailsID)

            // Safely unwrap the expected PolisObservingFacilityDetails from the loaded polisObject
            guard let polisDetails = polisObjectRep.polisObject as? PolisObservingFacilityDetails else {
                throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.cannotReadFileFromLocalStore
            }

            // If details do not exist yet, this will throw an exception, and in the catch part we will create the details
            let details = await ObservingFacilityDetails(polisDetails)
            return details
        }
        catch {
            // We assume, that the file does not exist, so we need to create it
            let polisDetails = PolisObservingFacilityDetails(id: UUID(), facilityID: self.id)
            let details      = await ObservingFacilityDetails(polisDetails)

            self.facilityDetailsID = details.id
            try? await details.markAsChanged()
            try await self.saveToLocalProvider() // Make sure the folder exists
            try await details.saveToLocalProvider()
            try await markAsChanged()

            return details
        }
    }
}
