//
//  EarthFixedBaseObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 23/10/2024.
//

import Foundation

open class EarthFixedBaseObservingFacilityDetails: PersistentObject {

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

    public var place: Place?

    //MARK: - PolisPersisting implementation -
    public func canEdit()                      async -> Bool { false } // Better be on the safe side
    public override func startEditing()        async throws { }
    public override func finishEditing()       async throws { }

    public func saveChanges()                  async throws { }
    public func revertToSaved()                async throws { }
    public func delete()                       async throws { }
    public func loadData()                     async throws { }

    public func didChange()                    async -> Bool { false }

    public func prepareToCloseTheObjectStore() async throws { }


    //MARK: Non-private APIs
    var facilityID: UUID
    var visitingHoursID: UUID?
    var placeID: UUID?

    init(visitingHours: VisitingHours?                         = nil,
         accessRestrictions: String?                           = nil,
         averageClearNightsPerYear: UInt?                      = nil,
         averageSeeingConditions: PolisPropertyValue?          = nil,
         averageSkyQuality: PolisPropertyValue?                = nil,
         traditionalLandOwners: String?                        = nil,
         dominantWindDirection: PolisDirection.RoughDirection? = nil,
         surfaceSize: PolisPropertyValue?                      = nil,
         facilityID: UUID,
         visitingHoursID: UUID?                                = nil,
         placeID: UUID?                                        = nil) async throws {
        self.visitingHours             = visitingHours
        self.accessRestrictions        = accessRestrictions
        self.averageClearNightsPerYear = averageClearNightsPerYear
        self.averageSeeingConditions   = averageSeeingConditions
        self.averageSkyQuality         = averageSkyQuality
        self.traditionalLandOwners     = traditionalLandOwners
        self.dominantWindDirection     = dominantWindDirection
        self.surfaceSize               = surfaceSize
        self.facilityID                = facilityID
        self.visitingHoursID           = visitingHoursID
        self.placeID                   = placeID

        try await super.init()
    }

    
}
