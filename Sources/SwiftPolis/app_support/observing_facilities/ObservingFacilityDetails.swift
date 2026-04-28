//
//  ObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 13.03.26.
//

import Foundation

@Observable open class ObservingFacilityDetails: IdentifiablePersistentObject, @unchecked Sendable {

    //MARK: Info
    public var website: URL?
    public var scientificObjectives: PolisLocalisedText?
    public var history: PolisLocalisedText?

    //MARK: Internal APIs
    init(_ facilityDetail: PolisObservingFacilityDetails) async {
        let fileResourceFinder                   = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject>  = PolisObjectRep(polisObject: facilityDetail as any PolisObject,
                                                                  localPath: fileResourceFinder.observingDataFile(withID: facilityDetail.id,
                                                                                                                  observingFacilityID: facilityDetail.parentObservingFacilityID!) ,
                                                                  objectType: .observingFacilityDirectory)
        let newIdentity                          = IdentifiableObject(id: facilityDetail.id,
                                                                      externalReferences: facilityDetail.identity.externalReferences,
                                                                      lastUpdateTime: facilityDetail.identity.lastUpdateTime,
                                                                      lifecycleStatus: facilityDetail.identity.lifecycleStatus,
                                                                      name: PolisLocalisedText(facilityDetail.identity.name),
                                                                      abbreviation:facilityDetail.identity.abbreviation,
                                                                      shortDescription: PolisLocalisedText(facilityDetail.identity.shortDescription),
                                                                      startTime: facilityDetail.identity.startTime,
                                                                      endTime: facilityDetail.identity.endTime,
                                                                      polisRegistrationTime: facilityDetail.identity.polisRegistrationTime)

        self.parentObservingFacilityID = facilityDetail.parentObservingFacilityID
        self.locationID                = facilityDetail.locationID
        self.observatoryIDs            = facilityDetail.observatoryIDs
        self.deviceIDs                 = facilityDetail.deviceIDs
        self.visitingHoursID           = facilityDetail.visitingHoursID
        self.ownerID                   = facilityDetail.ownerID
        self.mediaSourceID             = facilityDetail.mediaSourceID
        self.artifactIDs               = facilityDetail.artifactIDs
        self.website                   = facilityDetail.website
        self.scientificObjectives      = PolisLocalisedText(facilityDetail.scientificObjectives)
        self.history                   = PolisLocalisedText(facilityDetail.history)

        await super.init(polisRep: sP, identity: newIdentity)
    }

    //MARK: Below properties should be used only internally for bookkeeping
    var parentObservingFacilityID: UUID?
    var locationID: UUID?
    var observatoryIDs: Set<UUID>?
    var deviceIDs: Set<UUID>?
    var visitingHoursID: UUID?
    var ownerID: UUID?          // Who are the owners of the POLIS Item?
    var mediaSourceID: UUID?    // Defines a set of media sources (images, audio etc) attached to the POLIS Item

    var facilityDetail: PolisObservingFacilityDetails {
        PolisObservingFacilityDetails(identity: _identity.identity,
                                      parentObservingFacilityID: parentObservingFacilityID,
                                      locationID: locationID,
                                      observatoryIDs: observatoryIDs,
                                      deviceIDs: deviceIDs,
                                      visitingHoursID: visitingHoursID,
                                      ownerID: ownerID,
                                      mediaSourceID: mediaSourceID,
                                      artifactIDs: artifactIDs,
                                      website: website,
                                      scientificObjectives: scientificObjectives?.rawValues,
                                      history: history?.rawValues)
    }

    var artifactIDs: Set<UUID>? // Arifacts of interest could be also on other solar system bodies (e.g. Apollo landing site)

    //MARK: : - PolisObjectPersisting implementation -
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.observingDataFile(withID: _identity.id, observingFacilityID: _parentObservingFacilityID!)
    }

    override func setDidChange() async {
        let payload = PolisNotificationPayload(entity: .observingFacilityDetail, actionType: .update)

        _identity.lastUpdateTime = Date.now
        _hasChanged             = true
       _polisRep.updateCurrentPolisObject(facilityDetail)

        await MainActor.run { NotificationCenter.default.post(PolisObjectDidChange(payload)) }
    }
}
