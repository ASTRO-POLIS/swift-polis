//
//  ObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 13.03.26.
//

import Foundation

public enum ObservingFacilityDetailsType {
    case abstract
    case earthFixed
    case planetaryRover
    // ...
}

public protocol ObservingFacilityDetailsImplementing {
    var observingFacilityDetailsType: ObservingFacilityDetailsType { get }
    var facilityID: UUID                                           { get }

}
/// This is an abstract `ObservingFacilityDetails` class that needs to be subclasses to add concrete functionality
@Observable open class ObservingFacilityDetails: PersistentObject, ObservingFacilityDetailsImplementing, @unchecked Sendable {

    //MARK: Info
    public internal(set) var id: UUID
    public internal(set) var lastUpdateTime: Date
    public internal(set) var observingFacilityDetailsType: ObservingFacilityDetailsType = .abstract
    
    public var website: URL?
    public var scientificObjectives: PolisLocalisedText?
    public var history: PolisLocalisedText?

    //MARK: Internal APIs
    init(_ facilityDetail: PolisObservingFacilityDetails) async {
        let fileResourceFinder                   = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject>  = PolisObjectRep(polisObject: facilityDetail as any PolisObject,
                                                                  localPath: fileResourceFinder.observingDataFile(withID: facilityDetail.id,
                                                                                                                  observingFacilityID: facilityDetail.facilityID) ,
                                                                  objectType: .observingFacilityDirectory)

        self.id                    = facilityDetail.id
        self.lastUpdateTime        = facilityDetail.lastUpdateTime
        self.facilityID            = facilityDetail.facilityID
        self.typeSpecificDetailsID = facilityDetail.typeSpecificDetailsID
        self.observatoryIDs        = facilityDetail.observatoryIDs
        self.deviceIDs             = facilityDetail.deviceIDs
        self.ownerID               = facilityDetail.ownerID
        self.mediaSourceID         = facilityDetail.mediaSourceID
        self.artifactIDs           = facilityDetail.artifactIDs
        self.website               = facilityDetail.website
        self.scientificObjectives  = PolisLocalisedText(facilityDetail.scientificObjectives)
        self.history               = PolisLocalisedText(facilityDetail.history)

        await super.init(polisRep: sP)
    }

    //MARK: Below properties should be used only internally for bookkeeping
    public internal(set) var facilityID: UUID
    var typeSpecificDetailsID: UUID?
    var observatoryIDs: Set<UUID>?
    var deviceIDs: Set<UUID>?
    var ownerID: UUID?          // Who are the owners of the POLIS Item?
    var mediaSourceID: UUID?    // Defines a set of media sources (images, audio etc) attached to the POLIS Item

    var facilityDetail: PolisObservingFacilityDetails {
        PolisObservingFacilityDetails(id: id,
                                      facilityID: facilityID,
                                      typeSpecificDetailsID: typeSpecificDetailsID,
                                      observatoryIDs: observatoryIDs,
                                      deviceIDs: deviceIDs,
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
        return fileResourceFinder.observingDataFile(withID: id, observingFacilityID: facilityID)
    }

    override func setDidChange() async {
        let payload = PolisNotificationPayload(entity: .observingFacilityDetail, actionType: .update)

        lastUpdateTime = Date.now
        _hasChanged             = true
       _polisRep.updateCurrentPolisObject(facilityDetail)

        await MainActor.run { NotificationCenter.default.post(PolisObjectDidChange(payload)) }
    }
}
