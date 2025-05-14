//
//  ArtifactRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14.05.25.
//

import Foundation


open class ArtifactRep: PersistentAuxiliaryItem {

    public var artifactType: PolisArtifact.ArtifactType
    public var visitingOpportunities: String?
    public var mediaID: UUID?

    var facility: ObservingFacilityRep

    init(identity: PolisIdentity,
         artifactType: PolisArtifact.ArtifactType = .unknown,
         visitingOpportunities: String?           = nil,
         mediaID: UUID?                           = nil,
         facility: ObservingFacilityRep) {
        self.artifactType          = artifactType
        self.visitingOpportunities = visitingOpportunities
        self.mediaID               = mediaID
        self.facility              = facility

        super.init(id: identity.id, lastUpdateDate: identity.lastUpdateDate, name: identity.name ?? "<unnamed>")
    }
}
