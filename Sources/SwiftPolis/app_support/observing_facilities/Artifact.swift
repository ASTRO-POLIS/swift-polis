//
//  Artifact.swift
//  swift-polis
//
//  Created by Georg Tuparev on 12.05.26.
//

import Foundation

@Observable open class Artifact: IdentifiablePersistentObject, @unchecked Sendable {

    public internal(set)var facilityID: UUID

    public var artifactType: PolisArtifact.ArtifactType
    public var visitingOpportunities: LocalisableString?
    public var website: URL?

    public override func markAsChanged() async throws {
        //TODO: Implement me!
        try await setDidChange()
    }

    //MARK: (Private like) Internal APIs
    init(_ facility: PolisObservingFacilityDirectory.ObservingFacilityReference, identity: PolisIdentity) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: facility as any PolisObject as any PolisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: identity.id,
                                                                                                                 observingFacilityID: facility.id),
                                                                 objectType: .artifact)


        self.facilityID            = facility.id
        self.artifactType          = .unknown

        await super.init(polisRep: sP, identity: IdentifiableObject(identity: identity))
    }

    init(_ polisArtifact: PolisArtifact) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: polisArtifact as any PolisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: polisArtifact.identity.id,
                                                                                                                 observingFacilityID: polisArtifact.facilityID),
                                                                 objectType: .artifact)
        self.facilityID            = polisArtifact.facilityID
        self.artifactType          = polisArtifact.artifactType
        self.visitingOpportunities = polisArtifact.visitingOpportunities
        self.website               = polisArtifact.website

        await super.init(polisRep: sP, identity: IdentifiableObject(identity: polisArtifact.identity))
    }

    var _mediaID: UUID?

}
