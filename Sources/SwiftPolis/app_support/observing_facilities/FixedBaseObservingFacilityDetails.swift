//
//  FixedBaseObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 18.04.26.
//

import Foundation

@Observable open class FixedBaseObservingFacilityDetails: PersistentObject, @unchecked Sendable {

    public internal(set) var id: UUID
    public internal(set)var lastUpdateTime: Date
    public var accessRestrictions: PolisLocalisedText?
    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]
    public var traditionalLandOwners: PolisLocalisedText?
    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    //TODO: Implement the method!
//    public func observingFacility() -> ObservingFacility {
//    }

    //TODO: Implement Visiting Hours func
    //TODO: Implemented place func

    //MARK: Internal APIs

    /// Create a new instance with known Facility
    init(facility: ObservingFacility) async {
        let fileResourceFinder                   = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let polisObject                          = PolisEarthFixedBaseObservingFacilityDetails(facilityID: facility.id)
        let sP: PolisObjectRep<any PolisObject>  = PolisObjectRep(polisObject: polisObject as any PolisObject,
                                                                  localPath: fileResourceFinder.observingDataFile(withID: polisObject.id,
                                                                                                                  observingFacilityID: facility.id) ,
                                                                  objectType: .observingFacilityEarthFixedBasedDetails)

        self.id                   = polisObject.id
        self.lastUpdateTime       = Date.now
        self._facilityID          = facility.id
        self._visitingHoursID     = nil
        self._placeID             = nil            //TODO: This need to be changed. We need automatically to create a place

        accessRestrictions        = nil
        averageClearNightsPerYear = nil
        averageSeeingConditions   = nil // [arcsec]
        averageSkyQuality         = nil // [magnitude / arcsec^2]
        traditionalLandOwners     = nil
        dominantWindDirection     = nil
        surfaceSize               = nil

        await super.init(polisRep: sP)
    }

    /// Create the instance from an existing POLIS data
    init(_ fixedBaseObservingFacilityDetails: PolisEarthFixedBaseObservingFacilityDetails) async {
        let fileResourceFinder                   = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject>  = PolisObjectRep(polisObject: fixedBaseObservingFacilityDetails as any PolisObject,
                                                                  localPath: fileResourceFinder.observingDataFile(withID: fixedBaseObservingFacilityDetails.id,
                                                                                                                  observingFacilityID: fixedBaseObservingFacilityDetails.facilityID) ,
                                                                  objectType: .observingFacilityEarthFixedBasedDetails)
        self.id                   = fixedBaseObservingFacilityDetails.id
        self.lastUpdateTime       = fixedBaseObservingFacilityDetails.lastUpdateTime
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
    }
    
    //MARK: Private APIs
    private var _facilityID: UUID
    private var _visitingHoursID: UUID?
    private var _placeID: UUID?

}
