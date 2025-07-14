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

    public func saveChanges() async throws {
        nc.post(name: AppSupportStatusChangeNotification.earthBasedFacilityWillSaveNotification, object: self)
        try await earthFixedBaseObservingFacilityDetails.flashUsing(store: store)
        nc.post(name: AppSupportStatusChangeNotification.earthBasedFacilityDidSaveNotification, object: self)
    }

    public func revertToSaved()                async throws { }
    public func delete()                       async throws { }
    public func loadData()                     async throws { }

    public func didChange()                    async -> Bool { false }

    public func prepareToCloseTheObjectStore() async throws { }


    //MARK: Non-private APIs
    var facilityID: UUID
    var visitingHoursID: UUID?
    var placeID: UUID?

    var earthFixedBaseObservingFacilityDetails: PolisEarthFixedBaseObservingFacilityDetails {
        get {
            PolisEarthFixedBaseObservingFacilityDetails(id: id,
                                                        lastUpdateTime: lastUpdateTime,
                                                        facilityID: facilityID,
                                                        visitingHoursID: visitingHoursID,
                                                        accessRestrictions: accessRestrictions,
                                                        averageClearNightsPerYear: averageClearNightsPerYear,
                                                        averageSeeingConditions: averageSeeingConditions,
                                                        averageSkyQuality: averageSkyQuality,
                                                        traditionalLandOwners:traditionalLandOwners,
                                                        dominantWindDirection: dominantWindDirection,
                                                        surfaceSize: surfaceSize,
                                                        placeID: placeID)
        }
        set {
            id                        = newValue.id
            lastUpdateTime            = newValue.lastUpdateTime
            facilityID                = newValue.facilityID
            visitingHoursID           = newValue.visitingHoursID
            accessRestrictions        = newValue.accessRestrictions
            averageClearNightsPerYear = newValue.averageClearNightsPerYear
            averageSeeingConditions   = newValue.averageSeeingConditions
            averageSkyQuality         = newValue.averageSkyQuality
            traditionalLandOwners     = newValue.traditionalLandOwners
            dominantWindDirection     = newValue.dominantWindDirection
            surfaceSize               = newValue.surfaceSize
            placeID                   = newValue.placeID
        }
    }

    init(id: UUID                                              = UUID(),
         lastUpdateTime: Date                                  = Date(),
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

        try super.init(id: id,
                             lastUpdateTime: lastUpdateTime,
                             facilityID: facilityID,
                             representingStoredObjectType: .observingFacilityDetails)
    }

    init(earthFixedBaseObservingFacilityDetails: PolisEarthFixedBaseObservingFacilityDetails) async throws {
        self.accessRestrictions        = earthFixedBaseObservingFacilityDetails.accessRestrictions
        self.averageClearNightsPerYear = earthFixedBaseObservingFacilityDetails.averageClearNightsPerYear
        self.averageSeeingConditions   = earthFixedBaseObservingFacilityDetails.averageSeeingConditions
        self.averageSkyQuality         = earthFixedBaseObservingFacilityDetails.averageSkyQuality
        self.traditionalLandOwners     = earthFixedBaseObservingFacilityDetails.traditionalLandOwners
        self.dominantWindDirection     = earthFixedBaseObservingFacilityDetails.dominantWindDirection
        self.surfaceSize               = earthFixedBaseObservingFacilityDetails.surfaceSize
        self.facilityID                = earthFixedBaseObservingFacilityDetails.facilityID
        self.visitingHoursID           = earthFixedBaseObservingFacilityDetails.visitingHoursID
        self.placeID                   = earthFixedBaseObservingFacilityDetails.placeID

        try await super.init(id: earthFixedBaseObservingFacilityDetails.id,
                             lastUpdateTime: earthFixedBaseObservingFacilityDetails.lastUpdateTime,
                             facilityID: earthFixedBaseObservingFacilityDetails.facilityID,
                             representingStoredObjectType: .observingFacilityDetails)

        self.earthFixedBaseObservingFacilityDetails = earthFixedBaseObservingFacilityDetails
    }

}
