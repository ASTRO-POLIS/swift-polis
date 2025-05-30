//
//  EarthFixBasedObservingFacilityRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 23/10/2024.
//

import Foundation

open class EarthFixBasedObservingFacilityRep: IdentifiablePersistentItem {

    //MARK: Public APIs

    // General info
    public var visitingHours: VisitingHoursRep?
    public var accessRestrictions: String?

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    public var traditionalLandOwners: String?

    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    //MARK: - PolisPersisting implementation -
    public  func saveChanges() throws {
        if didChange() {

            //TODO: Implement me!

            // 1. Check if I exist as POLIS file, and if not, create myself

            // 2. Check if I did changed

            // 3. If I changed,
            // 3.1. Update `super` properties and called the super's `saveChanges()`
            // 3.1. Update PolisObservingFacilityLocation file
            // 3.2. Update the POLIS cache in Provider Manager
            // 3.3. Update the provider directory cache in Provider Manager
        }
    }

    public func revertToSaved() throws {
        //TODO: Implement me!
    }

    public func delete() throws {
        //TODO: Implement me!
    }

    public func loadData() throws {
        try super.loadData()

        //TODO: Implement me!
    }

    public func didChange() -> Bool {
        //TODO: Implement me!
        true
    }


    //MARK: Non-private APIs
//    static func registerFacilityWithExisting(identity: PolisIdentity) throws -> EarthFixBasedObservingFacilityRep {
//        let result = try EarthFixBasedObservingFacilityRep(id: identity.id, lastUpdateDate: identity.lastUpdateDate, facility)
//
//        return result
//    }

    var facilityID: UUID
    var visitingHoursID: UUID??

    var fixedSurfaceEarthBaseDetailsPersistenceReference: PolisReference!

    init(id: UUID, lastUpdateDate: Date = Date(), facilityID: UUID) throws{
        self.facilityID = facilityID

        try super.init(id: id, lastUpdateDate: lastUpdateDate)

        fixedSurfaceEarthBaseDetailsPersistenceReference = try PolisReference(facilityID: id, polisObjectID: id)
    }
}
