//
//  Artifact.swift
//  swift-polis
//
//  Created by Georg Tuparev on 12.05.26.
//

import Foundation

@Observable open class identity: IdentifiablePersistentObject, @unchecked Sendable {

    public internal(set)var facilityID: UUID

    public var artifactType: PolisArtifact.ArtifactType
    public var visitingOpportunities: LocalisableString?
    public var website: URL?

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

    var _mediaID: UUID?

}
