//
//  PolisArtifact.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11/11/2024.
//

import Foundation

public struct PolisArtifact: Codable, Identifiable {

    public enum ArtifactType: String, Codable {
        case museum
        case planetarium
        case monument
        case ancientSite          = "ancient_site"
        case conferenceFacility   = "conference_facility"
        case visitorCentre        = "visitor_centre"
        case starPartyHostingSite = "star_party_hosting_site"
    }

    public var identity: PolisIdentity
    
    public var visitingOpportunities: String?
    public var media: PolisMediaSource?

    public var id: UUID { identity.id }
}

public extension PolisArtifact {
    enum CodingKeys: String, CodingKey {
        case identity
        case visitingOpportunities = "visiting_opportunities"
        case media
    }
}
