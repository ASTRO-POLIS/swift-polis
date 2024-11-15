//
//  PolisArtifact.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11/11/2024.
//

import Foundation

/// Often ``PolisObservingFacility`` instances contain historically  interesting artefacts or facilities specially
/// designated for visitors (visitor centres, planetariums, museums, ...). `PolisArtifact` encapsulates such
/// artefacts.
///
/// **Note:** `PolisArtifact` is always part of an ``PolisObservingFacility`` and therefore inherits
/// the visiting hours.
public struct PolisArtifact: Codable, Identifiable {

    public enum ArtifactType: String, Codable {
        case museum
        case planetarium
        case monument
        case ancientSite          = "ancient_site"
        case conferenceFacility   = "conference_facility"
        case visitorCentre        = "visitor_centre"
        case starPartyHostingSite = "star_party_hosting_site"
        case unknown
    }

    public var identity: PolisIdentity
    public var artifactType: ArtifactType

    public var visitingOpportunities: String?
    public var media: PolisMediaSource?

    public var id: UUID { identity.id }

    public init(identity: PolisIdentity,
                artifactType: ArtifactType      = .unknown,
                visitingOpportunities: String?  = nil,
                media: PolisMediaSource?        = nil) {
        self.identity              = identity
        self.artifactType          = artifactType
        self.visitingOpportunities = visitingOpportunities
        self.media                 = media
    }
}

public extension PolisArtifact {
    enum CodingKeys: String, CodingKey {
        case identity
        case artifactType          = "artifact_type"
        case visitingOpportunities = "visiting_opportunities"
        case media
    }
}
