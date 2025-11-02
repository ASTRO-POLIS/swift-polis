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

    public var place: Place!

    public var facility: ObservingFacility!

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
                                                        surfaceSize: surfaceSize)
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
         facility: ObservingFacility,
         visitingHoursID: UUID?                                = nil,
         placeID: UUID?                                        = nil) async throws {
        self.accessRestrictions        = accessRestrictions
        self.averageClearNightsPerYear = averageClearNightsPerYear
        self.averageSeeingConditions   = averageSeeingConditions
        self.averageSkyQuality         = averageSkyQuality
        self.traditionalLandOwners     = traditionalLandOwners
        self.dominantWindDirection     = dominantWindDirection
        self.surfaceSize               = surfaceSize
        self.facility                  = facility
        self.visitingHoursID           = visitingHoursID
        self.placeID                   = placeID

        facilityID                    = facility.id

        try super.init(id: id,
                             lastUpdateTime: lastUpdateTime,
                             facilityID: facilityID,
                             representingStoredObjectType: .observingFacilityDetails)
        try await finaliseInitialisation()
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

        try super.init(id: earthFixedBaseObservingFacilityDetails.id,
                             lastUpdateTime: earthFixedBaseObservingFacilityDetails.lastUpdateTime,
                             facilityID: earthFixedBaseObservingFacilityDetails.facilityID,
                             representingStoredObjectType: .observingFacilityDetails)

        self.earthFixedBaseObservingFacilityDetails = earthFixedBaseObservingFacilityDetails
        try await finaliseInitialisation()
    }

    //MARK: - Private APIs -
    private var _originalEarthFixedBaseObservingFacilityDetails: PolisEarthFixedBaseObservingFacilityDetails!

    private func finaliseInitialisation() async throws {
        localPersistencyStatus = .inMemoryOnly
        _originalEarthFixedBaseObservingFacilityDetails = earthFixedBaseObservingFacilityDetails

        if placeID == nil {
            try place = Place(id: UUID(), facility: facility)
//            placeID   = place.id
        }
        else {
            do    { try await place.loadData() }
            catch { /* TODO: Handle error */ }
        }
    }
}

//MARK: - PolisPersisting implementation -
extension EarthFixedBaseObservingFacilityDetails {
    public func canEdit() async -> Bool {
        (localPersistencyStatus == .inMemoryOnly) || (_originalEarthFixedBaseObservingFacilityDetails != earthFixedBaseObservingFacilityDetails)
    }

//    public override func startEditing()        async throws { }
//    public override func finishEditing()       async throws { }

    public func saveChanges() async throws {
        guard await canEdit() else { return }

        nc.post(name: AppSupportStatusChangeNotification.earthBasedFacilityWillSaveNotification, object: self)
        try await earthFixedBaseObservingFacilityDetails.flashUsing(store: sharedObjectStore)
        nc.post(name: AppSupportStatusChangeNotification.earthBasedFacilityDidSaveNotification, object: self)
    }

    public func revertToSaved()                async throws { }
    public func delete()                       async throws { }

    public func loadData() async throws {
        nc.post(name: AppSupportStatusChangeNotification.earthBasedFacilityWillLoadNotification, object: self)

        self.earthFixedBaseObservingFacilityDetails = try await PolisEarthFixedBaseObservingFacilityDetails.loadFromLocalFileSystemUsing(store: sharedObjectStore,
                                                                                                    facilityID: facilityID,
                                                                                                    objectType: .observingFacilityDetails) as! PolisEarthFixedBaseObservingFacilityDetails

        //TODO: Load referenced objects!
        nc.post(name: AppSupportStatusChangeNotification.earthBasedFacilityDidLoadNotification, object: self)
        nc.post(name: AppSupportStatusChangeNotification.facilityDidChangeNotification, object: facility)
    }

    public func didChange()                    async -> Bool { false }

    public func prepareToCloseTheObjectStore() async throws { }

    private func ensureIKnowMyFacility() async throws {
        if self.facility != nil                                                      { return }
        guard let possibleFacility = await sharedObjectStore.facilityWithId(id) else { throw ObjectStore.ObjectStoreError.objectWithIDNotFound }

        self.facility = possibleFacility
    }

}
