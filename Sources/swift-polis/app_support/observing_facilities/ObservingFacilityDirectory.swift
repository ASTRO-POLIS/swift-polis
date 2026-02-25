//
//  ObservingFacilityDirectory.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25.02.26.
//

import Foundation

open class ObservingFacilityDirectory: PolisObjectPersisting {
    public var lastUpdate: Date // UTC
    public var observingFacilities: [ObservingFacility] = []

    init(_ facilityDirectory: PolisObservingFacilityDirectory) {
        self.lastUpdate = facilityDirectory.lastUpdate
        for facility in facilityDirectory.observingFacilityReferences {
            let facility = ObservingFacility(facilityIdentity: IdentifiableObject(identity: facility.identity),
                                             gravitationalBodyRelationship: facility.gravitationalBodyRelationship,
                                             placeInTheSolarSystem: facility.placeInTheSolarSystem)
            observingFacilities.append(facility)
        }
    }
}

    //
    //=====================================================================================================================
    //

//MARK: : - PolisObjectPersisting implementation -
public extension ObservingFacilityDirectory {
    @MainActor static func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.observingFacilitiesDirectoryFile()
    }

    //TODO: Implement me!
    static func loadFromLocalProvider() async throws -> PolisObjectPersisting { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }

    //TODO: Implement me!
    static func loadFromRemoteProvider() async throws -> PolisObjectPersisting { throw ObjectStoreCoordinator.ObjectStoreCoordinatorError.unaccessiblePath }

    //TODO: Implement me!
    func hasChanged() -> Bool { false }

    //TODO: Implement me!
    func saveLocally() async throws { }

    //TODO: Implement me!
    func saveRemotely() async throws { }
}


