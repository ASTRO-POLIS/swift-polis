//
//  EarthFixBasedObservingFacility.swift
//  swift-polis
//
//  Created by Georg Tuparev on 23/10/2024.
//

import Foundation

open class EarthFixBasedObservingFacility: IdentifiableObject {

    //MARK: Public APIs

    // General info
    public var visitingHours: VisitingHours?
    public var accessRestrictions: String?

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    public var traditionalLandOwners: String?

    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    //MARK: - PolisPersisting implementation -
    public  func saveChanges() async throws {
//        if didChange() {
//
//            //TODO: Implement me!
//
//            // 1. Check if I exist as POLIS file, and if not, create myself
//
//            // 2. Check if I did changed
//
//            // 3. If I changed,
//            // 3.1. Update `super` properties and called the super's `saveChanges()`
//            // 3.1. Update PolisObservingFacilityLocation file
//            // 3.2. Update the POLIS cache in Provider Manager
//            // 3.3. Update the provider directory cache in Provider Manager
//        }
    }

    public func revertToSaved() async throws {
        //TODO: Implement me!
    }

    public func delete() async throws {
        //TODO: Implement me!
    }

    public func loadData() async throws {

        //TODO: Implement me!
    }

    public func didChange() async -> Bool {
        //TODO: Implement me!
        true
    }


    //MARK: Non-private APIs
    var facilityID: UUID
    var visitingHoursID: UUID??

//    var fixedSurfaceEarthBaseDetailsPersistenceReference: PolisReference!

    init(id: UUID, lastUpdateTime: Date = Date(), facilityID: UUID) throws{
        self.facilityID = facilityID

        try super.init(id: id, lastUpdateTime: lastUpdateTime, name: "")  //FIXME: Put proper name!

//        fixedSurfaceEarthBaseDetailsPersistenceReference = try PolisReference(facilityID: id, polisObjectID: id)
    }
}
