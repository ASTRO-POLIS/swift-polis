//
//  ObservingFacilityDirectory.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25.02.26.
//

import Foundation

@Observable public final class ObservingFacilityDirectory: PersistentObject, @unchecked Sendable {
    var lastUpdateTime: Date // UTC

    init(_ facilityDirectory: PolisObservingFacilityDirectory) async {
        let fileResourceFinder                   = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject>  = PolisObjectRep(polisObject: facilityDirectory as any PolisObject,
                                                                  localPath: fileResourceFinder.observingFacilitiesDirectoryFile(),
                                                                  objectType: .observingFacilityDirectory)

        self.lastUpdateTime = facilityDirectory.lastUpdateTime
        await super.init(polisRep: sP)

        for facility in facilityDirectory.observingFacilityReferences {
            let facility = await ObservingFacility(facility)
            _observingFacilities.append(facility)
        }
    }

    var observingFacilityDirectory: PolisObservingFacilityDirectory {
        var references: [PolisObservingFacilityDirectory.ObservingFacilityReference] = []

        for facility in _observingFacilities {
            let ref = facility.facilityReference

            references.append(ref)
        }

        return PolisObservingFacilityDirectory(lastUpdateTime: lastUpdateTime, observingFacilityReferences: references)
    }

    func addFacility(_ facility: ObservingFacility) async {
        _observingFacilities.append(facility)
        await setDidChange()
    }


    //MARK: : - PolisObjectPersisting implementation -
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.observingFacilitiesDirectoryFile()
    }

    override func setDidChange() async {
        let payload = PolisNotificationPayload(entity: .observingFacilityDirectory, actionType: .update)

        lastUpdateTime = Date.now
        _hasChanged    = true
        _polisRep.updateCurrentPolisObject(observingFacilityDirectory)

        await MainActor.run { NotificationCenter.default.post(PolisObjectDidChange(payload)) }
        _hasChanged = true
    }

    //MARK: Private APIs
    private var _observingFacilities: [ObservingFacility] = []
}

