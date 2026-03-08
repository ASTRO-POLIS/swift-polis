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
         placeInTheSolarSystem: PolisPlaceInTheSolarSystem) {
        self.gravitationalBodyRelationship = gravitationalBodyRelationship
        self.placeInTheSolarSystem         = placeInTheSolarSystem

        super.init(identity: identity)
    }

    //MARK: PolisObjectPersisting
    override func pathToLocalPolisFile() async -> String {
        let rF = await ObjectStoreCoordinator.shared.fileResourceFinder()

        return rF!.observingFacilityFolder(observingFacilityID: identity.id)
    }

    override func hasChanged() -> Bool { false }
    override func saveToLocalProvider() async throws { }
    override func deleteFromLocalProvider() async throws { }

}

