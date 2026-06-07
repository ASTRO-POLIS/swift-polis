//
//  FixedBaseObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 18.04.26.
//

import Foundation

@Observable open class FixedBaseObservingFacilityDetails: PersistentObject, ObservingFacilityDetailsImplementing, Identifiable, Hashable, @unchecked Sendable {
    public internal(set) var id: UUID
    public internal(set) var lastUpdateTime: Date
    public internal(set) var facilityID: UUID
    public internal(set) var observingFacilityDetailsType: ObservingFacilityDetailsType = .earthFixed

    public var accessRestrictions: PolisLocalisedText?

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    public var traditionalLandOwners: PolisLocalisedText?

    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    //MARK: Make the class Hashable
    public static func == (lhs: FixedBaseObservingFacilityDetails, rhs: FixedBaseObservingFacilityDetails) -> Bool {  lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    public override func markAsChanged() async throws {
        //TODO: Implement me!
        await setDidChange()
    }

    public func placeOnEarth() -> PlaceOnEarth { _placeOnEarth! }

    //TODO: Implement the method!
//    public func observingFacility() -> ObservingFacility {
//    }

    //TODO: Implement Visiting Hours func
    //TODO: Implemented place func

    //MARK: Internal APIs

    /// Create a new instance with known Facility
    init(facility: ObservingFacility) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let polisObject                         = PolisEarthFixedBaseObservingFacilityDetails(facilityID: facility.id)
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: polisObject as any PolisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: polisObject.id,
                                                                                                                 observingFacilityID: facility.id),
                                                                 objectType: .observingFacilityEarthFixedBasedDetails)

        self.id                        = UUID()
        self.lastUpdateTime            = Date.now
        self._facilityID               = facility.id
        self._visitingHoursID          = nil
        self._placeID                  = nil
        self.accessRestrictions        = nil
        self.averageClearNightsPerYear = nil
        self.averageSeeingConditions   = nil // [arcsec]
        self.averageSkyQuality         = nil // [magnitude / arcsec^2]
        self.traditionalLandOwners     = nil
        self.dominantWindDirection     = nil
        self.surfaceSize               = nil

        await super.init(polisRep: sP)

        self._placeOnEarth = await PlaceOnEarth(facilityID: _facilityID)
        self._placeID      = _placeOnEarth.id
        await _placeOnEarth.setDidChange()
    }

    /// Create the instance from an existing POLIS data
    init(_ fixedBaseObservingFacilityDetails: PolisEarthFixedBaseObservingFacilityDetails, mainFacilityDetails: ObservingFacilityDetails) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: fixedBaseObservingFacilityDetails as any PolisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: fixedBaseObservingFacilityDetails.id,
                                                                                                                  observingFacilityID: fixedBaseObservingFacilityDetails.facilityID),
                                                                  objectType: .observingFacilityEarthFixedBasedDetails)

        self.id                   = fixedBaseObservingFacilityDetails.id
        self.lastUpdateTime       = fixedBaseObservingFacilityDetails.lastUpdateTime
        self.facilityID           = fixedBaseObservingFacilityDetails.facilityID
        self._facilityID          = fixedBaseObservingFacilityDetails.facilityID
        self.observingFacilityDetailsType = .earthFixed
        self._visitingHoursID     = fixedBaseObservingFacilityDetails.visitingHoursID
        self._placeID             = fixedBaseObservingFacilityDetails.placeID

        accessRestrictions        = PolisLocalisedText(fixedBaseObservingFacilityDetails.accessRestrictions ?? [:])
        averageClearNightsPerYear = fixedBaseObservingFacilityDetails.averageClearNightsPerYear
        averageSeeingConditions   = fixedBaseObservingFacilityDetails.averageSeeingConditions // [arcsec]
        averageSkyQuality         = fixedBaseObservingFacilityDetails.averageSkyQuality // [magnitude / arcsec^2]
        traditionalLandOwners     = PolisLocalisedText(fixedBaseObservingFacilityDetails.traditionalLandOwners ?? [:])
        dominantWindDirection     = fixedBaseObservingFacilityDetails.dominantWindDirection
        surfaceSize               = fixedBaseObservingFacilityDetails.surfaceSize
        
        await super.init(polisRep: sP)

        //TODO: Get the place using the _placeID
    }

    var polisEarthFixedBaseObservingFacilityDetails: PolisEarthFixedBaseObservingFacilityDetails {
        PolisEarthFixedBaseObservingFacilityDetails(id: id,
                                                    facilityID: facilityID,
                                                    visitingHoursID: _visitingHoursID,
                                                    accessRestrictions: accessRestrictions?.rawValues,
                                                    averageClearNightsPerYear: averageClearNightsPerYear,
                                                    averageSeeingConditions: averageSeeingConditions,
                                                    averageSkyQuality: averageSkyQuality,
                                                    traditionalLandOwners: traditionalLandOwners?.rawValues,
                                                    dominantWindDirection: dominantWindDirection,
                                                    surfaceSize: surfaceSize,
                                                    placeID: _placeID)
    }

    //MARK: Private APIs
    private var _visitingHoursID: UUID?
    private var _placeID: UUID?
    private var _placeOnEarth: PlaceOnEarth!

    //MARK: - PolisObjectPersisting implementation -
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!

        return fileResourceFinder.observingDataFile(withID: id, observingFacilityID: facilityID)
    }

    override func setDidChange() async {
        lastUpdateTime = Date.now
        _hasChanged    = true
        _polisRep.updateCurrentPolisObject(polisEarthFixedBaseObservingFacilityDetails)

        await ObjectStoreCoordinator.shared.didChange(object: self, ofType: .observingFacilityEarthFixedBasedDetails)
    }

}
