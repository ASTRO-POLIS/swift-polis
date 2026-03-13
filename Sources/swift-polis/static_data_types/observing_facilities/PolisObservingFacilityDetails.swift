//
//  PolisObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25/09/2024.
//

import Foundation

public struct PolisObservingFacilityDetails: Identifiable, Codable, Equatable, Sendable {

    //MARK: Identification & relationship to other facilities
    public var identity: PolisIdentity
    public var parentObservingFacilityID: UUID?

    //MARK: Contains
    public var locationID: UUID?
    public var observatoryIDs: Set<UUID>?
    public var deviceIDs: Set<UUID>?
    public var visitingHoursID: UUID?
    public var ownerID: UUID?          // Who are the owners of the POLIS Item?
    public var mediaSourceID: UUID?    // Defines a set of media sources (images, audio etc) attached to the POLIS Item
    public var artifactIDs: Set<UUID>? // Arifacts of interest could be also on other solar system bodies (e.g. Apollo landing site)

    //MARK: Info
    public var website: URL?
    public var scientificObjectives: [String : String]?
    public var history: [String : String]?

    //MARK: Identifiable protocol compliance
    public var id: UUID { identity.id }

    public init(identity: PolisIdentity,
                parentObservingFacilityID: UUID?         = nil,

                locationID: UUID?                        = nil,
                observatoryIDs: Set<UUID>?               = nil,
                deviceIDs: Set<UUID>?                    = nil,
                visitingHoursID: UUID?                   = nil,
                ownerID: UUID?                           = nil,
                mediaSourceID: UUID?                     = nil,
                artifactIDs: Set<UUID>?                  = nil,

                website: URL?                            = nil,
                scientificObjectives: [String : String]? = nil,
                history: [String : String]?              = nil) {
        self.identity                  = identity
        self.parentObservingFacilityID = parentObservingFacilityID

        self.locationID                = locationID
        self.observatoryIDs            = observatoryIDs
        self.deviceIDs                 = deviceIDs
        self.visitingHoursID           = visitingHoursID
        self.ownerID                   = ownerID
        self.mediaSourceID             = mediaSourceID
        self.artifactIDs               = artifactIDs

        self.website                   = website
        self.scientificObjectives      = scientificObjectives
        self.history                   = history
    }
}

public extension PolisObservingFacilityDetails {
    enum CodingKeys: String, CodingKey {
        case identity
        case parentObservingFacilityID = "parent_observing_facility_id"

        case locationID                = "location_id"
        case observatoryIDs            = "observatory_ids"
        case deviceIDs                 = "device_ids"
        case visitingHoursID           = "visiting_hours_id"
        case ownerID                   = "owner_id"
        case mediaSourceID             = "media_source_id"
        case artifactIDs               = "artifact_ids"

        case website
        case scientificObjectives      = "scientific_objectives"
        case history
    }
}
