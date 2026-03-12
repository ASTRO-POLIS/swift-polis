//
//  ObservingFacilityDirectory.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25.02.26.
//

import Foundation

open class ObservingFacilityDirectory: PersistentObject, @unchecked Sendable {
    var lastUpdate: Date // UTC

    var observingFacilityDirectory: PolisObservingFacilityDirectory {
        var references: [PolisObservingFacilityDirectory.ObservingFacilityReference] = []

        for facility in _observingFacilities {
            let ref = facility.facilityReference

            references.append(ref)
        }

        return PolisObservingFacilityDirectory(lastUpdate: lastUpdate, observingFacilityReferences: references)
    }

    init(_ facilityDirectory: PolisObservingFacilityDirectory) async {
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(originalPolisObject: facilityDirectory as any PolisObject,
                                                                 localPath: "",
                                                                 objectType: .serviceProvider)

        self.lastUpdate = facilityDirectory.lastUpdate
        for facility in facilityDirectory.observingFacilityReferences {
            let facility = await ObservingFacility(identity: IdentifiableObject(identity: facility.identity),
                                                   gravitationalBodyRelationship: facility.gravitationalBodyRelationship,
                                                   placeInTheSolarSystem: facility.placeInTheSolarSystem)
            _observingFacilities.append(facility)
        }
        await super.init(polisRep: sP)
    }

    func addFacility(_ facility: ObservingFacility) {
        _hasChanged = true
        _observingFacilities.append(facility)
    }
    
    //MARK: Private APIs
    private var _observingFacilities: [ObservingFacility] = []


    //MARK: : - PolisObjectPersisting implementation -
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.observingFacilitiesDirectoryFile()
    }

    override func hasChanged() -> Bool { _hasChanged }
    override func setDidChange() async { _hasChanged = true }

    override func saveToLocalProvider() async throws {
        if _hasChanged {
            //TODO: Implement me!
        }
    }

}

