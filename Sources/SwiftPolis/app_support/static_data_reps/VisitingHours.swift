//
//  VisitingHours.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11/06/2026.
//

import Foundation

@Observable open class VisitingHours: PersistentObject, Identifiable, @unchecked Sendable {

    public private(set)  var id: UUID
    public internal(set) var lastUpdateTime: Date
    public private(set)  var facilityID: UUID

    public internal(set) var visitingPossibilities: [PolisVisitingHours.VisitingPossibility]?

    public var note: String?

    //MARK: Internal APIs

    /// This initialiser is to me used to create a new instance of the class
    init(id: UUID = UUID(), lastUpdateTime: Date = Date.now, facilityID: UUID, visitingPossibilities: [PolisVisitingHours.VisitingPossibility]? = nil, note: String? = nil) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let polisObject                         = PolisVisitingHours(facilityID: facilityID)
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: polisObject as any PolisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: polisObject.id,
                                                                                                                 observingFacilityID: polisObject.facilityID),
                                                                 objectType: .observingFacilityEarthFixedBasedDetails)

        self.id                    = id
        self.lastUpdateTime        = lastUpdateTime
        self.facilityID            = facilityID
        self.visitingPossibilities = visitingPossibilities
        self.note                  = note

        await super.init(polisRep: sP)
    }

    var visitingHours: PolisVisitingHours {
        PolisVisitingHours(id: id,
                           lastUpdateTime: lastUpdateTime,
                           facilityID: facilityID,
                           visitingPossibilities: visitingPossibilities,
                           note: note)
    }

    //MARK: - PolisObjectPersisting implementation -
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.observingDataFile(withID: id, observingFacilityID: facilityID)
    }


    override func setDidChange() async {
        lastUpdateTime = Date.now
        _hasChanged    = true
        _polisRep.updateCurrentPolisObject(visitingHours)

        await ObjectStoreCoordinator.shared.didChange(object: self, ofType: .placeOnEarth)
    }

}
