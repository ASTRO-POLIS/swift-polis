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
    public let observingFacilityDetailsType: ObservingFacilityDetailsType = .earthFixed

    // For visitors
    public var accessRestrictions: PolisLocalisedText?

    // Site observing quality
    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    // Are there any claims for the land?
    public var traditionalLandOwners: PolisLocalisedText?

    // Miscellaneous stats
    public var dominantWindDirection: PolisDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    //MARK: Make the class Hashable
    public static func == (lhs: FixedBaseObservingFacilityDetails, rhs: FixedBaseObservingFacilityDetails) -> Bool {  lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    public override func markAsChanged() async throws {
        //TODO: Implement me!
        await setDidChange()
    }

    public func placeOnEarth() -> PlaceOnEarth { _placeOnEarth! }
    public func visitingHours(createIfMissing: Bool = false) async -> VisitingHours? {
        if _visitingHours != nil { return _visitingHours! }
        else if createIfMissing {
            // Now create visitingHours
            self._visitingHours   = await VisitingHours(facilityID: _facilityID)
            self._visitingHoursID = _visitingHours!.id
            await _visitingHours!.setDidChange()
        }
        
        return _visitingHours
    }

    //MARK: Internal APIs

    /// Create a new instance with known Facility
    init(facility: ObservingFacility) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let polisObject                         = PolisEarthFixedBaseObservingFacilityDetails(facilityID: facility.id)
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: polisObject as any PolisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: polisObject.id,
                                                                                                                 observingFacilityID: facility.id),
                                                                 objectType: .observingFacilityEarthFixedBasedDetails)

        self.id                        = polisObject.id
        self.lastUpdateTime            = polisObject.lastUpdateTime
        self._facilityID               = polisObject.facilityID
        self._visitingHoursID          = polisObject.visitingHoursID
        self.accessRestrictions        = PolisLocalisedText(polisObject.accessRestrictions)
        self.averageClearNightsPerYear = polisObject.averageClearNightsPerYear
        self.averageSeeingConditions   = polisObject.averageSeeingConditions
        self.averageSkyQuality         = polisObject.averageSkyQuality
        self.traditionalLandOwners     = PolisLocalisedText(polisObject.traditionalLandOwners)
        self.dominantWindDirection     = polisObject.dominantWindDirection
        self.surfaceSize               = polisObject.surfaceSize
        self._placeID                  = nil

        await super.init(polisRep: sP)

        // Now create the place
        self._placeOnEarth = await PlaceOnEarth(facilityID: _facilityID)
        self._placeID      = _placeOnEarth.id
        await _placeOnEarth.setDidChange()
    }

    /// Create the instance from an existing POLIS data
    init(_ fixedBaseObservingFacilityDetails: PolisEarthFixedBaseObservingFacilityDetails) async {
        //TODO: For the time being this is untested
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: fixedBaseObservingFacilityDetails as any PolisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: fixedBaseObservingFacilityDetails.id,
                                                                                                                  observingFacilityID: fixedBaseObservingFacilityDetails.facilityID),
                                                                  objectType: .observingFacilityEarthFixedBasedDetails)

        self.id                   = fixedBaseObservingFacilityDetails.id
        self.lastUpdateTime       = fixedBaseObservingFacilityDetails.lastUpdateTime
        self.facilityID           = fixedBaseObservingFacilityDetails.facilityID
        self._facilityID          = fixedBaseObservingFacilityDetails.facilityID
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

        //TODO: We need to load the Place here!
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
    private var _visitingHours: VisitingHours?
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
