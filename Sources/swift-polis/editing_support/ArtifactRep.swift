//
//  ArtifactRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14.05.25.
//

import Foundation


open class ArtifactRep: PersistentItem {


    public var artifactType: PolisArtifact.ArtifactType
    public var visitingOpportunities: String?
    public var mediaID: UUID?

    var facility: ObservingFacilityRep

    init(artifactType: PolisArtifact.ArtifactType = .unknown, visitingOpportunities: String? = nil, mediaID: UUID? = nil, facility: ObservingFacilityRep) {
        self.artifactType = artifactType
        self.visitingOpportunities = visitingOpportunities
        self.mediaID = mediaID
        self.facility = facility

        super.init(id: UUID(), lastUpdateDate: Date.now, name: "<unnamed>")
    }
}
