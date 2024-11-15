//
//  PolisArtifact.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11/11/2024.
//

import Foundation

/// `PolisObservingFacility` encapsulates non-observing artifacts like museums, planetariums etc.
///
/// Often ``PolisObservingFacility`` instances contain historically  interesting artifacts or facilities specially
/// designated for visitors (visitor centres, planetariums, museums, ...). `PolisArtifact` encapsulates such
/// artifacts.
///
/// **Note:** `PolisArtifact` is always part of an ``PolisObservingFacility`` and therefore inherits
/// the visiting hours.
public struct PolisArtifact: Codable, Identifiable {

    /// The type of the artifact
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

    /// The identity of the artifact
    public var identity: PolisIdentity

    /// The type of the artifact
    public var artifactType: ArtifactType

    ///  Describes the attractiveness of the artifact and how to visit it
    ///
    ///  **Note:** Visiting hours should be defined by the observing site
    public var visitingOpportunities: String?

    /// Mostly images (photos)
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
