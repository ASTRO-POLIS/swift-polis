//
//  VisitingHours.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11/06/2026.
//

import Foundation
import SoftwareEtudesUtilities

@Observable open class VisitingHours: PersistentObject, Hashable, @unchecked Sendable {

    public private(set)  var id: UUID
    public internal(set) var lastUpdateTime: Date
    public private(set)  var facilityID: UUID

    public internal(set) var visitingPossibilities: [PolisVisitingHours.VisitingPossibility]!

    public func allVisitingPossibilities() -> [PolisVisitingHours.VisitingPossibility] { visitingPossibilities ?? [] }
    public func visitingPossibilityWith(id: UUID) -> PolisVisitingHours.VisitingPossibility? {
        for visitingPossibility in visitingPossibilities ?? [] {
            if visitingPossibility.id == id { return visitingPossibility }
        }
        return nil
    }
    public func addVisitingPossibility(_ visitingPossibility: PolisVisitingHours.VisitingPossibility) { visitingPossibilities.append(visitingPossibility) }
    public func removeAllVisitingPossibilities() {visitingPossibilities.removeAll() }
    public func removeVisitingPossibilityWith(id: UUID) { visitingPossibilities.removeAll(where: {$0.id == id }) }

    public var note: String?

    //MARK: Make the class Hashable
    public static func == (lhs: VisitingHours, rhs: VisitingHours) -> Bool {  lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    public override func markAsChanged() async throws { await setDidChange() }

    //MARK: Internal APIs

    /// This initialiser is to be used to create a new instance of the class
    init(id: UUID = UUID(), lastUpdateTime: Date = Date.now, facilityID: UUID, visitingPossibilities: [PolisVisitingHours.VisitingPossibility]? = nil, note: String? = nil) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let polisObject                         = PolisVisitingHours(facilityID: facilityID)
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: polisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: polisObject.id,
                                                                                                                 observingFacilityID: polisObject.facilityID),
                                                                 objectType: .observingFacilityEarthFixedBasedDetails)

        self.id                    = id
        self.lastUpdateTime        = lastUpdateTime
        self.facilityID            = facilityID
        self.visitingPossibilities = visitingPossibilities != nil ? visitingPossibilities : []
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

        await ObjectStoreCoordinator.shared.didChange(object: self, ofType: .visitingHours)
    }

}
