//
//  ObservingFacilityDirectory.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25.02.26.
//

import Foundation

open class ObservingFacilityDirectory: PolisObjectPersisting {
    var lastUpdate: Date // UTC

    init(_ facilityDirectory: PolisObservingFacilityDirectory) {
        self.lastUpdate = facilityDirectory.lastUpdate
        for facility in facilityDirectory.observingFacilityReferences {
            let facility = ObservingFacility(identity: IdentifiableObject(identity: facility.identity),
                                             gravitationalBodyRelationship: facility.gravitationalBodyRelationship,
                                             placeInTheSolarSystem: facility.placeInTheSolarSystem)
            _observingFacilities.append(facility)
        }
    }

    func addFacility(_ facility: ObservingFacility) {
        _hasChanged = true
        _observingFacilities.append(facility)
    }
    
    //MARK: Private APIs
    private var _observingFacilities: [ObservingFacility] = []
    private var _hasChanged                               = false

}

    //
    //=====================================================================================================================
    //

//MARK: : - PolisObjectPersisting implementation -
extension ObservingFacilityDirectory {
    func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.observingFacilitiesDirectoryFile()
    }

   func hasChanged() -> Bool { _hasChanged }
}


