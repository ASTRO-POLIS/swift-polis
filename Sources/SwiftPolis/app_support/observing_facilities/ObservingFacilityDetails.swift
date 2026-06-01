//
//  ObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 13.03.26.
//

import Foundation

public enum ObservingFacilityDetailsType {
    case main
    case earthFixed
    case planetaryRover
    // ...
}

// It is expected that all Observing Facility Details types do confirm to this protocol
public protocol ObservingFacilityDetailsImplementing {
    var observingFacilityDetailsType: ObservingFacilityDetailsType { get }
    var facilityID: UUID                                           { get }
}

@Observable open class ObservingFacilityDetails: PersistentObject, ObservingFacilityDetailsImplementing, Hashable, @unchecked Sendable {

    //MARK: Info
    public internal(set) var id: UUID
    public internal(set) var lastUpdateTime: Date
    public internal(set) var observingFacilityDetailsType: ObservingFacilityDetailsType = .main

    public var website: URL?
    public var scientificObjectives: PolisLocalisedText?
    public var history: PolisLocalisedText?

    //MARK: Make the class Hashable
    public static func == (lhs: ObservingFacilityDetails, rhs: ObservingFacilityDetails) -> Bool {  lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    //MARK: Internal APIs
    init (facilityID: UUID) async {
        let newID                                = UUID()
        let polisObject                          = PolisObservingFacilityDetails(id: newID, facilityID: facilityID)
        let fileResourceFinder                   = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject>  = PolisObjectRep(polisObject: polisObject as any PolisObject,
                                                                  localPath: fileResourceFinder.observingDataFile(withID: newID,
                                                                                                                  observingFacilityID: facilityID),
                                                                  objectType: .observingFacilityDirectory)

        self.id             = newID
        self.facilityID     = facilityID
        self.lastUpdateTime = Date()

        await super.init(polisRep: sP)
    }

    init(_ facilityDetail: PolisObservingFacilityDetails) async {
        let fileResourceFinder                   = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject>  = PolisObjectRep(polisObject: facilityDetail as any PolisObject,
                                                                  localPath: fileResourceFinder.observingDataFile(withID: facilityDetail.id,
                                                                                                                  observingFacilityID: facilityDetail.facilityID),
                                                                  objectType: .observingFacilityDirectory)

        self.id                    = facilityDetail.id
        self.lastUpdateTime        = facilityDetail.lastUpdateTime
        self.facilityID            = facilityDetail.facilityID
        self.typeSpecificDetailsID = facilityDetail.typeSpecificDetailsID
        self.observatoryIDs        = facilityDetail.observatoryIDs
        self.deviceIDs             = facilityDetail.deviceIDs
        self.ownerID               = facilityDetail.ownerID
        self.mediaSourceID         = facilityDetail.mediaSourceID
        self._artifactIDs          = facilityDetail.artifactIDs
        self.website               = facilityDetail.website
        self.scientificObjectives  = PolisLocalisedText(facilityDetail.scientificObjectives)
        self.history               = PolisLocalisedText(facilityDetail.history)

        await super.init(polisRep: sP)
        try? await loadArtifacts()
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
                                      artifactIDs: _artifactIDs,
                                      website: website,
                                      scientificObjectives: scientificObjectives?.rawValues,
                                      history: history?.rawValues)
    }

    //MARK: Real private APIs
    private var _artifactIDs: Set<UUID>?
    private var _artifacts: [Artifact] = []

    //MARK: - PolisObjectPersisting implementation -
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.observingDataFile(withID: id, observingFacilityID: facilityID)
    }

    public override func markAsChanged() async throws { await setDidChange() }

    override func setDidChange() async {
//        let payload = PolisNotificationPayload(entity: .observingFacilityDetail, actionType: .update)

        lastUpdateTime = Date.now
        _hasChanged    = true
        _polisRep.updateCurrentPolisObject(facilityDetail)

        await ObjectStoreCoordinator.shared.didChange(object: self, ofType: .observingFacilityDetail)
    }
}

//MARK: - Working with Artifacts -
extension ObservingFacilityDetails {
    public func addArtifactWith(artifactType: PolisArtifact.ArtifactType) async -> Artifact {
        let identity      = PolisIdentity()
        let polisArtifact = PolisArtifact(identity: identity, facilityID: self.id, artifactType: artifactType)
        let artifact      = await Artifact(polisArtifact)

        try? await artifact.markAsChanged()

        if _artifactIDs == nil { _artifactIDs = [] }

        _artifactIDs!.insert(polisArtifact.id)
        _artifacts.append(artifact)
        try? await markAsChanged()
        await ObjectStoreCoordinator.shared.didChange(object: artifact, ofType: .artifact)

        return artifact
    }

    public func artifacts() -> [Artifact] { return _artifacts }

    public func artifactWith(id: UUID) -> Artifact? {
        //TODO: Implement me!
        return nil
    }

    private func loadArtifacts() async throws {
        if (_artifactIDs != nil) && (_artifactIDs!.count != _artifacts.count) {
            for artifactID in _artifactIDs! {
                let anArtifactRep = try await Artifact.fromLocalData(polisType: .artifact, facilityID: facilityID, objectID: artifactID)
                let anArtifact    = await Artifact(anArtifactRep.polisObject as! PolisArtifact)

                _artifacts.append(anArtifact)
            }

        }
    }
}
